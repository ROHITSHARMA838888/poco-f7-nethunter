#!/system/bin/sh
# File integration only; never enables monitor or changes network state.
MODDIR=${0%/*}
LOG=/data/adb/onyx-monitor-install.log
while [ -d "$MODDIR" ] && [ ! -f "$MODDIR/disable" ] && [ ! -f "$MODDIR/remove" ]; do
 /system/bin/sh "$MODDIR/install-monitor.sh" >>"$LOG" 2>&1
 sleep 20
done
