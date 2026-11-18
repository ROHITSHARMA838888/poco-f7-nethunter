#!/system/bin/sh
set -eu
D=${0%/*}
/system/bin/sh "$D/ctl.sh" stop
T=/data/local/nhsystem/kali-arm64/etc/init.d/bluetooth
if [ -f "$T.onyx-original" ]; then
 cmp -s "$T" "$D/kali-bluetooth" || { echo 'Hook changed; refusing restore'; exit 2; }
 mv "$T.onyx-original" "$T"
fi
