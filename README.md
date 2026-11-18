<div align="center">

# Onyx NetHunter

**POCO F7 / onyx · Unofficial · v0.2.0**

KernelSU Next · Internal & USB Wi-Fi · USB HID · Internal Bluetooth / VHCI

[![Kernel](https://img.shields.io/badge/Download-Kernel-20b981?style=for-the-badge)](https://github.com/ROHITSHARMA838888/poco-f7-nethunter/releases/download/v0.2.0/Onyx-NetHunter-v0.2.0-Kernel.zip)
[![Module](https://img.shields.io/badge/Download-KSU_Module-3b82f6?style=for-the-badge)](https://github.com/ROHITSHARMA838888/poco-f7-nethunter/releases/download/v0.2.0/Onyx-NetHunter-v0.2.0-WiFi-Bluetooth-KernelSU.zip)
[![Guide](https://img.shields.io/badge/Read-Flashing_Guide-f59e0b?style=for-the-badge)](#installation)
[![Changelog](https://img.shields.io/badge/View-Changelog-6366f1?style=for-the-badge)](https://github.com/ROHITSHARMA838888/poco-f7-nethunter/releases/tag/v0.2.0)

[Updates](https://t.me/POCO_F7_NETHUNTER) · [Discussion](https://t.me/poco_f7_discussion) · [Test photos](docs/testing/README.md)

</div>

## Compatibility

- **Device:** POCO F7 / `onyx` only.
- **Tested ROMs:** Infinity-X 4.1 and 4.2, Android 17. The latest combined Wi-Fi/Bluetooth runtime tests were on 4.2.
- **Kernel:** Linux `6.6.142-4k-g7750565ada3d-dirty`.
- Other ROMs may be compatible but are untested, including HyperOS. ROM/Android build-date allowlists are removed; compatible vendor drivers and boot layout are still required.
- Kernel Image is unchanged from the working build. This release updates the installer and the combined module; it does **not** contain the abandoned SUSFS / KernelSU Next v3.4.2 experiment.
- The revised unrestricted installer/versioned packages have passed offline checks; the exact new release ZIPs have not yet received a fresh flash test.

## Features

| Feature | Status |
| --- | --- |
| KernelSU Next | Existing working root integration |
| Internal Wi-Fi | 2.4 GHz monitor mode, probe injection and targeted deauth tested and working |
| Archer T2U Plus / TL-WN722N v2/v3 | Existing fixed drivers; monitor, injection and deauth working |
| USB stability guard | Automatic adapter handling and reconnect fixes |
| USB HID | Keyboard typing tested; gadget activation is separate |
| Internal Bluetooth / VHCI | Kali service Start creates HCI; interface UP and Stop/restore tested |
| Normal use | Wi-Fi, hotspot and earbuds audio tested on the guarded internal driver |
| Visuals | Blue Glitch boot animation and wallpaper collection installer |

Bluetooth discovery/SDP were tested previously; Bluetooth HID pairing remains unresolved. VHCI does not mean every Bluetooth attack is supported. NetHunter APKs and the Kali chroot are **not included**. Root/integrity detection by banking apps remains unresolved.

## Installation

Back up your current **Boot** partition, keep recovery available and unplug OTG adapters. Keep the bootloader unlocked. Stop active monitor and Kali Bluetooth sessions before updating/rebooting.

### 1. Kernel ZIP — OrangeFox recovery

1. Download **`Onyx-NetHunter-v0.2.0-Kernel.zip`**.
2. Reboot to **OrangeFox** (tested recovery: unofficial R12).
3. Select **Install → kernel ZIP → Flash**.
4. Reboot to Android and confirm KernelSU Next root works.

Already running the exact matching kernel? You can keep it and update only the module. The newer animation/wallpaper installer requires the newer kernel ZIP; module-only updates do not replace these visuals.

### 2. Combined module — KernelSU Next Manager

1. Stop internal monitor mode and Kali Bluetooth. Turn hotspot off for initial activation.
2. Open **KernelSU Next → Modules → Install**.
3. Select **`Onyx-NetHunter-v0.2.0-WiFi-Bluetooth-KernelSU.zip`**.
4. Reboot, unlock and allow about **90 seconds** for startup checks.
5. Connect one USB adapter at a time if needed.

This updates the same `onyx_verified_wifi` module. A known separate `onyx_internal_bluetooth` companion is backed up and disabled to avoid duplicate loaders. No new kernel recompile is needed for these module features.

**Kernel ZIP goes in recovery. Module ZIP goes in KernelSU Next. No data wipe is needed.** If installation fails, save the log and stop. Do not relock the bootloader on this custom setup or flash unrelated `vbmeta`/vendor partitions.

## Commands

### Internal Wi-Fi — Kali root terminal

```sh
uname -r
airmon-ng start wlan0 6
iw dev wlan0 info
# When finished, always restore normal Wi-Fi before rebooting:
airmon-ng stop wlan0
```

The interface remains `wlan0`. Internal helper channels are **1–11**; replace `6` with your test network's channel. Turn phone hotspot off first. For USB adapters, identify their interface with `airmon-ng`; do not assume `wlan0` is the USB adapter.

### Internal Bluetooth — Kali root terminal

Turn **Android Bluetooth OFF**, open Kali, then:

```sh
service bluetooth start
hciconfig -a
hciconfig hci0 up
# Finish before enabling Android Bluetooth / using earbuds:
service bluetooth stop
```

Start automatically opens the bridge; no manual `insmod` is needed. The HCI number can vary—use the one shown by `hciconfig -a`. Do not enable Android Bluetooth during the Kali session. The bridge has a 30-minute session limit.

Use radio/HID tests only with your own devices and permission. [Additional test guidance](docs/TESTING.md).

## Troubleshooting / rollback

- **No HCI:** Android Bluetooth OFF, Kali open, run `service bluetooth start` and save its full error.
- **Internal driver unavailable:** stop monitor mode before reboot. The loader stops safely if a session, unsupported driver or incomplete prior startup is detected; report the log instead of forcing a load.
- **Adapter disconnect/reboot:** remove OTG and stop testing.
- **Module problem:** disable `onyx_verified_wifi` in KernelSU and reboot without adapters. This restores the ROM internal driver; it does not replace your kernel or remove installed visuals.
- **Phone cannot boot:** use recovery to restore your own pre-flash Boot backup to the original slot.

[Source, patches and licences](SOURCE.md) · [Full changelog](CHANGELOG.md)
