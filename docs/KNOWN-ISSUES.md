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

## Fixed / historical incidents

| Issue | Finding and resolution |
| --- | --- |
| Early Konoha attempt | Wrong vendor module ABI for the tested ROM; current kernel uses the Onyx source instead |
| External adapter restarts | Driver CFI/disconnect/TX tasklet issues were fixed; separate USB HAL authorization/reconnect interference addressed by native guard |
| USB guard old path | Hardcoded historical directory caused lock open failure on another tester's installation; fixed package path handling and adapter inclusion; tester reported working |
| Internal monitor lacked TX | Stock monitor netdev had no TX hook; adapted injection patch and verified compiled TX path/import CRCs |
| Normal Wi-Fi broke with initial injection patch | Unconditional station/monitor concurrency capability override changed normal firmware policy; limit override to monitor mode |
| Real cfg80211 warning at unload | Android scan-always could remain active; quiesce Wi-Fi+scan, stable idle before non-forced unload; two clean r2 boots followed |
| Runtime checksum failed | KernelSU removes installer-only `customize.sh`; runtime manifest now excludes it |
| Shell `svc` collision | Use native Android framework commands where required rather than BusyBox applet resolution |
| Missing HCI after Wi-Fi module update | Only VHCI had been packaged, standalone bridge absent; combined bridge restores Kali Start/Stop integration |
| VHCI immediate device-node check | Device node creation can lag module load; bounded wait added |
| SUSFS official-stable build | Official v3.4.2 kernel compiled, SUSFS LKM required six unexported symbols; abandoned, not shipped |

Do not label every reconnect/crash as the same bug without logs. A missing guard lockfile alone does not prove a kernel panic. No raw user reports/logs are needed in the public repo.
