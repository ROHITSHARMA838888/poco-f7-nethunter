#!/system/bin/sh
D=${0%/*}
if [ -d /data/adb/onyx_internal_bluetooth/session ]; then /system/bin/sh "$D/ctl.sh" stop; else /system/bin/sh "$D/ctl.sh" start; fi
