#!/system/bin/sh
set -eu
export LC_ALL=C
PAYLOAD=${0%/*}
MODDIR=${PAYLOAD%/internal/wlan}
STATE="$MODDIR/internal-wlan-state"
RESTORE_LOCK=/dev/onyx-internal-wlan-restore.lock
M=/sys/module/qca_cld3_wcn7750
mkdir "$RESTORE_LOCK" 2>/dev/null || exit 0
trap 'rmdir "$RESTORE_LOCK" 2>/dev/null || true' EXIT
iw dev > "$STATE/iw-rollback.log"
if grep -q 'type AP' "$STATE/iw-rollback.log"; then
 echo HOTSPOT_ACTIVE_REBOOT_TO_RETURN_TO_STOCK
 exit 1
fi
if [ -d /data/adb/onyx-monitor-session ]; then
 timeout 20 /system/bin/sh /data/adb/modules/onyx_verified_wifi/internal/onyx-monitor.sh stop || exit 1
fi
/system/bin/sh "$PAYLOAD/quiesce.sh" off || exit 1
if [ -e "$M/parameters/injection_dp_inflight_limit" ]; then
 attempt=0
 while [ -d "$M" ]; do
  attempt=$((attempt + 1))
  [ "$attempt" -le 3 ] || { echo UNLOAD_RETRY_LIMIT_REACHED; exit 1; }
  [ -e "$M/parameters/injection_dp_inflight_limit" ] || { echo MODULE_IDENTITY_CHANGED; exit 1; }
  count=0; stable=0
  while [ "$stable" -lt 3 ]; do
   [ -d "$M" ] && [ -e "$M/parameters/injection_dp_inflight_limit" ] || exit 1
   REF=$(cat "$M/refcnt"); INIT=$(cat "$M/initstate")
   echo "UNLOAD_IDLE attempt=$attempt refcnt=$REF init=$INIT"
   if [ "$REF" = 0 ] && [ "$INIT" = live ]; then stable=$((stable + 1)); else stable=0; fi
   count=$((count + 1)); [ "$count" -le 15 ] || { echo MODULE_DID_NOT_SETTLE; exit 1; }
   [ "$stable" -ge 3 ] || sleep 1
  done
  RC=0
  OUTPUT=$(timeout 10 /system/bin/rmmod qca_cld3_wcn7750 2>&1) || RC=$?
  echo "UNLOAD_RESULT attempt=$attempt rc=$RC $OUTPUT"
  [ "$RC" = 0 ] && break
  [ "$RC" != 124 ] && [ "$RC" != 137 ] || { echo UNLOAD_TIMED_OUT_NO_RETRY; exit 1; }
  case "$OUTPUT" in
   *'Try again'*|*'Resource temporarily unavailable'*|*'Device or resource busy'*|*'is in use'*)
    [ "$attempt" -lt 3 ] || exit 1
    sleep 2;;
   *) echo UNLOAD_UNEXPECTED_ERROR_NO_RETRY; exit 1;;
  esac
 done
fi
if [ ! -d "$M" ]; then
 timeout 15 /system/bin/insmod /vendor_dlkm/lib/modules/qca_cld3_wcn7750.ko || exit 1
fi
[ ! -e "$M/parameters/injection_dp_inflight_limit" ] || exit 1
/system/bin/sh "$PAYLOAD/quiesce.sh" restore || exit 1

touch "$STATE/restored"
echo STOCK_RESTORED
