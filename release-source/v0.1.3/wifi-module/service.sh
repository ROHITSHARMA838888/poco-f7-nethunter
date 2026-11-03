#!/system/bin/sh
# Runs once at boot through KernelSU; no recurring interface/power tweaks.
set -eu
MODDIR=${0%/*}
[ ! -f "$MODDIR/disable" ] && [ ! -f "$MODDIR/remove" ] || exit 0
STATE=/data/adb/onyx-drivers-41316130882-v012
[ -d "$STATE" ] || exit 1
umask 077
exec >> "$STATE/boot.log" 2>&1
printf '\nSTART:%s kernel=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$(uname -r)"
if [ "$(uname -r)" != 6.6.142-4k-g7750565ada3d-dirty ]; then
  echo 'SKIP: different kernel; no drivers loaded'
  exit 0
fi
cd "$MODDIR"
sha256sum -c GUARD_SHA256SUMS
/system/bin/sh "$MODDIR/action.sh"
# Android's own ROM modules must be ready before external drivers.
attempt=0
while ! grep -q '^cfg80211 ' /proc/modules; do
  attempt=$((attempt + 1))
  [ "$attempt" -lt 60 ] || { echo 'FAIL: cfg80211 unavailable'; exit 1; }
  sleep 2
done
GUARD="$MODDIR/bin/usb-auth-guard"
running=0
if [ -f "$STATE/usb-auth-guard.pid" ]; then
  old=$(cat "$STATE/usb-auth-guard.pid")
  case "$old" in ''|*[!0-9]*) old=0;; esac
  if [ -r "/proc/$old/cmdline" ]; then
    program=$(tr '\000' '\n' < "/proc/$old/cmdline" | head -n 1)
    mode=$(tr '\000' '\n' < "/proc/$old/cmdline" | sed -n '2p')
    if [ "$program" = "$GUARD" ] && [ "$mode" = --run ] && kill -0 "$old" 2>/dev/null; then running=1; fi
  fi
fi
if [ "$running" = 0 ]; then
  if [ -f "$STATE/usb-auth-guard-boot.log" ]; then cp "$STATE/usb-auth-guard-boot.log" "$STATE/usb-auth-guard-boot.previous.log"; fi
  nohup "$GUARD" --run </dev/null >"$STATE/usb-auth-guard-boot.log" 2>&1 &
  guard_pid=$!
  echo "$guard_pid" > "$STATE/usb-auth-guard.pid"
  attempt=0
  while ! grep -q '^GUARD_SERVICE_READY' "$STATE/usb-auth-guard-boot.log"; do
    kill -0 "$guard_pid" || { echo 'FAIL: USB guard startup'; exit 1; }
    attempt=$((attempt + 1))
    [ "$attempt" -lt 20 ] || { echo 'FAIL: USB guard not ready'; exit 1; }
    sleep 0.1
  done
fi
/system/bin/sh "$STATE/load-drivers.sh"
echo 'BOOT_AUTOLOAD_PASS'
echo 'USB_GUARD_SERVICE_PASS'
