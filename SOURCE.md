# Exact source and build provenance — v0.1.2 and v0.2.0

Current base is NOT Konoha. Original authorship and licences remain applicable.

| Component | Upstream repository | Exact revision |
|---|---|---|
| Kernel | https://github.com/xiaomi-onyx-playground/android_kernel_xiaomi_sm8735 |7750565ada3d57e195798519b005d2b038e888c1|
| KernelSU Next |https://github.com/KernelSU-Next/KernelSU-Next|b427a3f9c2421a443f961007bfce66b25486643f|
| Archer rtl8812au |https://github.com/aircrack-ng/rtl8812au|734485506a30d6237c2deaad666a19f8ca5379f2|
| WN rtl8188eus |https://github.com/aircrack-ng/rtl8188eus|af3bf004458f76b7aec33e9ba552cd382ed1f5c3|
| AnyKernel3 |https://github.com/osm0sis/AnyKernel3|41f04bdb4ee30a44e429c2c1131d5e8bb32b15f1|
| Magisk installer tools |https://github.com/topjohnwu/Magisk|v31.1; exact tool provenance bundled with kernel|
| Kali artwork |https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-installer|aa1dca61435cc8a7e9f4053234c731855329e69b|

Full upstream source is available at each exact pinned revision. This repository includes downstream modifications, matching configuration and build/install source. `release-source/v0.1.2` contains complete kernel/driver patch files, exact resolved.config, installed installer/module shell sources, wallpaper Java helper source and packaging recipes. The recipes document the original local staging layout; they are not a claim of a one-command self-contained rebuild.

Kernel build recipe: `.github/workflows/rom-branded-kernel.yml`, LLVM22.1.8, KBUILD_BUILD_USER=Rohit-Sharma and KBUILD_BUILD_HOST=Built-for-NetHunter-Rebuilt-from-Onyx. Kernel build41207879867. Apply the kernel integration patch with KernelSU source at `.root_modules/KernelSU-Next` and `drivers/kernelsu` symlink, use matching resolved.config, then `make O=out ARCH=arm64 LLVM=-22 Image modules`. Preserve version/config/CFI/KASAN; no CRC/security bypass.

Driver recipes: `.github/workflows/rom-archer-tx-tasklet-fix.yml` (run41297489306), `.github/workflows/rom-wn722n-cfi-fix.yml` (run41316130882). Apply either the full corresponding patch OR the base/preparation helpers, not both. Use exact running kernel headers/config/Module.symvers; the matched table is available in the named public build-evidence artifacts. Archer built with CONFIG_RTW_DEBUG=y and is loaded with rtw_drv_log_level=1. WN includes software LED code. Guard source is `compatibility/usb_auth_guard.c`; its workflow is `.github/workflows/usb-auth-guard.yml` (run41200495879).

Source-Reconstruction-Kit contains these downstream sources/config/patches and recipes; it does not contain full upstream trees, toolchain binaries, user data or boot backups. Retrieve upstream trees from the exact pins above. Keep original licence notices and provide corresponding sources/modifications when redistributing, rather than removing credits.


## v0.2.0 combined update

Kernel Image is byte-identical to the existing working build (SHA256 `02a8135044334ecf4c98d4ca804d2afcaf2f990f95825d9401e97c174e45eeea`). Existing original KernelSU Next pin remains; this release does not use the abandoned v3.4.2 experiment.

Packaging scripts, module scripts and integration patches: [release-source/v0.2.0](release-source/v0.2.0).

Internal WLAN module upstream: [xiaomi-onyx-playground modules](https://github.com/xiaomi-onyx-playground/android_kernel_xiaomi_sm8735-modules/tree/02727998cd386983341bfc79c34dd20f5be7fb1b), injection patch from [Loukious](https://github.com/Loukious/vendor_qcom_opensource_wlan/commit/25875eb1a65e94fae404c6e9188c7a1fe679e0f5), plus the included mission-mode capability guard. Guarded build evidence: Actions run 43794293758. Driver SHA256 `4d8d93b7154109fa840f1052fda7e19fc8da7085b3b985018bd280351a573c6d`.

Bluetooth bridge uses [mer-hybris/bluebinder](https://github.com/mer-hybris/bluebinder/tree/ebab7c3c3fb15f0eea4db0ff14837066a716f973) with included AIDL adaptation and session-supervisor sources; libgbinder/libglibutil original notices remain. Existing Realtek, guard, tool and artwork source references/licences remain as documented in this repository and the package notices. These upstream components are not claimed as original project code.

## Rebuilding and continuing development

Start with [BUILDING](docs/BUILDING.md) and [KNOWN ISSUES](docs/KNOWN-ISSUES.md). Public config/CRC inputs are in `build-inputs/v0.2.0`; new manual driver workflows do not depend on expiring baseline artifacts. All current release text sources and binary input hashes are recorded in `release-source/v0.2.0/packaging`. `scripts/package_release.py` rebuilds ZIP content from those sources and supplied/locked binary inputs. A packaging round-trip is not a source compilation; historical Bluetooth/compiler bit-reproducibility limitations are explicitly documented in the build guide. Source/config/patches remain open. Personal handover/agent instructions and private device data are maintained separately by the owner.
