#!/system/bin/sh
# Explicit action and boot-time installation; no RF activity.
set -eu
MODDIR=${0%/*}
KALI=/data/local/nhsystem/kali-arm64
[ -f "$MODDIR/internal/airmon-ng" ] || { echo 'Missing integration payload'; exit 1; }
[ ! -f "$MODDIR/disable" ] && [ ! -f "$MODDIR/remove" ] || exit 0
if [ ! -x "$KALI/usr/sbin/airmon-ng" ]; then
 echo 'Kali/airmon-ng absent: install Kali and aircrack-ng, then tap this module Action or reboot.'
 exit 0
fi
if [ ! -x "$KALI/usr/sbin/chroot" ] || [ ! -r "$KALI/proc/1/root/proc/version" ]; then
 echo 'Kali must be mounted by NetHunter first; then tap module Action.'
 exit 0
fi
TARGET=$KALI/usr/sbin/airmon-ng
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
echo 'Hotspot must be OFF. Five-minute automatic restore; passive capture only qualified.'
