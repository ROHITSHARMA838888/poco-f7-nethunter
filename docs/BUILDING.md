# Build and packaging guide

## Start here

The repo publishes downstream changes and exact upstream revisions rather than vendoring millions of upstream files. Clone recursively only when a documented upstream needs it; never substitute latest HEAD. Read `SOURCE.md` for all pins. Linux x86-64 is the build environment; Windows can trigger the workflows without WSL.

The build produces a kernel `Image` and separate modules. The flashable ZIP is a later packaging step. A successful build is not a successful phone test.

## Working release inputs

| Component | Exact input / recipe |
| --- | --- |
| Kernel | Onyx source `7750565ada3d57e195798519b005d2b038e888c1` |
| KernelSU Next | Original working source `b427a3f9c2421a443f961007bfce66b25486643f`; do not replace with the abandoned v3.4.2 experiment |
| Config + kernel symbols | `build-inputs/v0.2.0/resolved.config`, `Module.symvers`, checked by their `SHA256SUMS` |
| External Wi-Fi | Existing `rom-archer-tx-tasklet-fix.yml` / `rom-wn722n-cfi-fix.yml`, pins in `SOURCE.md` |
| Internal Wi-Fi | `rebuild-internal-wlan.yml`, vendor source pin + two patches in `experimental/wcn7750` |
| VHCI | `rebuild-vhci.yml`, exact kernel source/ABI table |
| USB guard | `compatibility/usb_auth_guard.c`, `usb-auth-guard.yml` |
| Bluetooth bridge | Sources and build scripts in `release-source/v0.2.0/bluetooth-source` |
| Installer, scripts, visuals provenance | `release-source/v0.2.0/packaging/templates`, per-entry hashes/metadata in `package-inputs.lock.json` |

Original kernel build used apt LLVM 22.1.8; internal-WLAN/VHCI workflows pin the upstream LLVM 22.1.8 archive and its SHA256. The historical kernel workflow's apt repository can advance; inspect compiler output and require the expected version before claiming reproduction. Build timestamps, debug paths, tar ordering and compression versions can affect byte-for-byte hashes even when code is functionally equivalent.

## Trigger builds on your fork

Enable Actions, then use **Run workflow**. New driver workflows are manual-only; merely opening a PR does not compile or deploy code.

```sh
gh workflow run rom-branded-kernel.yml --repo YOUR_ACCOUNT/YOUR_FORK --ref YOUR_BRANCH
gh workflow run rebuild-internal-wlan.yml --repo YOUR_ACCOUNT/YOUR_FORK --ref YOUR_BRANCH
gh workflow run rebuild-vhci.yml --repo YOUR_ACCOUNT/YOUR_FORK --ref YOUR_BRANCH
```

Run the external driver/guard workflows as needed. They are already in `.github/workflows`. Download their artifacts and validate symbols/config against the target ROM before packaging. The bundled baseline config/symbols remove the new driver workflows' dependency on old expiring Actions artifacts. Other historical diagnostic workflows may still reference old artifacts and are not release recipes.

## Kernel locally (Linux)

Install build-essential, flex, bison, libssl-dev, libelf-dev, bc, dwarves, Python, git, kmod and the matching LLVM toolchain. Follow the exact source fetch, KSU wiring and ABI witness steps in `rom-branded-kernel.yml`. Set `KBUILD_BUILD_USER=Rohit-Sharma`, `KBUILD_BUILD_HOST=Built-for-NetHunter-Rebuilt-from-Onyx` and `KBUILD_BUILD_VERSION=1` for the historical identity.

```sh
# Once pinned source and KSU wiring are prepared as in the workflow:
mkdir -p rom-kernel/out
cp build-inputs/v0.2.0/resolved.config rom-kernel/out/.config
make -C rom-kernel O=out ARCH=arm64 LLVM=-22 olddefconfig
make -C rom-kernel O=out ARCH=arm64 LLVM=-22 -j"$(nproc)" Image modules
```

Review the resolved config diff and complete imported-symbol CRCs. Never copy the old symbol table over a new kernel to conceal a mismatch. Exact strings alone are insufficient, and source builds cannot be described as device-tested until a real boot/test passes.

## Bluetooth userspace

`build-isolated.sh` and `build-supervisor.sh` record the actual ARM64 Kali build: libgbinder dev/runtime **1.1.54-2**, libglibutil dev/runtime **1.0.83-2**, plus GLib. The C sources are public. These historical scripts use Android/chroot staging and must not be run blindly against a daily phone. For a clean ARM64 build container, install the same dependencies, adapt the staging paths, compile the Bluebinder C source using the recorded flags and compile the supervisor with `gcc -static -O2 -Wall -Wextra -Werror`.

The payload contains `bluebinder-candidate` plus extracted dependency headers/libraries. Both the AIDL adaptation (`bluebinder-aidl-candidate.c`) and its diagnostic trace variant (`bluebinder-trace.c`) are included. The shipped binary has TRACE RX/TX strings, so use the trace variant to reproduce its diagnostic behavior; do not mistake the untraced earlier file for the complete current source. See `package-inputs.lock.json` for the exact shipped payload hash. Versioned Debian packages may need the distribution snapshot/archive if removed from current mirrors. The original compiler/container filesystem and package download checksums were not fully recorded; a byte-identical Bluetooth payload source rebuild is **not yet proven**. Do not invent missing provenance. Use the locked release input for unchanged dependencies or qualify rebuilt ones independently.

## Repackage the exact published content

Requires Python 3.10+. This reads public text templates and uses hash-locked published ZIPs **only as donors for binary/data inputs**; it does not execute them or compile code:

```sh
python3 scripts/package_release.py --download-inputs --output .private/repacked-v0.2.0
```

Alternatively, supply downloaded published ZIPs with `--release-directory PATH`. For a fully compiled rebuild, put each binary/data input under `INPUTS/kernel/<zip-path>` or `INPUTS/module/<zip-path>` and use `--inputs INPUTS`. Required names/hashes are listed in `package-inputs.lock.json`.

To develop changes, edit templates and provide your newly compiled inputs, then:

```sh
python3 scripts/package_release.py --inputs INPUTS --development --output .private/new-candidate
```

This regenerates nested/package manifests. It does not automatically update the release version or qualify ABI/runtime compatibility. Update metadata, source records and version history before publishing a new version. All output filenames remain the fixture names until intentionally versioned; do not overwrite public v0.2.0 assets.

## Validate before distribution

1. Run `python3 .github/scripts/check_repository.py` and the privacy scanner.
2. Verify ZIP contents/manifests, unchanged binaries where intended, config diff and ABI imports.
3. On an authorized test device, check boot/root, normal Wi-Fi/hotspot/audio, internal monitor→normal, USB adapters, Bluetooth Start/UP/Stop and reconnect. Do not assume an old test covers changed bytes.
4. Record failures without suppressing warnings. Test only authorized owned networks; stop and restore after a failure.
5. Prepare README/changelog, get the owner's final release approval, then publish versioned kernel/module ZIPs together.
