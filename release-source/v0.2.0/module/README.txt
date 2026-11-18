PRIVATE DAILY-AUTOLOAD CANDIDATE - NOT A PUBLIC RELEASE
Updates the same onyx_verified_wifi module. Existing external adapter drivers,
USB guard and VHCI binary are unchanged. Kernel and ROM partitions are untouched.
The guarded internal WCN7750 driver loads each boot after Android is ready.
Wi-Fi and scan-always availability are temporarily disabled through Android APIs
until the framework and internal interfaces are quiescent, then restored exactly.
A boot journal blocks repeated automatic attempts after an incomplete startup.
The 60-second startup marker is not a guarantee against all later crashes.
If hotspot is active at boot it is left untouched; airmon-ng start wlan0 can
activate the internal driver later after hotspot is off. No Action button needed.
Disable/remove this module and reboot for ROM internal Wi-Fi driver recovery.
Normal Wi-Fi, monitor/injection, audio and hotspot passed controlled tests;
this combined package still needs installation, two boot checks and observation.
The separate onyx_internal_wlan_test companion must be disabled before reboot.
Source and upstream notices: internal/wlan/SOURCE.txt and UPSTREAM-NOTICES.txt.

Combined r3/code16: includes internal Bluetooth bridge. Android Bluetooth OFF, open Kali, Bluetooth service Start. Stop before Android audio. Separate old Bluetooth module disabled and retained as backup.
