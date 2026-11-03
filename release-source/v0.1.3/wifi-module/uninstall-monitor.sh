#!/system/bin/sh
MODDIR=${0%/*}
KALI=/data/local/nhsystem/kali-arm64
if [ -d /data/adb/onyx-monitor-session ]; then
 /system/bin/sh "$MODDIR/internal/onyx-monitor.sh" stop || exit 1
fi
TARGET=$KALI/usr/sbin/airmon-ng
if [ -f "$TARGET.distrib" ] && cmp -s "$MODDIR/internal/airmon-ng" "$TARGET"; then
 rm "$TARGET" || exit 1
 chroot "$KALI" /usr/bin/dpkg-divert --local --rename --remove /usr/sbin/airmon-ng
else
 echo 'No matching Onyx wrapper to restore; other edits preserved.'
fi
