#!/system/bin/sh
set -eu
D=${0%/*}
R=/data/local/nhsystem/kali-arm64
T="$R/etc/init.d/bluetooth"
O="$T.onyx-original"
[ -f "$T" ] || { echo 'Kali Bluetooth init script absent'; exit 2; }
if [ -f "$O" ]; then
 if ! cmp -s "$T" "$D/kali-bluetooth"; then
  [ "$(sha256sum "$T" | cut -d' ' -f1)" = c73f61b51337ac40febbba226c98d108d1c5bbb04b494e69cc3303482bdd2b7b ] || { echo 'Existing hook differs; refusing overwrite'; exit 2; }
  cp "$D/kali-bluetooth" "$T.onyx-new"
  chmod 755 "$T.onyx-new"
  mv "$T.onyx-new" "$T"
 fi
else
 [ "$(sha256sum "$T" | cut -d' ' -f1)" = 755b8516eeebe037bb8cf5daa33e882996a2cb531540e6dadbeb6536a04a0da2 ] || { echo 'Unknown Bluetooth init script; refusing overwrite'; exit 2; }
 cp -p "$T" "$O"
 cp "$D/kali-bluetooth" "$T.onyx-new"
 chmod 755 "$T.onyx-new"
 mv "$T.onyx-new" "$T"
fi
echo KALI_START_STOP_HOOK_READY
