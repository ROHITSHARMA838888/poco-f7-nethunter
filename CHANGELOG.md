# Changelog

## v0.1.3 — Wi-Fi module update

The kernel ZIP and external driver binaries are unchanged. Existing users update only the KernelSU Wi-Fi module; new users install the original kernel ZIP and updated module.

- Adds internal WCN7750 monitor activation through Kali airmon-ng.
- Preserves original airmon-ng; adds stop/restore and a five-minute automatic restore.
- Passive reception verified. Packaged module install, reboot autoload, USB guard, Action integration and direct Kali start/stop verified.
- See [upgrade instructions and release details](RELEASE-v0.1.3.md).


## Validation update — 2026-11-02

These are additional tests of the existing v0.1.2 packages; no kernel/module binary or release ZIP was rebuilt or replaced.

- **USB HID:** actual phone-to-Windows keyboard typing passed with the literal text `hid test ok`. The optional standalone HID switch remains unfinished and is not included in this release; automatic boot activation and seamless NetHunter USB switching are not qualified.
- **Deauthentication:** bounded targeted tests with Archer T2U Plus and TL-WN722N v2/v3 on an owned hotspot passed, with client connection interruption and reconnection observed. The maintainer also reports successful manual testing on another phone.
- **MDK:** maintainer reports working manual tests. Tool version, tested modes and repeatability have not been independently documented; this does not qualify every MDK mode.
- **Internal Wi-Fi:** the current kernel advertises monitor-mode support. Internal deauthentication is reported unsupported on the current setup. Actual internal capture and injection have not been independently validated.
- Exact tested device/ROM restrictions and existing backup/install requirements remain in effect. Other ROMs and long-term stability remain unqualified.

Private network identifiers and raw device logs are not published.

## v0.1.2

- KernelSU Next integration on the documented onyx Linux 6.6.142 base.
- Fixed external Archer and WN722N v2/v3 drivers, persistent loading and USB guard.
- Both adapters passed monitor transitions and bounded probe injection (29/30 replies each).
- Kali theme installer included.
