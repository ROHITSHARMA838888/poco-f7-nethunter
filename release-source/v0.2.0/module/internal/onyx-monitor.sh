#!/system/bin/sh
set -eu
HERE=${0%/*}
if [ "${1:-}" = start ] && [ ! -e /sys/module/qca_cld3_wcn7750/parameters/injection_dp_inflight_limit ]; then
 /system/bin/sh "$HERE/wlan/loader.sh" activate
 [ -e /sys/module/qca_cld3_wcn7750/parameters/injection_dp_inflight_limit ] || { echo 'Internal injection driver unavailable; inspect internal-wlan-state/boot.log.' >&2; exit 1; }
fi
exec /system/bin/sh "$HERE/onyx-monitor-base.sh" "$@"
