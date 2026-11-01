"""Stage pinned official artwork plus our one-shot installer; no phone writes."""
from pathlib import Path
import hashlib, json, shutil, zipfile

BASE=Path(__file__).resolve().parents[1]
BRAND=BASE/'branding'
def build_assets():
    provenance=json.loads((BRAND/'provenance.json').read_text(encoding='utf-8'))
    for name in ('nethunter-bootanimation-original.zip','nethunter-wallpaper-original.png'):
        assert hashlib.sha256((BRAND/name).read_bytes()).hexdigest()==provenance[name]['sha256']
    stage=BRAND/'package'; stage.mkdir(exist_ok=True)
    with zipfile.ZipFile(BRAND/'nethunter-bootanimation-original.zip') as src, zipfile.ZipFile(stage/'bootanimation.zip','w',zipfile.ZIP_STORED) as dst:
        assert src.testzip() is None
        for name in sorted(src.namelist()):
            assert name=='desc.txt' or (name.startswith('part0/') and name.endswith('.jpg'))
            data=b'1280 2772 60\np 0 0 part0\n' if name=='desc.txt' else src.read(name)
            # Frames remain unmodified; centered on the onyx portrait canvas.
            info=zipfile.ZipInfo(name,(2026,10,31,0,0,0));info.compress_type=zipfile.ZIP_STORED
            dst.writestr(info,data)
    shutil.copyfile(BRAND/'nethunter-wallpaper-original.png',stage/'wallpaper.png')
    for name in ('wallpaper-helper.jar','wallpaper-once.sh','install-recovery.sh','UPSTREAM-LICENSE','provenance.json'):
        shutil.copyfile(BRAND/name,stage/name)
    shutil.copyfile(BASE/'installer/CREDITS.txt',stage/'CREDITS.txt')
    for path in stage.glob('*.sh'):
        path.write_bytes(path.read_bytes().replace(b'\r\n',b'\n'))
    def manifest(names):
        return ''.join(hashlib.sha256((stage/n).read_bytes()).hexdigest()+'  '+n+'\n' for n in sorted(names))
    (stage/'WALLPAPER_SHA256SUMS').write_text(manifest(['wallpaper.png','wallpaper-helper.jar']),encoding='ascii',newline='\n')
    names=sorted(p.name for p in stage.iterdir() if p.is_file() and p.name!='SHA256SUMS')
    (stage/'SHA256SUMS').write_text(manifest(names),encoding='ascii',newline='\n')
    return {'branding/'+p.name:p.read_bytes() for p in stage.iterdir() if p.is_file()}

if __name__=='__main__':
    result=build_assets()
    print('BRANDING_ASSETS_STAGED',len(result))
