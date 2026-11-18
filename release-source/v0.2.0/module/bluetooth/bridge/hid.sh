#!/system/bin/sh
set -eu
D=${0%/*}
S=/data/adb/onyx_internal_bluetooth
R=/data/local/nhsystem/kali-arm64
case "${1:-status}" in
 start)
 target=${2:-}
 echo "$target" | grep -Eq '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$' || { echo 'Usage: hid.sh start OWN_LAPTOP_BLUETOOTH_MAC'; exit 2; }
 [ -d "$S/session" ] && [ -d /sys/class/bluetooth/hci0 ] || { echo 'Start Bluetooth session first'; exit 2; }
 [ ! -f "$S/hid.pid" ] || { echo 'HID already active/state exists'; exit 2; }
 (cd "$D" && /data/adb/ksu/bin/busybox sha256sum -c RUNTIME_SHA256SUMS) || exit 2
 T="$R/root/onyx-bluetooth-module/hid"
 mkdir -p "$T"; chmod 700 "$T"
 cp "$D"/hid/* "$T/"
 printf '%s\n' "$target" > "$S/hid.target"
 nohup "$D/session-supervisor" "$D/hid-cleanup.sh" -- /system/bin/chroot "$R" /usr/bin/env ONYX_HID_TARGET="$target" /usr/bin/python3 -u /root/onyx-bluetooth-module/hid/runner.py > "$S/hid.log" 2>&1 < /dev/null &
 p=$!; printf '%s\n' "$p" > "$S/hid.pid"
 for tick in $(seq 1 15); do
  grep -q HID_READY_NO_AUTOMATIC_KEYS "$S/hid.log" && { echo HID_READY; exit 0; }
  kill -0 "$p" 2>/dev/null || break
  sleep 1
 done
 kill -TERM "$p" 2>/dev/null || true
 tail -10 "$S/hid.log"; exit 3;;
 stop)
 [ -f "$S/hid.pid" ] || exit 0
 p=$(cat "$S/hid.pid")
 case "$p" in ''|*[!0-9]*) exit 2;; esac
 cmd=$(tr '\000' ' ' < "/proc/$p/cmdline" 2>/dev/null || true)
 case "$cmd" in *"$D/session-supervisor"*"$D/hid-cleanup.sh"*) kill -TERM "$p";; *) echo 'PID ownership not verified'; exit 2;; esac
 for tick in $(seq 1 10); do [ ! -f "$S/hid.pid" ] && { echo HID_STOPPED; exit 0; }; sleep 1; done
 exit 3;;
 status) if [ -f "$S/hid.pid" ]; then echo 'HID session/state present'; else echo HID_OFF; fi;;
 *) exit 2;;
esac
