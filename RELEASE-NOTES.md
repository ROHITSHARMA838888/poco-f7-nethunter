# Onyx NetHunter v0.1.2 — POCO F7 / onyx (Unofficial)

Built by Rohit Sharma (@hcclubb). **Tested only on Infinity-X4.1 Android17, incremental1792766195, patch2026-10-01.** Linux6.6.142; exact runtime6.6.142-4k-g7750565ada3d-dirty. Other ROMs/updates are not verified; installer guards must not be bypassed.

## Packages

- **Kernel ZIP:** OrangeFox recovery installer, KernelSU Next, HID configuration, Kali boot animation/wallpaper. Historical `test` filename is retained because these are the exact device-tested bytes.
- **WiFi ZIP:** install through KernelSU Next Manager after the matching kernel, then reboot with adapters removed. Includes both fixed external drivers and the targeted USB stability guard.
- **SHA256SUMS.txt:** verify downloads. Source pins/configuration/patches and packaging sources are linked in SOURCE.md; Source-Reconstruction-Kit is not a flashable package.

## Verified

Both Archer T2U Plus2357:0120 and WN722Nv2/v3 2357:010c passed monitor transitions and one bounded owned-hotspot probe injection test each (29/30 replies). Both fixed drivers auto-load after reboot, both postboot attachment tests passed, USB guard restores hub permissions on unplug, and WN LED works. Final bounded WN tests showed no new kernel warning. KernelSU root works; HID keyboard enumeration passed (keystroke transmission untested).

Callback type repairs preserve KCFI/KASAN. WN monitor disconnect now accepts the valid monitor state without hiding warnings for unknown states. No kernel recompile was required for these external-driver fixes.

## Limits

This is an unofficial community build, not an official Kali release. Not long-term/all-frame/all-ROM qualification. Deauth/MDK and internal Wi-Fi capture/injection are **untested**. WN722Nv1 is excluded from the module. Kali chroot/apps are separate. Keep your own boot backup and read INSTALL.md for exact requirements and rollback. Old Konoha6.6.143 Actions artifacts are incompatible with the tested ROM and are not this release.

Sources/credits: xiaomi-onyx-playground kernel, KernelSU Next, aircrack-ng/Realtek, osm0sis AnyKernel3, topjohnwu Magisk utilities, Kali NetHunter artwork contributors. Full source links/pins/patches and original licences are included in the repository/source kit.

Updates: https://t.me/POCO_F7_NETHUNTER
Discussion: https://t.me/poco_f7_discussion
