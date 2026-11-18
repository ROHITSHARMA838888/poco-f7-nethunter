#!/system/bin/sh
set -eu
D=${0%/*}
CORE=${D%/bluetooth/bridge}
[ ! -f "$CORE/disable" ] && [ ! -f "$CORE/remove" ] || { echo 'Core module disabled'; exit 2; }
S=/data/adb/onyx_internal_bluetooth
R=/data/local/nhsystem/kali-arm64
B=/data/adb/ksu/bin/busybox
[ "$(id -u)" = 0 ] && [ "$(getprop ro.product.device)" = onyx ] || exit 2
[ "$(uname -r)" = 6.6.142-4k-g7750565ada3d-dirty ] || exit 2
[ "$(/system/bin/cmd settings get global bluetooth_on)" = 0 ] || { echo 'Turn Android Bluetooth OFF first'; exit 2; }
[ -z "$(ls /sys/class/bluetooth 2>/dev/null)" ] || exit 2
[ -c "$R/dev/binder" ] || { echo 'Open Kali first'; exit 2; }
(cd "$D" && "$B" sha256sum -c RUNTIME_SHA256SUMS) || exit 2
[ -d /sys/module/hci_vhci ] || insmod "$D/hci_vhci.ko"
tick=0
while [ ! -c /dev/vhci ] || [ ! -c "$R/dev/vhci" ]; do
 tick=$((tick + 1))
 [ "$tick" -le 10 ] || { echo 'VHCI device unavailable after 10 seconds; open Kali first'; exit 2; }
 sleep 1
done
T="$R/root/onyx-bluetooth-module"
mkdir -p "$T" "$S"
"$B" tar -xzf "$D/payload.tar.gz" -C "$T"
mkdir "$S/session" || { echo 'Existing session or restore state; stop first'; exit 2; }
/system/bin/cmd settings get global ble_scan_always_enabled > "$S/session/original_scan"
cat /proc/sys/kernel/random/boot_id > "$S/session/boot"
printf '%s\n' "$$" > "$S/session/pid"
/system/bin/cmd settings put global ble_scan_always_enabled 0
/system/bin/cmd bluetooth_manager disable
sleep 4
if ! dumpsys bluetooth_manager | grep -q 'State: *OFF'; then /system/bin/sh "$D/cleanup.sh"; exit 2; fi
exec "$D/session-supervisor" "$D/cleanup.sh" -- /system/bin/chroot "$R" /usr/bin/env LD_LIBRARY_PATH=/root/onyx-bluetooth-module/deps/usr/lib/aarch64-linux-gnu /root/onyx-bluetooth-module/bluebinder-candidate
