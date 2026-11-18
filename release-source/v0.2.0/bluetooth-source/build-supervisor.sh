#!/system/bin/sh
set -eu
R=/data/local/nhsystem/kali-arm64
cp /data/local/tmp/onyx-session-supervisor.c "$R/root/onyx-bluetooth-candidate/session-supervisor.c"
chroot "$R" /usr/bin/env PATH=/usr/sbin:/usr/bin:/sbin:/bin /usr/bin/gcc -static -O2 -Wall -Wextra -Werror /root/onyx-bluetooth-candidate/session-supervisor.c -o /root/onyx-bluetooth-candidate/session-supervisor
cp "$R/root/onyx-bluetooth-candidate/session-supervisor" /data/local/tmp/onyx-session-supervisor
chmod 700 /data/local/tmp/onyx-session-supervisor
