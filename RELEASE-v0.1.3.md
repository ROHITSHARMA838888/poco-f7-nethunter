# Onyx NetHunter v0.1.3 — Wi-Fi module update

**The kernel is unchanged. Only the existing KernelSU Wi-Fi module is updated.**

## Downloads

- `Onyx-NetHunter-v0.1.2-test.zip`: the same original kernel ZIP, unchanged SHA-256.
- `Onyx-NetHunter-WiFi-v0.1.3-KernelSU.zip`: updated version of the existing Wi-Fi module; same module ID, no third module needed.
- `SHA256SUMS.txt`: hashes for both ZIPs.

## Existing users

If the v0.1.2 kernel is already installed, download and update **only the v0.1.3 Wi-Fi module** using KernelSU Next Manager → Modules. Do not reflash the kernel. Remove external adapters before the required reboot.

## New users

Install the kernel ZIP through OrangeFox, and install the new Wi-Fi module ZIP through KernelSU Next Manager. Follow the existing exact-ROM compatibility and backup instructions. The module ZIP is not recovery-flashable.

## Changelog

- Added internal WCN7750 monitor activation to the existing Wi-Fi module.
- Kali root terminal can use `airmon-ng start wlan0` / `airmon-ng stop wlan0`; Android activation is handled automatically.
- Original airmon-ng is backed up with a local dpkg diversion. External adapters continue through the original airmon-ng script.
- Added hotspot-active guard, error rollback and five-minute automatic normal-mode restore.
- Kernel Image, external 88XXau/8188eu driver binaries and USB guard are unchanged.
- Internal monitor mode and passive beacon capture verified on POCO F7. Internal injection/deauthentication are not qualified.

## Using internal monitor mode

Kali NetHunter chroot and aircrack-ng must already be installed. Supported path: `/data/local/nhsystem/kali-arm64`. Start Kali so its mounts are ready; if needed, tap the Wi-Fi module's **Action** button to install the integration. A Kali reinstall requires tapping Action again.

Turn phone Wi-Fi hotspot OFF. In Kali root terminal:

```sh
airmon-ng start wlan0 6
airodump-ng --channel 6 wlan0
# Ctrl+C, then:
airmon-ng stop wlan0
```

Default channel is 6; helper accepts 2.4 GHz channels 1–11. Normal Wi-Fi is automatically restored after five minutes. USB tethering can supply PC internet during capture.

## Compatibility and validation

POCO F7 / onyx, documented Infinity-X 4.1 Android 17 build, matching `6.6.142-4k-g7750565ada3d-dirty` kernel. Other ROMs/chroot layouts are not verified.

Package installation and reboot verification passed on the target phone: v0.1.3 active, both existing external drivers auto-loaded, USB guard passed, module Action installed the matching Kali wrapper, and direct airmon-ng start/stop passed. Normal Wi-Fi restored afterward. KernelSU BusyBox checksum verification passed after correcting manifest line endings. The five-minute timer is configured; automatic timeout itself has not been independently qualified in this packaged update.

Credits: Onyx kernel contributors, Qualcomm/ROM Wi-Fi driver contributors, KernelSU Next, aircrack-ng, and existing project credits. No kernel or external driver rebuild in this update.