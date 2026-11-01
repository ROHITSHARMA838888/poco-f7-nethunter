### Poco F7 onyx - verified ROM-source kernel candidate
properties() { '
kernel.string=Rohit Sharma Onyx NetHunter v0.1.2-test | KernelSU Next
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=onyx
supported.versions=17
supported.patchlevels=2026-10 - 2026-10
supported.vendorpatchlevels=
'; }

BLOCK=/dev/block/by-name/boot;
IS_SLOT_DEVICE=1;
SLOT_SELECT=active;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=0;
NO_MAGISK_CHECK=1;
NO_VBMETA_PARTITION_PATCH=1;

. tools/ak3-core.sh;

ui_print "Onyx NetHunter v0.1.2-test | Rohit Sharma";
ui_print "Thanks: xiaomi-onyx-playground / onyx kernel contributors";
ui_print "KernelSU Next | aircrack-ng Realtek drivers";
ui_print "AnyKernel3: osm0sis | tools: topjohnwu / Magisk";
ui_print "Artwork: Kali Linux / NetHunter contributors";
ui_print "Full upstream source links and credits: CREDITS.txt";

[ "$BOOTMODE" = false ] || abort "Recovery installation only.";
[ "$(getprop ro.product.device)" = onyx ] || abort "Only onyx is supported.";
case "$SLOT" in _a|_b) ;; *) abort "Invalid active slot.";; esac;
[ "$BLOCK" = "/dev/block/by-name/boot$SLOT" ] || abort "Unexpected target partition.";
lock_state=$(getprop ro.boot.flash.locked);
device_state=$(getprop ro.boot.vbmeta.device_state);
verified_state=$(getprop ro.boot.verifiedbootstate);
case "$lock_state" in ''|0) ;; *) abort "Bootloader reports locked or invalid lock state.";; esac;
case "$device_state" in ''|unlocked) ;; *) abort "Bootloader reports locked or invalid device state.";; esac;
case "$verified_state" in ''|orange) ;; *) abort "Conflicting verified boot state.";; esac;
if [ "$lock_state" != 0 ] || [ "$device_state" != unlocked ]; then
  # Some recoveries omit these properties. Accept only direct kernel bootconfig
  # evidence of orange/unlocked; unknown states and contradictory values abort.
  bootconfig_state=$(cat /proc/bootconfig 2>/dev/null | sed -n 's/^androidboot\.verifiedbootstate = "\([^"]*\)"$/\1/p');
  [ "$bootconfig_state" = orange ] || abort "Bootloader unlock evidence unavailable in recovery.";
fi;
[ "$(file_getprop /system/build.prop ro.build.version.incremental)" = 1792766195 ] || abort "This package requires the verified Infinity-X ROM build.";
[ "$(file_getprop /system/build.prop ro.build.version.sdk)" = 37 ] || abort "Android SDK mismatch.";
[ "$(file_getprop /system/build.prop ro.build.version.security_patch)" = 2026-10-01 ] || abort "ROM security patch mismatch or missing.";
sha256sum -c SHA256SUMS || abort "Package integrity check failed.";
sh "$AKHOME/branding/install-recovery.sh" "$AKHOME/branding" --check "$SLOT" || abort "Branding preflight failed; kernel not written.";

ui_print "Onyx NetHunter v0.1.2-test | by Rohit Sharma";
ui_print "Kernel-only installation to active slot $SLOT.";
split_boot;
magic=$(od -An -tx1 -N8 "$BOOTIMG" | tr -d ' \n');
[ "$magic" = 414e44524f494421 ] || abort "Unknown boot image magic.";
[ "$(od -An -tu4 -j40 -N4 "$BOOTIMG" | tr -d ' \n')" = 4 ] || abort "Only boot header v4 is supported.";
[ "$(od -An -tu4 -j20 -N4 "$BOOTIMG" | tr -d ' \n')" = 1584 ] || abort "Unexpected boot v4 header size.";
[ "$(od -An -tu4 -j12 -N4 "$BOOTIMG" | tr -d ' \n')" = 0 ] || abort "Unexpected boot ramdisk; refusing this layout.";
[ "$(od -An -tu4 -j1580 -N4 "$BOOTIMG" | tr -d ' \n')" = 0 ] || abort "Signed GKI boot layout requires separate review.";
# Keep the existing boot metadata. Separate init_boot/vendor_boot and their
# ramdisks/DTB are not supplied or selected by this kernel-only package.
flash_boot;
sh "$AKHOME/branding/install-recovery.sh" "$AKHOME/branding" --install "$SLOT" || abort "Kernel installed, but theme installation failed. See recovery log.";
ui_print "Kernel write completed. Wi-Fi module deployment is a separate step.";
