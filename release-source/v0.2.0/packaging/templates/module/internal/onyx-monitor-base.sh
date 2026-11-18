#!/system/bin/sh
# POCO F7 WCN7750: temporary passive monitor session, no boot hooks.
P=/sys/module/qca_cld3_wcn7750/parameters/con_mode
S=/data/adb/onyx-monitor-session
SELF=/data/adb/modules/onyx_verified_wifi/internal/onyx-monitor.sh
fail() { echo "ERROR: $*" >&2; exit 1; }
[ "$(id -u)" = 0 ] || fail 'Run using su -c.'
[ -f "$P" ] || fail 'Expected WCN7750 driver is absent.'
stop_session() {
 [ -d "$S" ] || { echo 'No helper session active.'; return 0; }
 timeout 15 sh -c "echo 0 > $P" || return 1
 [ "$(cat "$P")" = 0 ] || return 1
 if [ "$(cat "$S/wifi")" = 1 ]; then svc wifi enable || return 1; fi
 rm -f "$S/token" "$S/wifi" "$S/watchdog.log" "$S/ready"
 rmdir "$S" 2>/dev/null
 echo 'Normal driver mode restored.'
}
case "$1" in
 status)
  echo "Driver mode: $(cat "$P") (0=normal, 4=monitor)"
  iw dev wlan0 info
  [ ! -d "$S" ] || echo 'Helper session active; stop with airmon-ng stop wlan0.'
  ;;
 stop) stop_session || fail 'Restore failed; keep USB connected and report this error.' ;;
 _expire)
  [ -f "$S/token" ] && [ "$(cat "$S/token")" = "$2" ] && [ ! -f "$S/ready" ] && stop_session
  ;;
 start)
  CH=${2:-6}
  case "$CH" in 1|2|3|4|5|6|7|8|9|10|11) ;; *) fail 'Use a 2.4 GHz channel from 1 to 11.' ;; esac
  [ ! -d "$S" ] || fail 'Existing session: run stop first.'
  [ "$(cat "$P")" = 0 ] || fail 'Driver is already in another mode.'
  iw dev | grep -q 'type AP' && fail 'Turn phone hotspot OFF first.'
  WIFI=$(settings get global wifi_on)
  case "$WIFI" in 0|1) ;; *) fail 'Cannot determine original Wi-Fi setting.' ;; esac
  mkdir -m 700 "$S" || fail 'Cannot create session state.'
  echo "$WIFI" > "$S/wifi"
  TOKEN=$(cat /proc/sys/kernel/random/uuid)
  echo "$TOKEN" > "$S/token"
  trap 'stop_session' EXIT INT TERM
  nohup sh -c 'sleep 60; sh "$1" _expire "$2"' sh "$SELF" "$TOKEN" </dev/null >"$S/watchdog.log" 2>&1 &
  cmd wifi set-wifi-enabled disabled || exit 1
  sleep 3
  timeout 15 sh -c "echo 4 > $P" || exit 1
  [ "$(cat "$P")" = 4 ] || exit 1
  ip link set wlan0 up || exit 1
  iw dev wlan0 set channel "$CH" || exit 1
  [ "$(cat /sys/class/net/wlan0/type)" = 803 ] || exit 1
  iw dev wlan0 info | grep -q 'type monitor' || exit 1
  touch "$S/ready" || exit 1
  trap - EXIT INT TERM
  echo "Monitor enabled on wlan0, channel $CH. Stop using airmon-ng stop wlan0."
  echo "Stop: su -c 'sh $SELF stop'"
  ;;
 *) echo "Usage: su -c 'sh $SELF start [channel 1-11] | stop | status'" ;;
esac
