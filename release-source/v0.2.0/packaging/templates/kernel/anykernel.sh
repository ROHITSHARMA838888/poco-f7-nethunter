### Poco F7 onyx - verified ROM-source kernel candidate
properties() { '
kernel.string=Rohit Sharma Onyx NetHunter v0.2.0 | KernelSU Next
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=onyx
supported.versions=
supported.patchlevels=
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

while IFS= read -r line; do ui_print "$line"; done <<'ONYX_BANNER'

          /\                 /\
     ____/  \___        ____/  \
    /    _     _\______/        >
   <____/ \___/  CYBER DRAGON  /
             \_______________/

   +----------------------------------+
   |         N E T H U N T E R        |
   |              O N Y X             |
   +----------------------------------+
   | Blue Glitch boot animation       |
   | Dragon wallpaper collection      |
   | Apps: install separately            |
   | Kali chroot: NOT INCLUDED        |
   +----------------------------------+

ONYX_BANNER
ui_print "[1/5] Checking device and boot layout...";
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
# Patch dates and ROM build numbers are metadata, not ABI compatibility tests.
# No ROM-name, Android-version, build-number or patch-date allowlist.
ui_print "ROM/Android version allowlists disabled. Same-device vendor ABI compatibility is still required; other ROMs are untested.";
ui_print "[2/5] Verifying package files...";
sha256sum -c SHA256SUMS || abort "Package integrity check failed.";
theme_ready=0;
if sh "$AKHOME/branding/install-recovery.sh" "$AKHOME/branding" --check "$SLOT"; then
  theme_ready=1;
else
  ui_print "Theme skipped: prerequisites unavailable. Kernel compatibility checks still apply.";
fi;

ui_print "Onyx NetHunter v0.2.0 | by Rohit Sharma";
ui_print "Kernel-only installation to active slot $SLOT.";
ui_print "[3/5] Preparing the active-slot boot image...";
split_boot;
magic=$(od -An -tx1 -N8 "$BOOTIMG" | tr -d ' \n');
[ "$magic" = 414e44524f494421 ] || abort "Unknown boot image magic.";
[ "$(od -An -tu4 -j40 -N4 "$BOOTIMG" | tr -d ' \n')" = 4 ] || abort "Only boot header v4 is supported.";
[ "$(od -An -tu4 -j20 -N4 "$BOOTIMG" | tr -d ' \n')" = 1584 ] || abort "Unexpected boot v4 header size.";
[ "$(od -An -tu4 -j12 -N4 "$BOOTIMG" | tr -d ' \n')" = 0 ] || abort "Unexpected boot ramdisk; refusing this layout.";
[ "$(od -An -tu4 -j1580 -N4 "$BOOTIMG" | tr -d ' \n')" = 0 ] || abort "Signed GKI boot layout requires separate review.";
# Keep the existing boot metadata. Separate init_boot/vendor_boot and their
# ramdisks/DTB are not supplied or selected by this kernel-only package.
ui_print "[4/5] Writing kernel; existing Image retained...";
flash_boot;
ui_print "[5/5] Setting up boot animation and wallpapers...";
if [ "$theme_ready" = 1 ]; then
  if ! sh "$AKHOME/branding/install-recovery.sh" "$AKHOME/branding" --install "$SLOT"; then
    ui_print "WARNING: kernel installed, theme failed. Preserve recovery log and inspect mount state.";
  fi;
fi;
# Retire only our recognized prior app setup. Never uninstall user apps.
APP_STATE=/data/adb/onyx-extras-blueglitch-v1
APP_HOOK=/data/adb/service.d/onyx-extras-blueglitch-v1.sh
if [ -f "$APP_HOOK" ]; then
  app_hook_hash=$(sha256sum "$APP_HOOK" | cut -d' ' -f1)
  case "$app_hook_hash" in
    069b8b0f8abb74be6a68116cd487b890a177f206f6caf956f8e9cc68350068be|9e2cd61b6184e5512a358523b4a3c0ad6458972f9d2cba48a0550e076ac8ee0e|abb02bd5ddf4b1a23622322119c769e757a3aa50a74d27ed439b3c5624030ed0)
      if mkdir -p "$APP_STATE/retired-hooks" && chmod 700 "$APP_STATE" "$APP_STATE/retired-hooks" && mv "$APP_HOOK" "$APP_STATE/retired-hooks/$app_hook_hash.sh.disabled" && touch "$APP_STATE/disabled"; then
        ui_print "Previous automatic app setup disabled.";
      else
        ui_print "WARNING: could not retire old app setup; preserve recovery log.";
      fi;
      ;;
    *) ui_print "Unknown existing app hook preserved; review manually.";;
  esac;
fi;
ui_print "Kernel write completed. Wi-Fi/VHCI module deployment is a separate step.";

ui_print "Onyx setup staging finished. Read any WARNING above.";
ui_print "No APKs or app downloader included. Install apps separately.";
