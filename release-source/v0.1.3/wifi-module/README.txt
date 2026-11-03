Service-only KernelSU module. No system/ overlay or metamodule is required.
The KernelSU installer creates the verified private payload at
/data/adb/onyx-drivers-41316130882-v012 from the drivers included in this ZIP.
Only 88XXau and 8188eu are loaded, and only on the matching kernel.
WN722N v1/Atheros is excluded. Both actual adapters passed USB binding/stability
tests; network traffic, monitor/injection and HID operation are separate tests.

The guard listens for kernel USB events. Only while USB IDs 2357:0120 or
2357:010c are present, it removes write bits from their parent hub's authorized
inode so the ROM HAL cannot falsely reset the hub. HAL stays running. The
original inode mode returns on unplug, SIGTERM or helper crash; an independent
restore child holds the original inode, never a reused pathname. No ROM file,
USB authorization value, UID/GID, USB role or SELinux policy is changed.
Other devices sharing that hub can have reset recovery affected while a target
adapter is present. A proper HAL source fix would replace this workaround.

Version v0.1.2: Archer fix from run41297489306; WN722N callback, monitor-state
and LED fixes from run41316130882.
CFI/KCFI and KASAN remain enabled. Kernel Image is unchanged.
Both adapters: attach, monitor DOWN/UP transitions and one bounded probe injection test each
passed on the author's phone (29/30 directed replies, no reboot). This is not
long-term stability or all-ROM qualification. WN722N LED operation was confirmed
and no new kernel warnings were found in its final monitor and probe tests.

Install ONLY using KernelSU Next Manager on the exact matching onyx kernel.
Updating the same module ID takes effect after reboot; do not manually run its
service while the previous guard is running. Remove external adapters before
reboot. The original private payload remains at /data/adb/onyx-drivers-40863319425.
To roll back, reinstall the saved v0.1.1 module ZIP in KernelSU and reboot with
adapters disconnected. Do not enable an unrelated or absent legacy module.
Disable this module in KernelSU to stop its next-boot autoload. Keep a known-good
boot backup and recovery access. No boot partition is written by this module.

UPDATE v0.1.3 — INTERNAL MONITOR INTEGRATION
Kernel and both .ko driver binaries are unchanged. Existing v0.1.2 kernel users
update ONLY this ZIP in KernelSU Next Manager and reboot with adapters removed.
New users install the original kernel ZIP using OrangeFox and this module in
KernelSU Next Manager. Do not install this ZIP through recovery.

Integration installs automatically for existing Kali and Stryker root filesystems,
and Android root shell. No Action button or preliminary helper command.
Supported roots: /data/local/nhsystem/kali-arm64 and /data/local/stryker/release.
The boot worker also checks every 20 seconds for later installs or replacements.
Other layouts, rootless sessions and Android virtual machines are not qualified.
Hotspot OFF; run in Kali root terminal:
  airmon-ng start wlan0 6
  airodump-ng --channel 6 wlan0
  airmon-ng stop wlan0
Default channel 6, supported helper input 1-11. No session time limit; stop manually.
Internal passive beacon reception is verified. Internal injection/deauth are
not qualified. Stop capture before running airmon-ng stop wlan0.
Original airmon-ng is preserved through a local dpkg diversion; uninstall
restores it if the installed wrapper has not been changed by another tool.
Kali/Stryker reinstall is detected automatically while this module is enabled.
Disabling module does not run uninstall: re-enable it or uninstall to restore
original airmon-ng. No automatic monitor activation or boot partition writes.
