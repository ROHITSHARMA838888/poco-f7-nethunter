#!/system/bin/sh
# Runtime loader for the exact running candidate; no ROM or USB-role changes.
set -eu
[ "$(id -u)" = 0 ] || exit 1
[ "$(uname -r)" = 6.6.142-4k-g7750565ada3d-dirty ] || { echo 'Kernel mismatch'; exit 1; }
cd /data/adb/onyx-drivers-41316130882-v012
sha256sum -c SHA256SUMS
for name in 88XXau 8188eu; do
  if grep -q "^$name " /proc/modules; then
    echo "ALREADY_LOADED:$name"
  else
    if [ "$name" = 88XXau ]; then
      insmod "./$name.ko" rtw_drv_log_level=1 || { echo "LOAD_FAILED:$name"; exit 1; }
    else
      insmod "./$name.ko" || { echo "LOAD_FAILED:$name"; exit 1; }
    fi
    grep -q "^$name " /proc/modules || { echo "NOT_REGISTERED:$name"; exit 1; }
    echo "LOADED:$name"
  fi
done
echo 'BOTH_REALTEK_DRIVERS_LOADED: Archer T2U Plus and WN722N v2/v3'
