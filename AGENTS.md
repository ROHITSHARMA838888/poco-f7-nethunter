# Agent instructions

Read `docs/HANDOVER.md`, `docs/BUILDING.md`, `docs/KNOWN-ISSUES.md` and `SOURCE.md` before changing code. This is POCO F7 / onyx only. The actual release kernel is **not Konoha**.

- Preserve the working v0.2.0 release. Work on a `codex/` branch; do not rewrite old commits/tags or silently replace release assets.
- Never infer runtime support from a successful compile, matching version string or installer acceptance. Keep exact Image, config, symbol CRC and dependency hashes in evidence.
- Do not force-load modules, alter CRCs, disable CFI/KASAN, suppress real kernel warnings or remove compatibility guards merely to obtain a passing build.
- No phone flash/reboot, radio disruption or deployment without the owner's task authorization. Stop after an unexpected device/build failure, explain it and obtain authorization before a fix/retry. Mandatory cleanup/restoration still runs.
- Respect that the owner's only phone may provide the PC's internet. Target only specifically authorized owned lab APs/clients. Never run nearby-network attacks or unattended radio tests at boot.
- Back up working module/kernel before install. Keep Android settings restoration, session ownership checks and bounded timeouts. Stop monitor and Kali Bluetooth sessions before reboot.
- Do not revive the abandoned SUSFS experiment. The shipped kernel still uses the original pinned KernelSU Next source. Upgrading it is a separately tested change.
- Do not promise Play Integrity/banking-app success, universal ROM support, Bluetooth HID or every Bluetooth attack.
- Original licences, copyright notices and corresponding-source links must remain. Sources/build scripts stay public; do not hide implementation for exclusivity.
- Never commit tokens, private keys, Wi-Fi passwords, device serials, user MAC/IP addresses, raw phone logs, crash dumps, boot backups, browser/session data or complete private chat exports. Use `.private/` or an external private store. `.gitignore` is not encryption and does not remove existing Git history.
- Releases require a concrete reviewable result and the owner's final publish approval. Do not bypass branch-review rules without explicit owner authorization; do not weaken repository settings.
- Update `docs/HANDOVER.md`, `docs/KNOWN-ISSUES.md`, `CHANGELOG.md`, `SOURCE.md` and package metadata when behavior changes. Keep old and new version sections separate on the homepage and release page.

These are project practices; the current user's explicit instructions take precedence.
