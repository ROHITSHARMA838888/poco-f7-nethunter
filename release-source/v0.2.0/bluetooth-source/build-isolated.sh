#!/system/bin/sh
set -eu
R=/data/local/nhsystem/kali-arm64
D=$R/root/onyx-bluetooth-candidate
mkdir -p "$D"
cp /data/local/tmp/onyx-bluebinder-candidate.c "$D/bluebinder.c"
chroot "$R" /bin/sh <<'KALI'
set -eu
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd /root/onyx-bluetooth-candidate
mkdir -p debs deps
cd debs
apt-get download libgbinder-dev=1.1.54-2 libgbinder1=1.1.54-2 libglibutil-dev=1.0.83-2 libglibutil1=1.0.83-2
for package in ./*.deb; do dpkg-deb -x "$package" ../deps; done
cd ..
export PKG_CONFIG_PATH="$PWD/deps/usr/lib/aarch64-linux-gnu/pkgconfig:$PWD/deps/usr/lib/pkgconfig"
find deps -name '*.pc' -o -name 'libgbinder.so*' -o -name 'libglibutil.so*'
gcc -Wall -flto -DUSE_SYSTEMD=0 bluebinder.c -Ideps/usr/include/gbinder -Ideps/usr/include/gutil $(pkg-config --cflags glib-2.0) -L"$PWD/deps/usr/lib" -L"$PWD/deps/usr/lib/aarch64-linux-gnu" -Wl,-rpath,'$ORIGIN/deps/usr/lib:$ORIGIN/deps/usr/lib/aarch64-linux-gnu' -lgbinder -lglibutil $(pkg-config --libs glib-2.0) -o bluebinder-candidate
file bluebinder-candidate
sha256sum bluebinder-candidate
LD_LIBRARY_PATH="$PWD/deps/usr/lib:$PWD/deps/usr/lib/aarch64-linux-gnu" ldd ./bluebinder-candidate
KALI
