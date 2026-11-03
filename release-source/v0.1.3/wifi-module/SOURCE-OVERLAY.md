# v0.1.3 module source overlay

Apply these files over the v0.1.2 Wi-Fi module tree. Keep `bin/`, `drivers/`,
`payload/` byte-for-byte unchanged from v0.1.2. Included manifests pin all bytes.
No kernel compile or driver compile is performed. Package files from
PACKAGE_SHA256SUMS plus PACKAGE_SHA256SUMS itself at the ZIP root, preserving
Unix executable modes for shell scripts, internal/airmon-ng and usb-auth-guard.
This overlay contains no third-party driver binaries or original airmon-ng.

Validation: ZIP integrity and both SHA256 manifests verified; Android sh syntax
passed for installer/service/action/helper/uninstall/wrapper. Standalone monitor
activation and passive reception verified on the target phone, and Kali direct
airmon-ng start/stop integration verified. Full KernelSU ZIP installation and postboot checks passed: v0.1.3 active, both drivers auto-loaded, USB guard passed, Action wrapper matches and direct Kali start/stop passed. Manifest checks also passed under KernelSU BusyBox after enforcing LF line endings.
