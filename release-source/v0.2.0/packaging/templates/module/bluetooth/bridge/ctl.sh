#!/system/bin/sh
set -eu
D=${0%/*}
S=/data/adb/onyx_internal_bluetooth
[ "$(id -u)" = 0 ] || exit 2
case "${1:-status}" in
 start)
 mkdir -p "$S"
 if [ -d "$S/session" ]; then
   p=$(cat "$S/session/pid" 2>/dev/null || true)
   case "$p" in ''|*[!0-9]*) echo 'Invalid session state; inspect before retry'; exit 2;; esac
   cmd=$(tr '\000' ' ' < "/proc/$p/cmdline" 2>/dev/null || true)
   case "$cmd" in *"$D/session-supervisor"*)
    [ -n "$(ls /sys/class/bluetooth 2>/dev/null)" ] && { echo 'READY: session already running'; exit 0; };; esac
   echo 'Session/state already exists; stop first'; exit 2
 fi
 nohup /system/bin/sh "$D/run.sh" > "$S/session.log" 2>&1 < /dev/null &
 p=$!
 for tick in $(seq 1 35); do
  if grep -q 'Successfully initialized vhci bluetooth' "$S/session.log" && [ -n "$(ls /sys/class/bluetooth 2>/dev/null)" ]; then echo 'READY: use Kali hcitool/hciconfig'; exit 0; fi
  kill -0 "$p" 2>/dev/null || break
  sleep 1
 done
 kill -TERM "$p" 2>/dev/null || true
 wait "$p" 2>/dev/null || true
 tail -10 "$S/session.log"
 exit 3;;
 stop)
 /system/bin/sh "$D/hid.sh" stop
 if [ -f "$S/session/pid" ] && [ "$(cat "$S/session/boot")" = "$(cat /proc/sys/kernel/random/boot_id)" ]; then
  p=$(cat "$S/session/pid")
  case "$p" in ''|*[!0-9]*) exit 2;; esac
  cmd=$(tr '\000' ' ' < "/proc/$p/cmdline" 2>/dev/null || true)
  case "$cmd" in *"$D/session-supervisor"*|*"$D/run.sh"*) kill -TERM "$p";; *) echo 'PID ownership not verified'; exit 2;; esac
  for tick in $(seq 1 12); do [ ! -d "$S/session" ] && { echo STOPPED; exit 0; }; sleep 1; done
  echo 'Cleanup incomplete; inspect session.log'; exit 3
 fi
 /system/bin/sh "$D/cleanup.sh";;
 status) if [ -d "$S/session" ]; then echo 'Session/restore state present'; else echo OFF; fi;;
 *) echo 'Usage: ctl.sh start|stop|status'; exit 2;;
esac
