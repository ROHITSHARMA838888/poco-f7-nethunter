#!/system/bin/sh
set -eu
S=/data/adb/onyx_internal_bluetooth
[ -z "$(ls /sys/class/bluetooth 2>/dev/null)" ] || { echo 'HCI still present; restore state retained'; exit 2; }
[ -f "$S/session/original_scan" ] || exit 0
old=$(cat "$S/session/original_scan")
case "$old" in 0|1) /system/bin/cmd settings put global ble_scan_always_enabled "$old";; null) /system/bin/cmd settings delete global ble_scan_always_enabled;; *) exit 3;; esac
rm -f "$S/session/original_scan" "$S/session/pid" "$S/session/boot"
rmdir "$S/session"
echo 'Bluetooth stopped; original scanning setting restored.'
