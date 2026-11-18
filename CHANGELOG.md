# Changelog

## Onyx NetHunter v0.2.0 — POCO F7 / onyx

Unofficial update. **Download both ZIPs for a fresh setup.** Existing matching-kernel users can update only the module.

### Downloads & installation

- **Kernel ZIP:** `Onyx-NetHunter-v0.2.0-Kernel.zip` → OrangeFox recovery → Install → Flash → reboot.
- **Combined module:** `Onyx-NetHunter-v0.2.0-WiFi-Bluetooth-KernelSU.zip` → KernelSU Next → Modules → Install → reboot.
- [Flashing guide and commands](https://github.com/ROHITSHARMA838888/poco-f7-nethunter/blob/main/README.md#installation)

### v0.2.0 — New changes

- Added guarded internal Wi-Fi injection and deauth support; monitor mode working.
- Internal targeted deauth tested: owned laptop connection reset and recovered in about 3 seconds.
- Added internal Bluetooth bridge and VHCI integration to the main Wi-Fi module. Kali Bluetooth Start creates HCI; UP/Stop/restore working.
- Kept the fixed Archer T2U Plus / WN722N v2/v3 drivers and USB reconnect guard.
- Added Blue Glitch boot animation and wallpaper assets; no bundled APKs or Kali chroot.
- Removed ROM-name, Android-version and build/patch-date installer allowlists. Device and essential compatibility checks remain.
- Existing working Linux 6.6.142 kernel Image retained. No SUSFS or abandoned v3.4.2 experimental build included.

### Previous version — v0.1.2

The earlier release included KernelSU Next, external Archer/WN722N monitor/injection/deauth support, MDK and USB HID testing, internal Wi-Fi **monitor mode only**, and the earlier Kali visuals. Its downloadable module was later refreshed with the v0.1.4 USB-guard/path fix. It did not include the new internal injection/deauth or combined Bluetooth bridge.

[View the separate v0.1.2 release and its changelog](https://github.com/ROHITSHARMA838888/poco-f7-nethunter/releases/tag/v0.1.2)

### Before flashing

**POCO F7 / onyx only.** Back up Boot; keep the bootloader unlocked. Stop monitor/Kali Bluetooth sessions and unplug OTG before updating. Module requires the matching kernel and KernelSU Next. Android Bluetooth must be OFF before Kali Bluetooth Start.

Tested on **Infinity-X 4.1 and 4.2 / Android 17**; newest combined-module runtime tests were on 4.2. Other ROMs may be compatible but remain untested. Exact newly versioned ZIPs / revised unrestricted installer still need a fresh flash test; existing Image/drivers and r3 functionality were tested. Banking/Play Integrity issues are not resolved; Bluetooth HID pairing remains unresolved.

[Updates](https://t.me/POCO_F7_NETHUNTER) · [Discussion](https://t.me/poco_f7_discussion)


---

# Changelog

## Validation update — 2026-11-02

These are additional tests of the existing v0.1.2 packages; no kernel/module binary or release ZIP was rebuilt or replaced.

- **USB HID:** actual phone-to-Windows keyboard typing passed with the literal text `hid test ok`. The optional standalone HID switch remains unfinished and is not included in this release; automatic boot activation and seamless NetHunter USB switching are not qualified.
- **Deauthentication:** bounded targeted tests with Archer T2U Plus and TL-WN722N v2/v3 on an owned hotspot passed, with client connection interruption and reconnection observed. The maintainer also reports successful manual testing on another phone.
- **MDK:** maintainer reports working manual tests. Tool version, tested modes and repeatability have not been independently documented; this does not qualify every MDK mode.
- **Internal Wi-Fi:** the current kernel advertises monitor-mode support. Internal deauthentication is reported unsupported on the current setup. Actual internal capture and injection have not been independently validated.
- Exact tested device/ROM restrictions and existing backup/install requirements remain in effect. Other ROMs and long-term stability remain unqualified.

Private network identifiers and raw device logs are not published.

## v0.1.2

- KernelSU Next integration on the documented onyx Linux 6.6.142 base.
- Fixed external Archer and WN722N v2/v3 drivers, persistent loading and USB guard.
- Both adapters passed monitor transitions and bounded probe injection (29/30 replies each).
- Kali theme installer included.
