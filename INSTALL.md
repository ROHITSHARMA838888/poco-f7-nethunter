# Install and rollback — v0.1.2

Only the exact tested POCOF7/onyx Infinity-X4.1 Android17 build is supported (incremental1792766195, SDK37, patch2026-10-01). Installer guards intentionally reject other layouts/ROMs; do not bypass them.

1. Save a known-good **current boot partition backup**, the ROM recovery method and a rollback module package before proceeding. A ROM-extracted boot image is not a backup of a modified current boot. Disconnect external USB adapters.
2. Verify both downloaded ZIP hashes against SHA256SUMS.txt.
3. In OrangeFox recovery (tested unofficialR12), back up Boot for the current slot. Choose Install and the **kernel ZIP**. Do not wipe/format data. Installer targets active-slot boot only, validates header/layout and retains existing boot metadata. It does not flash vbmeta/init_boot/vendor_boot. It also installs theme files and a one-shot wallpaper hook; this is not solely an Image copy.
4. If installation succeeds, reboot Android and unlock. On any error stop and retain the recovery log; do not repeatedly flash or switch slots blindly. Theme failure can occur after a kernel write; read the error before assuming nothing changed.
5. In **KernelSU Next Manager**, install the **WiFi ZIP**. It checks exact running kernel/device/root and package hashes. Do not flash this module in recovery or manually run its boot service. It preserves earlier private payload directories.
6. With adapters unplugged, reboot. Confirm module versionv0.1.2-dual-wifi-fix, then connect one adapter at a time. Reboot interrupts phone hotspot/internet.

The USB guard is a targeted workaround for the ROM HAL resetting the parent USB hub. It temporarily removes write bits from the hub authorized inode for exact adapter IDs, restores on unplug/exit, leaves the HAL running, and does not change USB authorization values or SELinux. It can affect reset recovery of other devices sharing that hub while the adapter is attached.

## Rollback

If Wi-Fi causes problems, remove OTG first. Disable onyx_verified_wifi in KernelSU and reboot without adapters. To restore the previous module use the previously saved v0.1.1 ZIP; its WN driver predates the current fixes and must not be treated as injection-qualified. Previous directories are retained, but disabling the module does not itself restore a different kernel or erase its files.

If Android cannot boot, use the known-working recovery/fastboot path and restore **your own verified pre-flash boot backup to its original slot**. Do not use another person's boot image, format data or flash vbmeta as a generic repair. Theme installation keeps its own backup/state; preserve that before any manual theme rollback. Current successful users do not need to flash again simply because this release is published.
