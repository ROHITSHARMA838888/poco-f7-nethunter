#!/system/bin/sh
# Use Android framework APIs; never force interface/module teardown.
set -eu
export LC_ALL=C
PAYLOAD=${0%/*}
MODDIR=${PAYLOAD%/internal/wlan}
STATE="$MODDIR/internal-wlan-state"
M=/sys/module/qca_cld3_wcn7750
framework() {
 RC=0
 OUTPUT=$(/system/bin/cmd wifi "$@" 2>&1) || RC=$?
 printf '%s\n' "$OUTPUT"
 [ "$RC" = 0 ]
}
case "${1:-}" in
 restore)
  [ -f "$STATE/scan-before" ] && [ -f "$STATE/wifi-before" ]
  case "$(cat "$STATE/scan-before")" in
   1) framework set-scan-always-available enabled;;
   0) framework set-scan-always-available disabled;;
   *) echo INVALID_SAVED_SCAN_SETTING; exit 1;;
  esac
  case "$(cat "$STATE/wifi-before")" in
   1) framework set-wifi-enabled enabled;;
   0) framework set-wifi-enabled disabled;;
   *) echo INVALID_SAVED_WIFI_SETTING; exit 1;;
  esac
  echo FRAMEWORK_USER_SETTINGS_RESTORED
  exit;;
 off) ;;
 *) exit 2;;
esac
[ -f "$STATE/scan-before" ] && [ -f "$STATE/wifi-before" ]
case "$(cat "$STATE/scan-before"):$(cat "$STATE/wifi-before")" in 0:0|0:1|1:0|1:1) ;; *) exit 1;; esac
trap 'rc=$?; if [ "$rc" != 0 ]; then /system/bin/sh "$PAYLOAD/quiesce.sh" restore || echo USER_SETTING_RESTORE_FAILED; fi' EXIT
iw dev > "$STATE/iw-before-quiesce.log"
! grep -q 'type AP' "$STATE/iw-before-quiesce.log" || { echo HOTSPOT_ACTIVE_NO_QUIESCE; exit 1; }
framework set-scan-always-available disabled
framework set-wifi-enabled disabled
count=0; stable=0
while [ "$stable" -lt 3 ]; do
 RC=0
 STATUS=$(/system/bin/cmd wifi status 2>&1) || RC=$?
 printf '%s\n' "$STATUS" > "$STATE/framework-off-status.log"
 SCAN=$(/system/bin/cmd settings get global wifi_scan_always_enabled 2>&1)
 WIFI=$(/system/bin/cmd settings get global wifi_on 2>&1)
 QUIET=1
 [ "$RC" = 0 ] && [ "$SCAN" = 0 ] && [ "$WIFI" = 0 ] || QUIET=0
 printf '%s\n' "$STATUS" | grep -q 'Wifi is disabled' || QUIET=0
 if printf '%s\n' "$STATUS" | grep -q 'ClientModeManager instance:'; then QUIET=0; fi
 for NAME in wlan0 wlan1 p2p0 wifi-aware0; do
  if [ -r "/sys/class/net/$NAME/flags" ]; then
   FLAGS=$(cat "/sys/class/net/$NAME/flags")
   [ "$((FLAGS & 1))" = 0 ] || QUIET=0
  fi
 done
 if [ -d "$M" ]; then
  REF=$(cat "$M/refcnt"); INIT=$(cat "$M/initstate")
  [ "$REF" = 0 ] && [ "$INIT" = live ] || QUIET=0
 else
  REF=absent; INIT=absent
 fi
 echo "QUIESCE sample=$count quiet=$QUIET scan=$SCAN wifi=$WIFI ref=$REF init=$INIT"
 if [ "$QUIET" = 1 ]; then stable=$((stable + 1)); else stable=0; fi
 count=$((count + 1)); [ "$count" -le 25 ] || { echo FRAMEWORK_NOT_QUIESCENT_NO_UNLOAD; exit 1; }
 [ "$stable" -ge 3 ] || sleep 1
done
iw dev > "$STATE/iw-quiescent.log"
trap - EXIT
echo FRAMEWORK_AND_INTERNAL_INTERFACES_QUIESCENT
