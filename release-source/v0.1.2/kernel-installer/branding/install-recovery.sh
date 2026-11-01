#!/system/bin/sh
# Called by the recovery kernel installer, never a standalone flash target.
set -eu
ASSETS=${1:?asset directory required}
MODE=${2:---check}
SLOT=${3:?active slot required}
fail() { echo "BRANDING_ERROR: $*"; exit 1; }
[ "$MODE" = --check ] || [ "$MODE" = --install ] || fail 'Invalid mode'
[ "$(id -u)" = 0 ] || fail 'Recovery root required'
[ "$(getprop ro.product.device)" = onyx ] || fail 'Only onyx supported'
case "$SLOT" in _a|_b) ;; *) fail 'Invalid active slot';; esac
[ -d /data/adb ] && [ -d /data/system/users/0 ] || fail 'Unlock/decrypt data in recovery first'
[ -x /data/adb/ksud ] || fail 'Existing KernelSU Next setup required for the one-shot wallpaper hook'
cd "$ASSETS"
sha256sum -c SHA256SUMS || fail 'Theme integrity check failed'
target=
for path in /system_root/system/media/bootanimation.zip /system/system/media/bootanimation.zip /system/media/bootanimation.zip; do
  if [ -f "$path" ]; then target=$(readlink -f "$path"); break; fi
done
[ -n "$target" ] || fail 'ROM animation file not found'
# Locate the actual longest matching mounted filesystem, not a symlink alias.
mount_record=$(awk -v path="$target" '
  { m=$2; if ((m=="/" || index(path,m"/")==1) && length(m)>best) { best=length(m); record=$2" "$3" "$4" "$1; } }
  END {print record}' /proc/mounts)
set -- $mount_record
mountpoint=${1:-}; fstype=${2:-}; options=${3:-}
device=${4:-}
case "$mountpoint" in /system_root|/system|/system_root/system) ;; *) fail 'Unexpected system mount; refusing writes';; esac
[ "$fstype" = ext4 ] || fail 'Direct animation install requires writable ext4; no EROFS conversion attempted'
# Properties can be spoofed by Android modules; require the real DM table.
dm_device=$(readlink -f "$device")
dm_name=$(cat "/sys/class/block/${dm_device##*/}/dm/name")
[ "$dm_name" = "system$SLOT" ] || fail 'Mounted system does not match the active slot'
DMCTL=$(command -v dmctl || true)
[ -n "$DMCTL" ] || DMCTL=/system/bin/dmctl
[ -x "$DMCTL" ] || fail 'Cannot inspect system verification; no ROM changes attempted'
table=$("$DMCTL" table "$dm_name") || fail 'Cannot inspect system DM table'
targets=$(printf '%s\n' "$table" | grep -E '^[0-9]+-[0-9]+:') || fail 'Unknown system DM table'
if printf '%s\n' "$targets" | grep -v -E '^[0-9]+-[0-9]+: linear,' >/dev/null; then
  fail 'Verified or unknown system mapping; refusing animation changes (verification is never disabled)'
fi
[ ! -e "$target.onyx-new" ] || fail 'Stale animation staging file exists'
STATE=/data/adb/onyx-branding
HOOK=/data/adb/service.d/onyx-wallpaper-once.sh
if [ -e "$HOOK" ]; then
  cmp -s "$ASSETS/wallpaper-once.sh" "$HOOK" || fail 'Existing wallpaper hook differs; preserve it for review'
fi
if [ "$MODE" = --check ]; then echo 'BRANDING_PREFLIGHT_PASS; no files changed'; exit 0; fi
umask 077
mkdir -p "$STATE" /data/adb/service.d
chmod 700 "$STATE"
if [ ! -e "$STATE/bootanimation-original.zip" ]; then
  cp -p "$target" "$STATE/bootanimation-original.zip"
  stat -c '%u %g %a' "$target" > "$STATE/bootanimation-original-metadata.txt"
  printf '%s\n' "$target" > "$STATE/bootanimation-original-path.txt"
fi
cp "$ASSETS/wallpaper-helper.jar" "$STATE/wallpaper-helper.jar"
cp "$ASSETS/wallpaper.png" "$STATE/wallpaper.png"
cp "$ASSETS/WALLPAPER_SHA256SUMS" "$STATE/WALLPAPER_SHA256SUMS"
cp "$ASSETS/CREDITS.txt" "$STATE/CREDITS.txt"
cp "$ASSETS/UPSTREAM-LICENSE" "$STATE/UPSTREAM-LICENSE"
chmod 600 "$STATE/wallpaper-helper.jar" "$STATE/wallpaper.png" "$STATE/WALLPAPER_SHA256SUMS"
restore_ro=0
cleanup() {
  rm -f "$target.onyx-new"
  if [ "$restore_ro" = 1 ]; then
    mount -o remount,ro "$mountpoint" || { echo 'ERROR: system read-only restoration failed'; exit 1; }
  fi
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
case ",$options," in *,ro,*) mount -o remount,rw "$mountpoint"; restore_ro=1;; *,rw,*) ;; *) fail 'Unknown mount flags';; esac
cp "$ASSETS/bootanimation.zip" "$target.onyx-new"
chown 0:0 "$target.onyx-new"
chmod 644 "$target.onyx-new"
chcon u:object_r:system_file:s0 "$target.onyx-new"
mv "$target.onyx-new" "$target"
sync
if [ "$restore_ro" = 1 ]; then mount -o remount,ro "$mountpoint"; restore_ro=0; fi
# Activate the one-shot wallpaper hook only after the animation write succeeds.
cp "$ASSETS/wallpaper-once.sh" "$HOOK"
chmod 755 "$HOOK"
echo 'BRANDING_INSTALLED: official NetHunter animation; home wallpaper queued once'
echo 'Original system mount mode restored; original animation backed up privately'
