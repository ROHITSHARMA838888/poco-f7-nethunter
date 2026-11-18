# Basic functional checks

## Preconditions

POCO F7 / onyx, matching kernel, KernelSU root and combined module. Open the Kali chroot. Save logs privately; redact IP/MAC/device details before sharing.

## Wi-Fi

Turn hotspot off. In Kali root terminal:

```sh
airmon-ng start wlan0 6
iw dev wlan0 info
airmon-ng stop wlan0
```

Expect monitor type on channel 6, then normal mode after stop. Internal channels 1–11 only. Always stop before reboot.

On your own AP, a bounded injection diagnostic (replace placeholders):

```sh
airmon-ng start wlan0 OWN_AP_CHANNEL
timeout 15 aireplay-ng --test -a OWN_AP_BSSID -e 'OWN_AP_SSID' wlan0
airmon-ng stop wlan0
```

Do not target nearby networks. ACKs alone do not prove client disconnection; targeted deauth was separately verified on an owned client. Do not infer compatibility with all protected networks.

## Bluetooth

Android Bluetooth OFF, Kali open:

```sh
service bluetooth start
hciconfig -a
hciconfig hci0 up
hciconfig hci0
service bluetooth stop
```

Use the displayed HCI number. Check normal Android Bluetooth/audio after stopping. This does not qualify every Bluetooth tool or Bluetooth HID pairing.

## Diagnostics

Android root shell, if reporting an issue:

```sh
uname -r
cat /data/adb/modules/onyx_verified_wifi/module.prop
tail -40 /data/adb/modules/onyx_verified_wifi/internal-wlan-state/boot.log
cat /data/adb/onyx-drivers-41316130882-v012/bluetooth-hook.log
```

No automatic radio attacks run at boot. No public raw-log uploads are required.
