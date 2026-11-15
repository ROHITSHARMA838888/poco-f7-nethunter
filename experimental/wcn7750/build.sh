#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
KERNEL_SRC="$GITHUB_WORKSPACE/rom-kernel"
KERNEL_OUT="$KERNEL_SRC/out"
WLAN_TREE="$GITHUB_WORKSPACE/vendor-modules/qcom/opensource/wlan"
PLATFORM_DIR="$WLAN_TREE/platform"
QCACLD_DIR="$WLAN_TREE/qcacld-3.0"
VENDOR_SYMVERS="$GITHUB_WORKSPACE/experimental/wcn7750/infinity-wlan-extra.symvers"
JOBS=$(nproc)
WLAN_EXTRA_KCFLAGS=""
WLAN_CTRL_NAME=wlan
test -s "$VENDOR_SYMVERS"
test -f "$KERNEL_SRC/include/linux/qcom-iommu-util.h"
test -d "$QCACLD_DIR/cmn"
grep -qx CONFIG_FEATURE_FRAME_INJECTION_SUPPORT=y "$QCACLD_DIR/configs/sun_gki_wcn7750_defconfig"
COMMON_ARGS=(
	ARCH=arm64
	SUBARCH=arm64
	CC="${CC:-clang}"
	LLVM=1
	LLVM_IAS=1
	CONFIG_CNSS_OUT_OF_TREE=y
	"KCFLAGS=-w -mno-outline -D__ANDROID_COMMON_KERNEL__ -DCONFIG_ARM_SMMU_MODULE=1 -DCONFIG_CFG80211_MODULE=1 -DCONFIG_NL80211_TESTMODE=1 -DCONFIG_QCOM_IOMMU_UTIL_MODULE=1 -DCONFIG_QCOM_MINIDUMP_MODULE=1 -DCONFIG_QCOM_VA_MINIDUMP_MODULE=1 -DCONFIG_SCHED_WALT_MODULE=1 $WLAN_EXTRA_KCFLAGS"
)

EXTRA_SYMVERS="$VENDOR_SYMVERS"

echo "[+] Building WCN7750 driver"
make -j"$JOBS" -C "$KERNEL_SRC" O="$KERNEL_OUT" M="$QCACLD_DIR" modules \
	"${COMMON_ARGS[@]}" \
	WLAN_ROOT="$QCACLD_DIR" \
	WLAN_PROFILE=sun_gki_wcn7750 \
	MODNAME=qca_cld3_wcn7750 \
	CHIP_NAME=wcn7750 \
	DEVNAME=wcn7750 \
	WLAN_CTRL_NAME="$WLAN_CTRL_NAME" \
	QCA_WIFI_FTM_NL80211=y \
	CONFIG_QCA_WIFI_ISOC=0 \
	CONFIG_QCA_WIFI_2_0=1 \
	CONFIG_QCA_CLD_WLAN=m \
	CONFIG_ARM_SMMU=m \
	CONFIG_CFG80211=m \
	CONFIG_QCOM_IOMMU_UTIL=m \
	CONFIG_QCOM_VA_MINIDUMP=m \
	CONFIG_SCHED_WALT=m \
	CONFIG_CNSS2_SSR_DRIVER_DUMP=y \
	CONFIG_WLAN_FEATURE_WMI_DIAG_OVER_CE7=y \
	KBUILD_EXTRA_SYMBOLS="$EXTRA_SYMVERS"


ko="$QCACLD_DIR/qca_cld3_wcn7750.ko"
test "$(modinfo -F name "$ko")" = qca_cld3_wcn7750
test "$(modinfo -F vermagic "$ko" | cut -d' ' -f1)" = 6.6.142-4k-g7750565ada3d-dirty
modprobe --show-modversions "$ko" > wlan-evidence/imported-crcs.txt
python3 experimental/wcn7750/verify_imports.py
llvm-nm "$ko" | grep ' hdd_monitor_mode_tx_inject$'
modinfo "$ko" > wlan-evidence/modinfo.txt
mkdir -p compiled-wlan-NOT-FLASHABLE
cp "$ko" compiled-wlan-NOT-FLASHABLE/
sha256sum "$ko" > wlan-evidence/SHA256SUMS.txt
