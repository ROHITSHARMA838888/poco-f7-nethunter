#!/system/bin/sh
# Automatic file integration; chroot mounts are not required.
set -eu
MODDIR=${0%/*}
[ -f "$MODDIR/internal/airmon-ng" ] || { echo 'Missing integration payload'; exit 1; }
[ ! -f "$MODDIR/disable" ] && [ ! -f "$MODDIR/remove" ] || exit 0
for KALI in /data/local/nhsystem/kali-arm64 /data/local/stryker/release; do
TARGET=$KALI/usr/sbin/airmon-ng
[ -x "$TARGET" ] && [ -x "$KALI/usr/bin/dpkg-divert" ] || continue
cmp -s "$MODDIR/internal/airmon-ng" "$TARGET" && continue
if [ -f "$TARGET.distrib" ]; then
 grep -q 'Onyx WCN7750 compatibility' "$TARGET" || { echo 'Foreign diversion: refusing to replace airmon-ng'; exit 1; }
else
 chroot "$KALI" /usr/bin/dpkg-divert --local --rename --add /usr/sbin/airmon-ng
fi
cp "$MODDIR/internal/airmon-ng" "$TARGET.onyx-new"
chmod 755 "$TARGET.onyx-new"
chroot "$KALI" /bin/sh -n /usr/sbin/airmon-ng.onyx-new
mv "$TARGET.onyx-new" "$TARGET"
echo 'Internal monitor integration ready: airmon-ng start wlan0 [channel], airmon-ng stop wlan0.'
done
TARGET=/data/adb/ksu/bin/airmon-ng
if [ -e "$TARGET" ] && ! grep -q 'Onyx WCN7750 Android compatibility' "$TARGET"; then
 echo 'Existing Android airmon-ng preserved; refusing replacement.'
 exit 1
fi
if ! cmp -s "$MODDIR/internal/airmon-ng-android" "$TARGET"; then
 cp "$MODDIR/internal/airmon-ng-android" "$TARGET.onyx-new"
 chmod 755 "$TARGET.onyx-new"
 mv "$TARGET.onyx-new" "$TARGET"
 echo 'Android root airmon-ng entry point installed.'
fi
