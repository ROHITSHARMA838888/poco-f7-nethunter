"""Package the runtime-tested Archer and WN722N fixes without replacing the old candidate."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

BASE = Path(__file__).resolve().parents[1]
ROOT = BASE / 'root-setup/persistent-module-v0.1.2'
OLD = BASE / 'root-setup/persistent-module'
STATE = '/data/adb/onyx-drivers-41316130882-v012'
EXPECTED = {
    '88XXau.ko': 'eb5e3dc0ff366dd04cb1984922d403a1cfc76b354f764753bebfa6ae194e499a',
    '8188eu.ko': '44a9160029c9fd3e7a40d58cb6e789a037736c416e5411c471495dacb0bd8c37',
}

def digest(data):
    return hashlib.sha256(data).hexdigest()

proof = json.loads((BASE / 'root-setup/archer-tx-fix-runtime/fixed-tx-verification.json').read_text(encoding='utf-8'))
assert proof['probe_injection_passed'] and proof['boot_id_unchanged']
assert proof['module_sha256'] == EXPECTED['88XXau.ko']
wn_proof = json.loads((BASE / 'root-setup/wn722n-v011-validation/monitor-led-fixed-load/tx-verification.json').read_text(encoding='utf-8'))
assert wn_proof['probe_injection_passed'] and wn_proof['boot_unchanged']
assert wn_proof['module_sha256'] == EXPECTED['8188eu.ko']
shutil.copytree(OLD, ROOT, dirs_exist_ok=True)
shutil.copyfile(BASE / 'build-evidence/archer-tx-fix-41297489306/candidate/88XXau.ko', ROOT / 'drivers/88XXau.ko')
shutil.copyfile(BASE / 'build-evidence/wn722n-monitor-led-41316130882/candidate/8188eu.ko', ROOT / 'drivers/8188eu.ko')
for name, expected in EXPECTED.items():
    assert digest((ROOT / 'drivers' / name).read_bytes()) == expected
for name in ('customize.sh', 'service.sh', 'uninstall.sh', 'payload/load-drivers.sh'):
    path = ROOT / name
    text = (OLD / name).read_text(encoding='utf-8').replace('/data/adb/onyx-drivers-40863319425', STATE)
    if name == 'customize.sh':
        text = text.replace('module v0.1.0', 'module v0.1.2')
    if name == 'payload/load-drivers.sh':
        original = '    insmod "./$name.ko" || { echo "LOAD_FAILED:$name"; exit 1; }'
        assert text.count(original) == 1
        text = text.replace(original, '''    if [ "$name" = 88XXau ]; then
      insmod "./$name.ko" rtw_drv_log_level=1 || { echo "LOAD_FAILED:$name"; exit 1; }
    else
      insmod "./$name.ko" || { echo "LOAD_FAILED:$name"; exit 1; }
    fi''')
    path.write_text(text, encoding='utf-8', newline='\n')
prop = (OLD / 'module.prop').read_text(encoding='utf-8')
prop = prop.replace('version=40863319425-2', 'version=v0.1.2-dual-wifi-fix').replace('versionCode=2', 'versionCode=4')
prop = prop.replace('description=', 'description=Archer and WN722N callback fixes, WN monitor-state fix and LED support; each passed one owned-hotspot probe test (29/30 replies), no reboot. ')
(ROOT / 'module.prop').write_text(prop, encoding='utf-8', newline='\n')
readme = (OLD / 'README.txt').read_text(encoding='utf-8').replace('/data/adb/onyx-drivers-40863319425', STATE)
readme = readme[:readme.index('Previous nethunter_wireless_drivers')]
readme += '''Version v0.1.2: Archer fix from run41297489306; WN722N callback, monitor-state
and LED fixes from run41316130882.
CFI/KCFI and KASAN remain enabled. Kernel Image is unchanged.
Both adapters: attach, monitor DOWN/UP transitions and one bounded probe injection test each
passed on the author's phone (29/30 directed replies, no reboot). This is not
long-term stability or all-ROM qualification. WN722N LED operation was confirmed
and no new kernel warnings were found in its final monitor and probe tests.

Install ONLY using KernelSU Next Manager on the exact matching onyx kernel.
Updating the same module ID takes effect after reboot; do not manually run its
service while the previous guard is running. Remove external adapters before
reboot. The original private payload remains at /data/adb/onyx-drivers-40863319425.
To roll back, reinstall the saved v0.1.1 module ZIP in KernelSU and reboot with
adapters disconnected. Do not enable an unrelated or absent legacy module.
Disable this module in KernelSU to stop its next-boot autoload. Keep a known-good
boot backup and recovery access. No boot partition is written by this module.
'''
(ROOT / 'README.txt').write_text(readme, encoding='utf-8', newline='\n')
credits = (OLD / 'CREDITS.txt').read_text(encoding='utf-8')
credits += '\nWi-Fi v0.1.2: callback compatibility fixes for pinned aircrack-ng rtl8812au and rtl8188eus; WN monitor-state handling and software LED support.\nBuild evidence: https://github.com/ROHITSHARMA838888/poco-f7-nethunter/actions/runs/41297489306\n'
credits += '\nWN build evidence: https://github.com/ROHITSHARMA838888/poco-f7-nethunter/actions/runs/41316130882\n'
(ROOT / 'CREDITS.txt').write_text(credits, encoding='utf-8', newline='\n')
assert (ROOT / 'bin/usb-auth-guard').read_bytes() == (OLD / 'bin/usb-auth-guard').read_bytes()
payload = ''.join(EXPECTED[n] + '  ' + n + '\n' for n in ('88XXau.ko', '8188eu.ko'))
payload += digest((ROOT / 'payload/load-drivers.sh').read_bytes()) + '  load-drivers.sh\n'
(ROOT / 'payload/SHA256SUMS').write_text(payload, encoding='ascii', newline='\n')
runtime = ['module.prop', 'service.sh', 'uninstall.sh', 'skip_mount', 'README.txt', 'CREDITS.txt', 'DRIVER-LICENSE', 'bin/usb-auth-guard', 'drivers/88XXau.ko', 'drivers/8188eu.ko', 'payload/load-drivers.sh', 'payload/SHA256SUMS']
def manifest(names):
    return ''.join(digest((ROOT / n).read_bytes()) + '  ' + n + '\n' for n in sorted(names))
(ROOT / 'GUARD_SHA256SUMS').write_text(manifest(runtime), encoding='ascii', newline='\n')
names = runtime + ['GUARD_SHA256SUMS', 'customize.sh']
(ROOT / 'PACKAGE_SHA256SUMS').write_text(manifest(names), encoding='ascii', newline='\n')
names += ['PACKAGE_SHA256SUMS']
target = BASE / 'testing-packages/Onyx-NetHunter-WiFi-v0.1.2-KernelSU.zip'
with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
    for name in sorted(names):
        entry = zipfile.ZipInfo(name, date_time=(2026, 11, 1, 0, 0, 0))
        entry.create_system = 3
        entry.external_attr = (0o100000 | (0o755 if name.endswith('.sh') or name == 'bin/usb-auth-guard' else 0o644)) << 16
        entry.compress_type = zipfile.ZIP_DEFLATED
        archive.writestr(entry, (ROOT / name).read_bytes())
with zipfile.ZipFile(target) as archive:
    assert archive.testzip() is None
    assert set(archive.namelist()) == set(names)
    for manifest_name in ('GUARD_SHA256SUMS', 'PACKAGE_SHA256SUMS'):
        for line in archive.read(manifest_name).decode('ascii').splitlines():
            sha, name = line.split('  ', 1)
            assert digest(archive.read(name)) == sha
    for name, expected in EXPECTED.items():
        assert digest(archive.read('drivers/' + name)) == expected
    assert not any(n.startswith('system/') or n.endswith('.img') for n in names)
report = {'path': str(target), 'bytes': target.stat().st_size, 'sha256': digest(target.read_bytes()), 'payload_directory': STATE, 'old_payload_preserved': True, 'phone_installed': False, 'published': False, 'archive_and_manifests_verified': True}
(BASE / 'root-setup/module-v012-package-report.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
print(json.dumps(report, indent=2))
