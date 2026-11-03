#!/system/bin/sh
# Installed by KernelSU Next Manager / ksud, not OrangeFox.
ui_print 'Onyx NetHunter Wi-Fi | by Rohit Sharma'
ui_print 'KernelSU module v0.1.3 | Archer + WN722N v2/v3'
ui_print 'Thanks: aircrack-ng / Realtek driver contributors'
ui_print 'Kernel: xiaomi-onyx-playground | Root: KernelSU Next'
ui_print 'Full source links and acknowledgements: CREDITS.txt'
[ "$BOOTMODE" = true ] || abort 'Install this module from KernelSU Next in Android.'
[ "$(id -u)" = 0 ] || abort 'Root is required.'
[ "$(getprop ro.product.device)" = onyx ] || abort 'Only Poco F7 / onyx is supported.'
[ "$(uname -r)" = 6.6.142-4k-g7750565ada3d-dirty ] || abort 'Matching installed kernel is required.'
[ -x /data/adb/ksud ] || abort 'KernelSU Next daemon was not found.'
cd "$MODPATH" || abort 'Missing module directory.'
sha256sum -c PACKAGE_SHA256SUMS || abort 'Module package integrity check failed.'
STATE=/data/adb/onyx-drivers-41316130882-v012
mkdir -p "$STATE" || abort 'Cannot prepare private driver directory.'
chmod 700 "$STATE"
for driver in 88XXau 8188eu; do
  if [ -e "$STATE/$driver.ko" ]; then
    old=$(sha256sum "$STATE/$driver.ko" | cut -d' ' -f1)
    new=$(sha256sum "$MODPATH/drivers/$driver.ko" | cut -d' ' -f1)
    [ "$old" = "$new" ] || abort 'Existing private driver differs; review before replacing it.'
  fi
done
for driver in 88XXau 8188eu; do cp "$MODPATH/drivers/$driver.ko" "$STATE/$driver.ko" || abort 'Driver copy failed.'; done
cp "$MODPATH/payload/load-drivers.sh" "$STATE/load-drivers.sh" || abort 'Loader copy failed.'
cp "$MODPATH/payload/SHA256SUMS" "$STATE/SHA256SUMS" || abort 'Checksum copy failed.'
chmod 600 "$STATE/88XXau.ko" "$STATE/8188eu.ko" "$STATE/load-drivers.sh" "$STATE/SHA256SUMS"
chmod 755 "$MODPATH/service.sh" "$MODPATH/uninstall.sh" "$MODPATH/bin/usb-auth-guard"
LEGACY=/data/adb/modules/nethunter_wireless_drivers
if [ -d "$LEGACY" ] && [ ! -e "$LEGACY/disable" ]; then
  BACKUP=/data/adb/onyx-driver-backups
  mkdir -p "$BACKUP" || abort 'Cannot prepare legacy backup.'
  chmod 700 "$BACKUP"
  if [ ! -e "$BACKUP/nethunter_wireless_drivers-before-autoload.tar" ]; then
    tar -C /data/adb/modules -cf "$BACKUP/nethunter_wireless_drivers-before-autoload.tar" nethunter_wireless_drivers || abort 'Legacy backup failed.'
    chmod 600 "$BACKUP/nethunter_wireless_drivers-before-autoload.tar"
  fi
  touch "$LEGACY/disable" || abort 'Cannot prevent duplicate legacy loader.'
fi
ui_print '- Matching Realtek drivers and USB guard prepared.'
ui_print '- USB HAL stays running; hub permissions restore on unplug/exit.'
ui_print '- Reboot to activate. No kernel partition or ROM file changed.'

chmod 755 "$MODPATH/action.sh" "$MODPATH/uninstall-monitor.sh" "$MODPATH/internal/onyx-monitor.sh" "$MODPATH/internal/airmon-ng"
ui_print "- Internal monitor: after reboot, open Kali then tap module Action if needed."
ui_print "- Existing kernel users: module update only; no kernel reflash."
