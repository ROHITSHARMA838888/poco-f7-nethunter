# Onyx NetHunter â€” POCO F7 (Unofficial)

By **Rohit Sharma / [@hcclubb](https://t.me/hcclubb)**. An independent community kernel build, not an official Kali release.

## Supported setup

**POCO F7 / onyx â€” Infinity-X 4.1, Android 17**, ROM incremental `1792766195`, SDK37, security patch `2026-10-01`. Recovery installer enforces these identifiers. Other ROMs, devices and ROM updates are **not verified**. An unlocked bootloader and a known-good boot backup/recovery path are required.

Current base is [xiaomi-onyx-playground/android_kernel_xiaomi_sm8735](https://github.com/xiaomi-onyx-playground/android_kernel_xiaomi_sm8735/tree/7750565ada3d57e195798519b005d2b038e888c1), **Linux6.6.142**, runtime release `6.6.142-4k-g7750565ada3d-dirty`. The repository is named `poco-f7-nethunter`; the released kernel is **not Konoha-based**.

## v0.1.2: what was tested

| Feature | Evidence / limits |
| --- | --- |
| KernelSU Next | Real pinned source integrated; phone boots and root works |
| Archer T2U Plus, USB2357:0120 | Managed/monitor transitions, monitor-UP and one owned-hotspot probe injection test:29/30 replies |
| TL-WN722N v2/v3, USB2357:010c | Same probe result29/30; LED confirmed; monitor disconnect warning fixed |
| Persistent Wi-Fi module | Both fixed drivers auto-load after reboot; postboot attachment and USB guard restore checked |
| USB HID | Windows HID keyboard enumeration passed; no keystroke transmission qualification |
| Theme | Kali boot animation and wallpaper installer included |

No reboot or new adapter-test kernel warning was observed in the final bounded Wi-Fi tests. These results do not establish long-term stability, every frame type, every hardware revision or cross-ROM compatibility. **Deauthentication/MDK operation is untested. Internal Wi-Fi capture/injection is untested.** Kali apps/chroot are not bundled in the kernel ZIP. WN722N v1 is excluded from this Wi-Fi module.

## Downloads and installation

Use [GitHub Releases](../../releases) and verify `SHA256SUMS.txt`. There are two different packages:

- `Onyx-NetHunter-v0.1.2-test.zip`: OrangeFox recovery kernel installer. The historical `test` filename is retained to preserve the exact tested bytes.
- `Onyx-NetHunter-WiFi-v0.1.2-KernelSU.zip`: service-only KernelSU module for external adapters, not a recovery-flashable ZIP.

Read [INSTALL.md](INSTALL.md) before flashing. **Do not flash old6.6.143 Konoha CI artifacts or raw Image/.ko outputs.** Old Actions runs are development evidence, not release downloads.

## Sources and credits

See [SOURCE.md](SOURCE.md), [CREDITS.txt](CREDITS.txt), the exact source pins, matching configuration and patches under `release-source/v0.1.2/`. Original licences and authorship are retained.

- [Kernel base](https://github.com/xiaomi-onyx-playground/android_kernel_xiaomi_sm8735)
- [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next)
- [aircrack-ng RTL8812AU](https://github.com/aircrack-ng/rtl8812au) / [RTL8188EUS](https://github.com/aircrack-ng/rtl8188eus)
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3), [Magisk utilities](https://github.com/topjohnwu/Magisk), and Kali NetHunter artwork contributors

## Community

[Updates](https://t.me/POCO_F7_NETHUNTER) Â· [Discussion](https://t.me/poco_f7_discussion)

For bugs include ROM incremental/security patch, kernel and module versions, adapter model/USBID and steps. Remove personal data from logs. Keep upstream acknowledgements when redistributing.
