Experimental onyx internal Bluetooth, exact kernel 6.6.142-4k-g7750565ada3d-dirty.
Kali rootfs must be /data/local/nhsystem/kali-arm64 and opened before start.
Turn Android Bluetooth OFF. KernelSU Action starts/stops a manual session.
Do not enable Android Bluetooth during a Kali session. Stop before normal audio.
Session has maximum 30 minutes. No radio activation at boot.
Tested: owned-device scanning, SDP, supervised cleanup, normal Android audio.
Not all Bluetooth attacks are qualified. No Wi-Fi/kernel replacement.
Package install/reboot testing pending. Do not distribute as stable.
Credits: Linux VHCI authors; mer-hybris Bluebinder; libgbinder and libglibutil authors.
Bluebinder source ebab7c3c3fb15f0eea4db0ff14837066a716f973, aidl6/aidl3 patch and trace logging.
https://github.com/mer-hybris/bluebinder
Keep original component licences and corresponding sources when redistributing.

Experimental opt-in HID (v0.1.1): package integration testing pending.
Start main Bluetooth session with Action, then Android root shell:
sh /data/adb/modules/onyx_internal_bluetooth/hid.sh start OWN_LAPTOP_BLUETOOTH_MAC
Pair Onyx HID Test on your own laptop. No automatic keystrokes.
Stop HID: sh /data/adb/modules/onyx_internal_bluetooth/hid.sh stop
Main Action stop also stops HID before restoring Android scanning.
HID stores temporary BlueZ/agent logs inside Kali rootfs; do not publish raw logs.

Repair v0.1.2: restores missing bridge; Kali init Start/Stop hook. No Wi-Fi changes.
No automatic radio activation at boot. Turn Android Bluetooth OFF before Kali Start.
