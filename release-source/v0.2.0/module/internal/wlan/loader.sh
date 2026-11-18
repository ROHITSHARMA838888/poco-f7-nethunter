#!/system/bin/sh
# Daily internal WLAN loader with a per-boot journal and fail-closed recovery.
set -eu
export LC_ALL=C
PAYLOAD=${0%/*}
MODDIR=${PAYLOAD%/internal/wlan}
STATE="$MODDIR/internal-wlan-state"
BOOT_ID=$(cat /proc/sys/kernel/random/boot_id)
LOCK=/dev/onyx-internal-wlan-load.lock
M=/sys/module/qca_cld3_wcn7750
umask 077
mkdir -p "$STATE"
exec >> "$STATE/boot.log" 2>&1
if [ "${1:-}" = watchdog ]; then
 sleep 75
 [ -f "$STATE/ready" ] && [ "$(cat "$STATE/ready")" = "$BOOT_ID" ] || /system/bin/sh "$PAYLOAD/rollback.sh"
 exit
fi
if [ "${1:-}" = healthy ]; then
 sleep 60
 [ "$(cat /proc/sys/kernel/random/boot_id)" = "$BOOT_ID" ] || exit 0
 [ ! -f "$MODDIR/disable" ] && [ ! -f "$MODDIR/remove" ] || exit 0
 [ "$(cat "$STATE/ready" 2>/dev/null)" = "$BOOT_ID" ] || exit 0
 [ -e "$M/parameters/injection_dp_inflight_limit" ] || exit 0
 echo "$BOOT_ID" > "$STATE/healthy"
 echo STARTUP_HEALTH_WINDOW_PASSED
 exit 0
fi
mkdir "$LOCK" 2>/dev/null || { echo LOADER_ALREADY_RUNNING; exit 0; }
echo "START $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
STEP=initial
stage() { STEP=$1; echo "STEP=$STEP"; }
fail() { echo "FAIL STEP=$STEP REASON=$*"; exit 1; }
trap 'rc=$?; rmdir "$LOCK" 2>/dev/null || true; echo "EXIT=$rc STEP=$STEP"' EXIT
stage module_enabled
[ ! -f "$MODDIR/disable" ] && [ ! -f "$MODDIR/remove" ] || exit 0
[ ! -f "$STATE/suspended" ] || { echo SUSPENDED_AFTER_INCOMPLETE_PREVIOUS_START; exit 1; }
if [ -f "$STATE/attempted" ]; then
 PREVIOUS=$(cat "$STATE/attempted")
 [ "$PREVIOUS" != "$BOOT_ID" ] || { echo ALREADY_ATTEMPTED_THIS_BOOT; exit 0; }
 if [ "$(cat "$STATE/healthy" 2>/dev/null)" != "$PREVIOUS" ]; then
  echo "$PREVIOUS" > "$STATE/suspended"
  echo PREVIOUS_START_NOT_HEALTHY_KEEP_ROM_DRIVER
  exit 1
 fi
fi
stage kernel
[ "$(uname -r)" = 6.6.142-4k-g7750565ada3d-dirty ] || fail kernel_mismatch
cd "$MODDIR"
stage runtime_integrity
sha256sum -c GUARD_SHA256SUMS || fail checksum
stage android_boot_ready
count=0
while [ "$(getprop sys.boot_completed)" != 1 ]; do
 count=$((count + 1)); [ "$count" -lt 90 ] || fail boot_not_completed
 sleep 2
done
[ ! -f "$MODDIR/disable" ] && [ ! -f "$MODDIR/remove" ] || exit 0
stage stock_driver_ready
[ -d "$M" ] && [ "$(cat "$M/parameters/con_mode")" = 0 ] || fail stock_driver_not_normal
[ ! -e "$M/parameters/injection_dp_inflight_limit" ] || { echo OTHER_EXPERIMENT_ACTIVE_SKIPPED; exit 1; }
[ ! -d /data/adb/onyx-monitor-session ] || fail monitor_session_exists
stage hotspot_check
iw dev > "$STATE/iw-before.log" || fail iw_query
! grep -q 'type AP' "$STATE/iw-before.log" || { echo HOTSPOT_ACTIVE_SKIPPED_NO_RADIO_CHANGE; exit 0; }
stage stock_driver_hash
HASH=$(sha256sum /vendor_dlkm/lib/modules/qca_cld3_wcn7750.ko 2>&1) || fail stock_hash_read
HASH=${HASH%% *}
echo "STOCK_HASH=$HASH"
[ "$HASH" = 9b2015268a09c97bf4b44cd9f6966b90ab92d8c2d3df53139b170b8d1a4c1fde ] || fail stock_hash_mismatch
stage wifi_user_state_ready
count=0
while :; do
 RC=0
 WIFI=$(/system/bin/cmd settings get global wifi_on 2>&1) || RC=$?
 echo "WIFI_READ_RC=$RC VALUE=<$WIFI>"
 case "$RC:$WIFI" in 0:0|0:1) break;; esac
 count=$((count + 1)); [ "$count" -lt 30 ] || fail invalid_wifi_state
 sleep 2
done
stage scan_user_state_ready
RC=0
SCAN=$(/system/bin/cmd settings get global wifi_scan_always_enabled 2>&1) || RC=$?
echo "SCAN_READ_RC=$RC VALUE=<$SCAN>"
case "$RC:$SCAN" in 0:0|0:1) ;; *) fail invalid_scan_setting;; esac
if [ "${1:-}" = diagnose ]; then echo READONLY_PREFLIGHT_PASS_NO_DRIVER_CHANGE; exit 0; fi
stage record_attempt
echo "$WIFI" > "$STATE/wifi-before"
echo "$SCAN" > "$STATE/scan-before"
cat /proc/sys/kernel/random/boot_id > "$STATE/boot-id"
dmesg > "$STATE/dmesg-before.log"
echo "$BOOT_ID" > "$STATE/attempted"
trap 'rc=$?; echo "EXIT=$rc STEP=$STEP ROLLBACK_REQUESTED"; /system/bin/sh "$PAYLOAD/rollback.sh"; rmdir "$LOCK" 2>/dev/null || true' EXIT
trap 'exit 130' INT TERM HUP
nohup /system/bin/sh "$PAYLOAD/loader.sh" watchdog </dev/null > "$STATE/watchdog.log" 2>&1 &
stage quiesce_framework_and_scans
/system/bin/sh "$PAYLOAD/quiesce.sh" off || fail framework_quiesce
stage unload_stock
if [ -d "$M" ]; then
 timeout 15 /system/bin/rmmod qca_cld3_wcn7750 || fail unload_stock
else
 echo FRAMEWORK_ALREADY_UNLOADED_STOCK
fi
stage load_candidate
timeout 15 /system/bin/insmod "$PAYLOAD/qca_cld3_wcn7750.ko" con_mode=0 injection_dp_inflight_limit=1 || fail load_candidate
[ "$(cat "$M/parameters/injection_dp_inflight_limit")" = 1 ]
[ "$(cat "$M/parameters/con_mode")" = 0 ]
stage restore_user_radio_settings
/system/bin/sh "$PAYLOAD/quiesce.sh" restore || fail restore_user_settings

dmesg > "$STATE/dmesg-after.log"
echo "$BOOT_ID" > "$STATE/ready"
rmdir "$LOCK"
trap - EXIT INT TERM HUP
nohup /system/bin/sh "$PAYLOAD/loader.sh" healthy </dev/null > "$STATE/healthy.log" 2>&1 &
echo GUARDED_DRIVER_READY_FOR_CURRENT_BOOT
