"""Build local test packages and exercise installer guards with host-only mocks."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import struct
import subprocess
import tempfile
import zipfile
import runpy
import argparse

BASE = Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--verified-identity-build',action='store_true')
args=parser.parse_args()
UP = BASE / 'installer-upstream'
OUT = BASE / 'testing-packages'
(BASE / 'installer-validation').mkdir(exist_ok=True)
TEST = Path(tempfile.mkdtemp(prefix='guards-', dir=BASE / 'installer-validation'))
FILES = BASE / 'build-evidence/rom-root-40863319425/files'
PIN = '41f04bdb4ee30a44e429c2c1131d5e8bb32b15f1'
IMAGE_HASH = '2f26ba841a9b3094943a06c60047a999cafd75a2a484670fbeb0cf0ab19c00f6'
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=UP,text=True).strip()==PIN
assert hashlib.sha256((FILES/'Image').read_bytes()).hexdigest()==IMAGE_HASH
image_path=FILES/'Image'
version='v0.1.0-test'
build_run=40863319425
if args.verified_identity_build:
    candidate=BASE/'build-evidence/branded-41207879867'
    checked=json.loads((BASE/'rom-inspection/branded-41207879867-byte-report.json').read_text(encoding='utf-8'))
    abi=json.loads((BASE/'rom-inspection/branded-41207879867-abi-report.json').read_text(encoding='utf-8'))
    assert checked['passed'] and not checked['errors']
    assert abi['summary']['modules']==959 and abi['summary']['modules_with_crc_mismatch']==0
    assert not abi['summary']['not_in_kernel_or_crc_matched_rom_providers']
    for name in ('Module.symvers','resolved.config'):
        assert (candidate/'evidence'/name).read_bytes()==(BASE/'build-evidence/rom-root-40863319425/evidence'/name).read_bytes()
    assert 'Rohit-Sharma@Built-for-NetHunter-Rebuilt-from-Onyx' in checked['image']['banner']
    image_path=candidate/'runtime-files/Image'
    IMAGE_HASH=checked['image']['sha256']
    assert hashlib.sha256(image_path.read_bytes()).hexdigest()==IMAGE_HASH
    version='v0.1.2-test'
    build_run=41207879867
OUT.mkdir(exist_ok=True)
TEST.mkdir(exist_ok=True)
script=(BASE/'installer/anykernel.sh').read_bytes().replace(b'\r\n',b'\n')
script=script.replace(b'v0.1.0-test',version.encode())
payload={}
paths=subprocess.check_output(['git','ls-tree','-r','--name-only',PIN,'tools','META-INF','LICENSE'],cwd=UP,text=True).splitlines()
for name in paths:
    payload[name]=subprocess.check_output(['git','show',f'{PIN}:{name}'],cwd=UP)
assert 'LICENSE' in payload and 'tools/magiskboot' in payload
# The stock backend launches a separate ash for anykernel.sh. Export its
# BOOTMODE value so the recovery-only guard can see the detected mode.
entry='META-INF/com/google/android/update-binary'
assert payload[entry].count(b'\nBOOTMODE=false;') == 1
payload[entry]=payload[entry].replace(b'\nBOOTMODE=false;', b'\nexport BOOTMODE=false;')
# Kernel-only replacement never uses the old kernel or a boot ramdisk. Avoid
# needlessly decompressing the outgoing gzip kernel; the exact new Image is
# independently validated and repack preserves the template compression.
core='tools/ak3-core.sh'
assert payload[core].count(b'magiskboot unpack -h $BOOTIMG') == 1
payload[core]=payload[core].replace(b'magiskboot unpack -h $BOOTIMG',b'magiskboot unpack -n -h $BOOTIMG')
# This onyx target runs arm64-only Android. The AK3 default binaries are ARM32.
# Use official, digest-pinned Magisk ARM64 tools, and omit unused ARM32 helpers
# for dynamic/system partitions; this installer calls only split_boot/flash_boot.
apk=BASE/'installer-tools/Magisk-v31.1.apk'
assert hashlib.sha256(apk.read_bytes()).hexdigest()=='89cefac0a318afa39fb3880c45c87b036c05bc1ebf02a7a715b7f8d7c26ac6e7'
for name in ('fec','httools_static','lptools_static','snapshotupdater_static'):
    del payload['tools/'+name]
with zipfile.ZipFile(apk) as z:
    for name in ('busybox','magiskboot','magiskpolicy'):
        b=z.read('lib/arm64-v8a/lib'+name+'.so')
        assert b[:5]==b'\x7fELF\x02' and struct.unpack_from('<H',b,18)[0]==183
        payload['tools/'+name]=b
payload['MAGISK-LICENSE']=(BASE/'installer-tools/Magisk-v31.1-LICENSE').read_bytes()
assert b'GNU GENERAL PUBLIC LICENSE' in payload['MAGISK-LICENSE']
payload['TOOL-PROVENANCE.json']=(json.dumps({
    'url':'https://github.com/topjohnwu/Magisk/releases/tag/v31.1',
    'apk_sha256':hashlib.sha256(apk.read_bytes()).hexdigest(),
    'tools':{n:hashlib.sha256(payload['tools/'+n]).hexdigest() for n in ('busybox','magiskboot','magiskpolicy')},
    'architecture':'AArch64',
    'script_changes':['export BOOTMODE to installer child shell','kernel-only split_boot unpack -n retains outgoing compression without decoding unused old kernel'],
    'omitted_unused_arm32_tools':['fec','httools_static','lptools_static','snapshotupdater_static'],
},indent=2)+'\n').encode()
payload['anykernel.sh']=script
payload['CREDITS.txt']=(BASE/'installer/CREDITS.txt').read_bytes()
payload.update(runpy.run_path(str(BASE/'branding/build_assets.py'))['build_assets']())
payload['Image']=image_path.read_bytes()
payload['INSTALLER-NOTES.txt']=f'''Onyx NetHunter {version} | Rohit Sharma
Poco F7 onyx; Infinity-X Android17 build1792766195 only.
Kernel build{build_run}, Image SHA256 {IMAGE_HASH}.
Official AnyKernel3 source pin {PIN}.
ARM64 busybox/magiskboot/magiskpolicy from official Magisk v31.1;
see TOOL-PROVENANCE.json and MAGISK-LICENSE. Magisk app is NOT installed.
Backend BOOTMODE is explicitly exported to the separate installer shell.
Kernel-only split_boot retains compressed outgoing kernel; no ramdisk unpack.
Recovery-only, active boot slot only, header-v4/no boot ramdisk/no GKI signature.
Refuses reported locked bootloader. The owner's original kernel-only installer
was installed and booted successfully, with actual fastboot unlock verified.
THIS REPACKAGED THEME INSTALLER HAS NOT YET BEEN RECOVERY-TESTED OR FLASHED.
Wi-Fi drivers use the separate matching KernelSU module.
Official NetHunter boot animation and wallpaper are bundled in this kernel ZIP.
No additional theme module: recovery replaces /system/media/bootanimation.zip
only after verifying a linear (non-verity), writable ext4 active-system mapping.
Original animation is backed up under /data/adb/onyx-branding and the initial
system mount mode is restored. Refuses EROFS/verity/unknown mapping.
An existing KernelSU Next service.d hook sets the home wallpaper once through
Android's API, after owner-user unlock. No lock wallpaper change is requested.
Original wallpaper files are backed up privately. The wallpaper hook is not a
KernelSU module and does not continually overwrite later wallpaper choices.
init_boot, vendor_boot, DTB and vbmeta partitions are not selected for writing.
Theme helper's read-only API check passed on the phone; actual application and
boot animation rendering remain untested. Keep this package marked test-only.
User reports owning a backup of their current custom kernel.
Kernel source: https://github.com/xiaomi-onyx-playground/android_kernel_xiaomi_sm8735/tree/7750565ada3d57e195798519b005d2b038e888c1
KernelSU Next: https://github.com/KernelSU-Next/KernelSU-Next/tree/b427a3f9c2421a443f961007bfce66b25486643f
'''.encode()
payload['SHA256SUMS']=''.join(f'{hashlib.sha256(data).hexdigest()}  {name}\n' for name,data in sorted(payload.items())).encode()
def write_zip(path, entries):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for name,data in sorted(entries.items()):
            i=zipfile.ZipInfo(name,date_time=(2026,10,29,0,0,0));i.create_system=3
            mode=0o755 if name.startswith('tools/') or name in ('anykernel.sh','META-INF/com/google/android/update-binary') else 0o644
            i.external_attr=(0o100000|mode)<<16;i.compress_type=zipfile.ZIP_DEFLATED
            z.writestr(i,data)
    with zipfile.ZipFile(path) as z:
        assert z.testzip() is None
        assert 'boot.img' not in z.namelist() and 'init_boot.img' not in z.namelist()
    return {'path':str(path),'bytes':path.stat().st_size,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}

installer=write_zip(OUT/f'Onyx-NetHunter-{version}-Rohit-Sharma.zip',payload)

# Separate recovery trial: same guards/unpack, but NO call to flash_boot.
assert script.count(b'\nflash_boot;') == 1
check_script=script.replace(b'\nflash_boot;', b'\nui_print "CHECK_ONLY_PASS: no flash performed.";\nexit 0;')
assert b'\nflash_boot;' not in check_script
check_payload=dict(payload)
check_payload['anykernel.sh']=check_script
check_payload['INSTALLER-NOTES.txt']=b'CHECK ONLY: validates ROM/slot/boot state and reads/unpacks active boot into temporary files. Never calls flash_boot. AK3 backend sets up temporary recovery environment and ROM mounts. Not an installation.\n'
del check_payload['SHA256SUMS']
check_payload['SHA256SUMS']=''.join(f'{hashlib.sha256(data).hexdigest()}  {name}\n' for name,data in sorted(check_payload.items())).encode()
check_zip=write_zip(OUT/f'Onyx-NetHunter-{version}-BRANDING-CHECK-NO-FLASH.zip',check_payload)
drivers={p.name:p.read_bytes() for p in FILES.glob('*.ko')}
assert len(drivers)==6
drivers['README.txt']=b'Driver payload only. No automatic installer or loader. Requires the matching kernel40863319425; ath9k_htc firmware is separate. WN722N hardware revision and runtime operation are unverified.\n'
drivers['SHA256SUMS']=''.join(f'{hashlib.sha256(b).hexdigest()}  {n}\n' for n,b in sorted(drivers.items())).encode()
driver_zip=write_zip(OUT/'onyx-40863319425-driver-payload.zip',drivers)

# All following operations run in ordinary host folders, not on the phone.
mock='''AKHOME="$PWD"; BOOTIMG="$PWD/boot.img"; SLOT="$MOCK_SLOT";
BLOCK="${MOCK_BLOCK:-/dev/block/by-name/boot$SLOT}";
abort() { echo "ABORT:$*"; exit 1; }
ui_print() { printf '%s\\n' "$*"; }
getprop() { case "$1" in ro.product.device) echo "$MOCK_DEVICE";; ro.boot.flash.locked) echo "$MOCK_LOCK";; ro.boot.vbmeta.device_state) echo "$MOCK_STATE";; ro.boot.verifiedbootstate) echo "$MOCK_VERIFIED";; esac; }
cat() { if [ "$1" = /proc/bootconfig ]; then printf '%s\\n' "$MOCK_BOOTCONFIG"; else command cat "$@"; fi; }
file_getprop() { case "$2" in ro.build.version.incremental) echo "$MOCK_ROM";; ro.build.version.sdk) echo "$MOCK_SDK";; ro.build.version.security_patch) echo "$MOCK_PATCH";; esac; }
split_boot() { cp fixture.img "$BOOTIMG" || abort "fixture copy"; }
flash_boot() { echo "MOCK_ONLY:$BLOCK" >> trace.log; }
sh() {
  if [ "$1" = "$AKHOME/branding/install-recovery.sh" ]; then
    [ "${MOCK_BRANDING_FAIL:-0}" != 1 ] || return 1;
    echo "MOCK_BRANDING:$3"; return 0;
  fi;
  command sh "$@";
}
'''
rom=BASE/'rom-inspection/partitions/boot.img'
with rom.open('rb') as f: fixture=f.read(4096)
assert fixture[:8]==b'ANDROID!' and struct.unpack_from('<I',fixture,40)[0]==4
assert struct.unpack_from('<I',fixture,12)[0]==0 and struct.unpack_from('<I',fixture,1580)[0]==0
assert len(payload['Image'])+4096<rom.stat().st_size
cases=[('slot_a',{'MOCK_SLOT':'_a'},True),('slot_b',{},True),('dry_run',{},True),
       ('branding_preflight_failure',{'MOCK_BRANDING_FAIL':'1'},False),
       ('wrong_device',{'MOCK_DEVICE':'other'},False),('locked',{'MOCK_LOCK':'1'},False),
       ('locked_state',{'MOCK_STATE':'locked'},False),
       ('missing_lock',{'MOCK_LOCK':''},False),('missing_state',{'MOCK_STATE':''},False),
       ('unknown_state',{'MOCK_STATE':'unknown'},False),
       ('recovery_orange',{'MOCK_LOCK':'','MOCK_STATE':'','MOCK_BOOTCONFIG':'androidboot.verifiedbootstate = "orange"'},True),
       ('locked_orange',{'MOCK_LOCK':'1','MOCK_BOOTCONFIG':'androidboot.verifiedbootstate = "orange"'},False),
       ('state_locked_orange',{'MOCK_STATE':'locked','MOCK_BOOTCONFIG':'androidboot.verifiedbootstate = "orange"'},False),
       ('recovery_green',{'MOCK_LOCK':'','MOCK_STATE':'','MOCK_BOOTCONFIG':'androidboot.verifiedbootstate = "green"'},False),
       ('recovery_duplicate',{'MOCK_LOCK':'','MOCK_STATE':'','MOCK_BOOTCONFIG':'androidboot.verifiedbootstate = "orange"\nandroidboot.verifiedbootstate = "green"'},False),
       ('recovery_malformed',{'MOCK_LOCK':'','MOCK_STATE':'','MOCK_BOOTCONFIG':'other.androidboot.verifiedbootstate = "orange"'},False),
       ('conflicting_verified',{'MOCK_VERIFIED':'green','MOCK_BOOTCONFIG':'androidboot.verifiedbootstate = "orange"'},False),
       ('wrong_rom',{'MOCK_ROM':'other'},False),
       ('wrong_sdk',{'MOCK_SDK':'36'},False),('bad_slot',{'MOCK_SLOT':'_c'},False),
       ('wrong_patch',{'MOCK_PATCH':'2026-09-01'},False),('missing_patch',{'MOCK_PATCH':''},False),
       ('wrong_partition',{'MOCK_BLOCK':'/dev/block/by-name/init_boot_b'},False),
       ('android_booted',{'BOOTMODE':'true'},False),('header3',{},False),
       ('bad_magic',{},False),('header_size',{},False),('truncated_header',{},False),
       ('ramdisk',{},False),('signature',{},False),('bad_hash',{},False)]
results=[]
bash=r'C:\Program Files\Git\bin\bash.exe'
for name,changes,success in cases:
    d=TEST/name;d.mkdir(exist_ok=False);(d/'tools').mkdir()
    (d/'anykernel.sh').write_bytes(check_script if name=='dry_run' else script);(d/'tools/ak3-core.sh').write_text(mock,encoding='utf-8',newline='\n')
    if name=='bad_hash': (d/'Image').write_bytes(b'invalid')
    else: os.link(image_path,d/'Image')
    (d/'SHA256SUMS').write_text(f'{IMAGE_HASH}  Image\n',encoding='ascii',newline='\n')
    b=bytearray(fixture)
    if name=='header3':struct.pack_into('<I',b,40,3)
    if name=='bad_magic':b[:8]=b'INVALID!'
    if name=='header_size':struct.pack_into('<I',b,20,1580)
    if name=='ramdisk':struct.pack_into('<I',b,12,8)
    if name=='signature':struct.pack_into('<I',b,1580,4096)
    if name=='truncated_header':b=b[:1580]
    (d/'fixture.img').write_bytes(b)
    env=os.environ.copy();env.update({'MOCK_SLOT':'_b','MOCK_DEVICE':'onyx','MOCK_LOCK':'0','MOCK_STATE':'unlocked','MOCK_VERIFIED':'','MOCK_BOOTCONFIG':'','MOCK_ROM':'1792766195','MOCK_SDK':'37','MOCK_PATCH':'2026-10-01','BOOTMODE':'false'});env.update(changes)
    run=subprocess.run([bash,'--noprofile','--norc','anykernel.sh'],cwd=d,env=env,text=True,capture_output=True)
    reached=(d/'trace.log').exists()
    assert (run.returncode==0)==success and reached==(success and name!='dry_run'),(name,run.stdout,run.stderr)
    if name=='dry_run':assert 'CHECK_ONLY_PASS' in run.stdout
    if not success:
        expected = {
            'branding_preflight_failure':'Branding preflight failed',
            'wrong_device':'Only onyx', 'locked':'invalid lock state', 'missing_lock':'unlock evidence',
            'locked_state':'invalid device state', 'missing_state':'unlock evidence',
            'unknown_state':'invalid device state', 'wrong_rom':'verified Infinity-X',
            'locked_orange':'invalid lock state', 'state_locked_orange':'invalid device state',
            'recovery_green':'unlock evidence', 'recovery_duplicate':'unlock evidence',
            'recovery_malformed':'unlock evidence', 'conflicting_verified':'Conflicting verified boot',
            'wrong_sdk':'SDK mismatch', 'bad_slot':'Invalid active slot',
            'wrong_patch':'ROM security patch', 'missing_patch':'ROM security patch',
            'wrong_partition':'Unexpected target partition', 'android_booted':'Recovery installation only',
            'header3':'Only boot header v4', 'bad_magic':'Unknown boot image magic',
            'header_size':'Unexpected boot v4 header size', 'truncated_header':'Signed GKI boot layout',
            'ramdisk':'Unexpected boot ramdisk', 'signature':'Signed GKI boot layout',
            'bad_hash':'integrity check failed',
        }[name]
        assert any(line.startswith('ABORT:') and expected in line for line in run.stdout.splitlines()), (name, run.stdout, run.stderr)
    if reached:assert (d/'trace.log').read_text().strip()==f'MOCK_ONLY:/dev/block/by-name/boot{env["MOCK_SLOT"]}'
    results.append({'case':name,'expected_success':success,'passed':True})
report={'installer':installer,'recovery_check_no_flash':check_zip,'drivers':driver_zip,'guard_tests':results,
        'kernel_build_run':build_run,'image_sha256':IMAGE_HASH,
        'scope':'Host mocked guards/ZIP integrity/ROM header and size checks only. No actual repack, recovery install or phone writes.'}
(TEST/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
(BASE/'installer-validation/report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
if args.verified_identity_build:
    (BASE/'installer-validation/branded-41207879867-package-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2))
