#!/system/bin/sh
S=/data/adb/onyx_internal_bluetooth
rm -f "$S/hid.pid" "$S/hid.target"
echo HID_STOPPED
