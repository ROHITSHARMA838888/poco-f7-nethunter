"""Summarize compiler callback diagnostics and validate the audit module's CRCs.

This audit never loads a module, disables CFI, or modifies CRCs.
"""
from pathlib import Path
import argparse,hashlib,json,re

parser=argparse.ArgumentParser()
parser.add_argument('--require-clean-callbacks',action='store_true')
args=parser.parse_args()

out=Path('wn722n-evidence')
source=Path('external/rtl8188eus')
text=(out/'build.log').read_text(encoding='utf-8',errors='replace')
config=(out/'resolved.config').read_text(encoding='utf-8')
assert 'CONFIG_CFI_CLANG=y\n' in config
assert 'CONFIG_KASAN_HW_TAGS=y\n' in config
assert 'CONFIG_CFI_PERMISSIVE=y\n' not in config
assert '-fsanitize=kcfi' in text, 'Audit compile command did not show active KCFI'
assert '-fno-sanitize=kcfi' not in text, 'Do not bypass KCFI in this audit'
assert '-Wcast-function-type-strict' in text
assert 'void usb_recv_tasklet(unsigned long priv)' in (source/'os_dep/linux/usb_ops_linux.c').read_text()
assert 'netdev_tx_t rtw_xmit_entry(struct sk_buff *pkt, struct net_device *pnetdev)' in (source/'os_dep/linux/xmit_linux.c').read_text()
symbols={}
for line in (out/'Module.symvers').read_text().splitlines():
    c=line.split();symbols[c[1]]=int(c[0],16)
imports=[]
for line in (out/'imported-versions.txt').read_text().splitlines():
    c=line.split()
    if not c:continue
    crc=int(c[0],16);name=c[1]
    assert name in symbols and symbols[name]==crc, ('CRC/provider mismatch',name)
    imports.append(name)
assert imports and 'module_layout' in imports
diagnostics=[]
for line in text.splitlines():
    if re.search(r'warning:.*\[-W(?:cast-function-type|incompatible-function-pointer-types)',line):
        diagnostics.append(line)
assert not diagnostics, 'Callback cast diagnostics remain'
assert 'rtl8188eu_xmit_tasklet(unsigned long priv)' in (source/'hal/rtl8188e/usb/usb_ops_linux.c').read_text()
assert 'mpath_tx_tasklet_hdl(unsigned long priv)' in (source/'core/mesh/rtw_mesh.c').read_text()
report={
    'scope':'Off-device compiler/ABI audit only; NOT a reboot fix or runtime qualification',
    'runtime_protections_retained':['CFI/KCFI','KASAN_HW_TAGS','original ROM config'],
    'wn722n_callback_type_fixes_applied':True,
    'cast_diagnostic_count':len(diagnostics),
    'cast_diagnostics':diagnostics,
    'module_import_crcs_checked':len(imports),
    'module_sha256':hashlib.sha256((source/'8188eu.ko').read_bytes()).hexdigest(),
    'module_not_uploaded_for_install':False,
    'module_distribution_scope':'review_candidate_only',
    'phone_install_performed':False,
    'callback_type_fix_required':True,
    'limits':['Compiler cast warnings are findings to review, not proof of the phone reboot cause',
              'Zero warnings does not rule out use-after-free, firmware/power faults or other driver bugs',
              'No kernel Image rebuild, phone load, injection test or public Release performed'],
}
(out/'cfi-audit.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k!='cast_diagnostics'},indent=2))
