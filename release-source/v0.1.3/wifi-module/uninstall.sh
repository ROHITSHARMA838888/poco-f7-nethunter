#!/system/bin/sh
MODDIR=${0%/*}
/system/bin/sh "$MODDIR/uninstall-monitor.sh" || exit 1
# Stop only this module's guard; its inode restore child handles cleanup.
STATE=/data/adb/onyx-drivers-41316130882-v012
GUARD=/data/adb/modules/onyx_verified_wifi/bin/usb-auth-guard
[ -f "$STATE/usb-auth-guard.pid" ] || exit 0
pid=$(cat "$STATE/usb-auth-guard.pid")
case "$pid" in ''|*[!0-9]*) exit 0;; esac
[ -r "/proc/$pid/cmdline" ] || exit 0
program=$(tr '\000' '\n' < "/proc/$pid/cmdline" | head -n 1)
mode=$(tr '\000' '\n' < "/proc/$pid/cmdline" | sed -n '2p')
[ "$program" = "$GUARD" ] && [ "$mode" = --run ] || exit 0
kill -TERM "$pid"
