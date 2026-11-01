"""Fix real TX tasklet callback types; retain KCFI instead of casting it away."""
from pathlib import Path
import sys

root=Path(sys.argv[1])
for family in ('8812','8814'):
    name=f'rtl{family}au_xmit_tasklet'
    paths=(root/f'include/rtl{family}a_xmit.h',
           root/f'hal/rtl{family}a/usb/usb_ops_linux.c')
    before=f'{name}(void *priv)'
    after=f'{name}(unsigned long priv)'
    for path in paths:
        text=path.read_text(encoding='utf-8')
        assert text.count(before)==1,(str(path),'Unexpected pinned callback declaration')
        path.write_text(text.replace(before,after),encoding='utf-8',newline='\n')
    path=root/f'hal/rtl{family}a/usb/rtl{family}au_xmit.c'
    text=path.read_text(encoding='utf-8')
    before=f'(void(*)(unsigned long)){name}'
    assert text.count(before)==1,(str(path),'Unexpected pinned registration')
    path.write_text(text.replace(before,name),encoding='utf-8',newline='\n')
print('TX_TASKLET_TYPES_FIXED: declarations, definitions and registrations; no runtime CFI bypass')
