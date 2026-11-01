#!/system/bin/sh
# Common KernelSU service.d hook; not an additional KernelSU module.
# Only a one-shot home wallpaper change after the owner user has unlocked.
STATE=/data/adb/onyx-branding
[ ! -e "$STATE/wallpaper-applied" ] || exit 0
umask 077
exec >>"$STATE/wallpaper-setup.log" 2>&1
chmod 600 "$STATE/wallpaper-setup.log"
echo 'WALLPAPER_SETUP_START'
attempt=0
previous=
while :; do
  boot=$(/system/bin/getprop sys.boot_completed)
  current=$(/system/bin/am get-current-user 2>&1)
  owner=$(/system/bin/am get-started-user-state 0 2>&1)
  if [ "$boot" = 1 ] && [ "$current" = 0 ] && [ "$owner" = RUNNING_UNLOCKED ]; then break; fi
  state="boot=$boot current=$current owner=$owner"
  if [ "$state" != "$previous" ]; then echo "WAIT:$state"; previous=$state; fi
  attempt=$((attempt + 1))
  [ "$attempt" -le 180 ] || { echo 'FAIL: owner user not ready within six minutes'; exit 1; }
  sleep 2
done
echo 'OWNER_READY'
cd "$STATE" || exit 1
sha256sum -c WALLPAPER_SHA256SUMS || exit 1
# Retain existing wallpaper files privately; never upload this backup.
if [ ! -e "$STATE/previous-wallpaper.tar" ]; then
  (cd /data/system/users/0 && find . -maxdepth 1 -name '*wallpaper*' >"$STATE/previous-wallpaper-files.txt") || exit 1
  tar -C /data/system/users/0 -cf "$STATE/previous-wallpaper.tar" -T "$STATE/previous-wallpaper-files.txt" || exit 1
  chmod 600 "$STATE/previous-wallpaper.tar"
fi
echo 'WALLPAPER_BACKUP_PASS'
CLASSPATH="$STATE/wallpaper-helper.jar" /system/bin/app_process /system/bin OnyxWallpaper --apply "$STATE/wallpaper.png" || exit 1
touch "$STATE/wallpaper-applied"
# Retain the script for audit; the marker prevents replacing user choices later.
