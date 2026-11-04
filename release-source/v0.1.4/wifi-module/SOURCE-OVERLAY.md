Source overlay for Wi-Fi v0.1.4-usb-guard-fix / versionCode 7.
External driver bytes and internal monitor integration match v0.1.3. Driver source pins are documented under v0.1.2. Guard source: compatibility/usb_auth_guard.c, build/test workflow .github/workflows/usb-auth-guard.yml at this commit. Compiled guard run: 41812976995. Binaries are distributed in the release ZIP; manifest entries describe those bytes.
T2U 2357:011f has driver/guard coverage; tester reports working. Independent physical retest/log confirmation remains limited.
