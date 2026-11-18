# Known issues and historical fixes

## Open issues / limitations

- **Banking / Play Integrity:** unresolved. Root, unlocked bootloader, ROM certification and hooking modules may all affect detection. No paid-keybox or banking-success claim.
- **Legacy monitor state after reboot:** old helper state has no boot-ID record. A leftover `/data/adb/onyx-monitor-session` can make the internal loader stop with `monitor_session_exists`. The observed stale state was archived after proving normal mode/no monitor interface; general automatic recovery is **not yet implemented**. Stop monitor before reboot. Do not delete a live session or bypass the guard.
- **Bluetooth HID:** Windows pairing/driver recognition remained unresolved. Bluetooth HCI UP or discovery is not proof of HID/all attacks support.
- **Bluetooth app integration:** actual Kali init-service path was tested; the app GUI button itself was not directly observed in that final test.
- **USB HID lifecycle:** harmless typing worked; fully automatic gadget activation/cleanup has race concerns. The daily Wi-Fi module does not configure the USB gadget automatically.
- **ROM compatibility:** latest runtime on Infinity-X 4.2; historical base on 4.1. Other ROMs / HyperOS / Android versions untested. Removed installer allowlists do not fix vendor ABI mismatches.
- **Exact v0.2.0 flash test:** pending; code17 metadata and r6 installer packaging differ from prior tested ZIPs even though Image/driver bytes are unchanged.
- **Source reproducibility:** workflow/source/ABI inputs and packaging are public; original Bluetooth dependency compiler/filesystem state is incompletely recorded. Functionally equivalent builds need tests; bit-identical source rebuild not promised.
