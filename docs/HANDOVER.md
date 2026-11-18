# Onyx NetHunter — maintainer/agent handover

Status recorded **2026-11-18**. Public project: `ROHITSHARMA838888/poco-f7-nethunter`. This document contains project facts, not private chat history or device identifiers.

## Published state

- Public releases: v0.1.2 (previous) and **v0.2.0** (new). A historical v0.1.3 draft is not a released version.
- v0.2.0 release commit: `dc04b31c9d2b9d47c716b8d4a2cc8f58e02f2c61` (PR #10).
- Kernel asset: `Onyx-NetHunter-v0.2.0-Kernel.zip`, 58,357,110 bytes, SHA256 `d5e5c490f2d496513073ec3ba4ec89c71efcc5a554ce7c6d3c1c2b1c0e1c449b`.
- Module asset: `Onyx-NetHunter-v0.2.0-WiFi-Bluetooth-KernelSU.zip`, 35,051,222 bytes, SHA256 `9248321dcb266c5499d09213fa847a0f958eb5ceeb85a5064c75ace0c91effc9`.
- Kernel Image SHA256: `02a8135044334ecf4c98d4ca804d2afcaf2f990f95825d9401e97c174e45eeea`; unchanged by the module/installer updates.
- Exact kernel release: `6.6.142-4k-g7750565ada3d-dirty`. v0.2.0 module ID `onyx_verified_wifi`, versionCode **17**; based on tested r3/code16 functionality.
- r5: no-apps Blue Glitch installer. r6: removed Android-version allowlists; Image unchanged. r3: combined internal Wi-Fi/Bluetooth module. These are packaging/test revisions, not distinct public kernel releases.
- Revised unrestricted installer and exact v0.2.0 ZIPs passed offline checks but do **not** have a recorded fresh flash test. Do not erase this distinction.

## Runtime evidence summary

| Area | Recorded result |
| --- | --- |
| Device / ROM | POCO F7 / onyx; kernel/base tested on Infinity-X 4.1 and 4.2 / Android 17; newest combined tests on 4.2 |
| Root | Existing original pinned KernelSU Next working; not the abandoned newer official-stable experiment |
| Internal WCN7750 | Normal Wi-Fi/DHCP, 2.4 GHz monitor, probe injection and targeted owned-client deauth tested |
| Latest combined deauth | 2026-11-16: ACKs plus client-side Windows security stop/restart about 3 seconds apart; same phone boot and restored normal mode |
| Bluetooth | Combined module: service Start→HCI, interface UP, duplicate Start, Stop and BLE scan restoration passed |
| Coexistence | Normal Wi-Fi, actual hotspot internet and earbuds audio tested on guarded internal driver; short audio interruption during live driver swaps had recovered |
| USB adapters | Fixed Archer T2U Plus and WN722N v2/v3 monitor/injection/deauth historically passed; unchanged driver bytes in v0.2.0 |
| USB HID | Actual harmless text typing passed previously; automatic gadget activation/cleanup not fully qualified |

No broad all-ROM, all-Bluetooth-attacks, long-term endurance or banking/Integrity claim is justified. See `KNOWN-ISSUES.md`.

## Source and build map

- Kernel config/integration/Realtek changes: `release-source/v0.1.2` and pinned workflows.
- Current shell sources, Bluetooth C source, internal-WLAN patches: `release-source/v0.2.0`.
- Complete release text templates, per-file hashes and archive metadata: `release-source/v0.2.0/packaging`.
- Baseline matching config and kernel CRC table: `build-inputs/v0.2.0`.
- Manual internal WLAN and VHCI rebuild workflows: `rebuild-internal-wlan.yml`, `rebuild-vhci.yml`.
- Public packaging entry point: `scripts/package_release.py`. Read `BUILDING.md` before using it; release-input repack is not a source compile.
- Pinned upstream URLs/revisions: `SOURCE.md`. No tokens or private device backups are required to read public source.

## Important build/test history

| Run | Purpose / result |
| --- | --- |
| 41207879867 | Working branded kernel/base config and complete symbol table |
| 41297489306 | Archer TX tasklet fix |
| 41316130882 | WN722N CFI/disconnect fixes and LED support |
| 41200495879 | Native USB guard build |
| 43794293758 | Guarded internal WCN7750 driver; 527 imports checked, compiled TX path verified |
| 44318997538 | Official KernelSU Next v3.4.2 + SUSFS LKM experiment: kernel built, LKM MODPOST failed; abandoned by owner |

Old artifacts can expire. The baseline config/CRC table and current patches are now in Git. Workflow logs are supplementary evidence, not the only build inputs.

## Device architecture

The kernel ZIP writes the active-slot Boot kernel through AnyKernel3 and separately installs visual assets when prerequisites allow. It is recovery-only. Kernel ZIP does not include Kali chroot/APKs.

The KSU module loads external Realtek drivers and native USB authorization guard, then independently starts the guarded internal driver loader. Exact kernel/stock-WLAN hash checks remain; no ROM-name lock. Internal state lives under the module's `internal-wlan-state`; a previous incomplete startup can suspend loading rather than risk repeating a crash.

Internal driver loader quiesces Android Wi-Fi plus scan-always, waits for stable idle, switches only non-forcibly and restores user settings. Startup watchdog is 75 seconds; health marker after 60 seconds proves liveness only. AP active at boot causes a safe skip. The normal firmware capability policy is preserved; monitor-only override is gated by con_mode 4.

The combined Bluetooth bridge is `bluetooth/bridge`. Boot installs a reversible Kali init hook, **does not activate radio**. With Android Bluetooth OFF and Kali open, Kali service Start launches supervised Bluebinder, exposing HCI via VHCI; Stop restores scan settings. Session limit is 30 minutes. A known standalone `onyx_internal_bluetooth` module is backed up/disabled during migration.

## Next work / priorities

1. Fresh flash-test exact v0.2.0 installer/module on authorized hardware, including a second reboot. Preserve the working backup first.
2. Harden legacy monitor-session boot ownership/recovery without losing restoration state; see known issues. Do not silently discard live session state.
3. Qualify Bluetooth GUI Start path, extended use and Windows Bluetooth HID pairing separately.
4. Test other POCO F7 ROMs using their actual vendor ABI before listing them as supported.
5. Improve fully isolated source rebuilds for Bluetooth dependencies and byte reproducibility; do not invent missing historical provenance.

SUSFS work is **paused/abandoned at owner request**, not a release feature. Do not revive or flash its partial artifacts without a new request. Existing phones may still have the r3 test label; published code17 is a metadata update, not evidence it was installed.

## Privacy boundary

Public: implementation, configs, ABI tables, patches, recipes, sanitized test outcomes, original notices and dependency pins. Private: credentials, passwords, phone serials, personal SSID/MAC/IPs, raw dmesg/pstore/boot logs, boot backups and chat exports. No complete private conversation is uploaded. Local reports remain outside the public repository. See `PRIVACY.md`.
