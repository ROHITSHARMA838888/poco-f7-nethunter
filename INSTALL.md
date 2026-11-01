# Simple flashing guide — Onyx NetHunter v0.1.2

> **Check first:** Only POCO F7 / onyx running the tested Infinity-X 4.1 Android 17 build: incremental `1792766195`, SDK `37`, patch `2026-10-01`. Other ROMs/updates are not verified. An unlocked bootloader, working recovery and your own current Boot backup are required. Do not bypass installer checks.

Download both ZIPs from [the release](https://github.com/ROHITSHARMA838888/poco-f7-nethunter/releases/tag/v0.1.2), verify their hashes using `SHA256SUMS.txt`, and unplug all external adapters/OTG.

## 1. Kernel ZIP → OrangeFox recovery

1. Copy `Onyx-NetHunter-v0.1.2-test.zip` to the phone.
2. Reboot into **OrangeFox** (tested: unofficial R12).
3. Open **Backup → Boot**. Back up the currently active slot and keep the backup somewhere accessible if Android cannot boot.
4. Open **Install → select the kernel ZIP → Swipe to flash**.
5. If successful, tap **Reboot System** and unlock Android.

## 2. Wi-Fi ZIP → KernelSU Next Manager

1. Open **KernelSU Next Manager** and confirm root works.
2. Open **Modules → Install**.
3. Choose `Onyx-NetHunter-WiFi-v0.1.2-KernelSU.zip`.
4. After successful installation, reboot **with adapters unplugged**.
5. Unlock Android, wait about **30 seconds**, and connect one adapter at a time.

## Important

- **No data wipe or format is needed.** Kernel ZIP is for recovery; Wi-Fi ZIP is for KernelSU.
- Do not flash `vbmeta`, `init_boot` or `vendor_boot`, bypass checks, manually run the module service or force-load mismatched drivers.
- If installation fails, stop and save the log. Theme installation can fail **after the kernel write**; do not assume nothing changed or repeatedly flash.
- Reboot interrupts the phone hotspot. If attaching an adapter causes reboot/reset loops, remove OTG and stop testing.
- The kernel installer also installs Kali boot animation/wallpaper files and a one-shot wallpaper hook; wallpaper waits for Android/owner unlock. Kali apps/chroot are separate.
- If the current kernel and module are already working, do not reflash just because a release was published.

## If something goes wrong

- **Android boots, module causes trouble:** unplug OTG, disable `onyx_verified_wifi` in KernelSU and reboot. An earlier module can be restored from your saved ZIP, but v0.1.1's WN driver predates these fixes and is not injection-qualified.
- **Android does not boot:** use your known-working recovery/fastboot method to restore **your own pre-flash Boot backup to its original slot**. Do not use someone else's boot image or format data as a generic repair.
- **Theme problem:** preserve the recovery log and theme backup/state. Disabling the Wi-Fi module does not restore the kernel or theme files.

## USB guard note

The Wi-Fi module includes a targeted workaround for the ROM USB HAL resetting the adapter's parent hub. For the supported USB IDs, it temporarily removes write bits from the hub's `authorized` inode and restores the original mode on unplug/exit. It leaves the HAL running and does not change USB authorization values, roles or SELinux. Other devices sharing that hub can have reset recovery affected while an adapter is attached.

[Full tested setup, checksums and limitations](README.md)
