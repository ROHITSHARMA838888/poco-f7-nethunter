"""Repair pinned WN722N Linux callback types without disabling KCFI."""
from pathlib import Path
import sys

root = Path(sys.argv[1])

def change(relative, before, after, count=1):
    path = root / relative
    text = path.read_text(encoding='utf-8')
    assert text.count(before) == count, (relative, before, text.count(before))
    path.write_text(text.replace(before, after), encoding='utf-8', newline='\n')

for path in ('include/usb_ops_linux.h', 'os_dep/linux/usb_ops_linux.c'):
    change(path, 'usb_recv_tasklet(void *priv)', 'usb_recv_tasklet(unsigned long priv)', 2 if path.endswith('.c') else 1)
change('hal/hal_hci/hal_usb.c', '(void(*)(unsigned long))usb_recv_tasklet', 'usb_recv_tasklet')
for path in ('include/rtl8188e_xmit.h', 'hal/rtl8188e/usb/usb_ops_linux.c'):
    change(path, 'rtl8188eu_xmit_tasklet(void *priv)', 'rtl8188eu_xmit_tasklet(unsigned long priv)')
change('hal/rtl8188e/usb/rtl8188eu_xmit.c', '(void(*)(unsigned long))rtl8188eu_xmit_tasklet', 'rtl8188eu_xmit_tasklet')
change('core/mesh/rtw_mesh.c', 'mpath_tx_tasklet_hdl(void *priv)', 'mpath_tx_tasklet_hdl(unsigned long priv)')
change('core/mesh/rtw_mesh.c', '(void(*)(unsigned long))mpath_tx_tasklet_hdl', 'mpath_tx_tasklet_hdl')
# Linux ndo_start_xmit uses netdev_tx_t, skb* and net_device*, not int/void*.
change('include/xmit_osdep.h', 'extern int _rtw_xmit_entry(_pkt *pkt, _nic_hdl pnetdev);\nextern int rtw_xmit_entry(_pkt *pkt, _nic_hdl pnetdev);',
       'extern int _rtw_xmit_entry(_pkt *pkt, _nic_hdl pnetdev);\nextern netdev_tx_t rtw_xmit_entry(struct sk_buff *pkt, struct net_device *pnetdev);')
change('os_dep/linux/xmit_linux.c', '\nint rtw_xmit_entry(_pkt *pkt, _nic_hdl pnetdev)',
       '\nnetdev_tx_t rtw_xmit_entry(struct sk_buff *pkt, struct net_device *pnetdev)')
# Monitor is a valid interface mode, but has no associated station/AP to notify.
# Retain all hardware/disconnect cleanup and warnings for genuinely unknown states.
path = root / 'core/rtw_mlme_ext.c'
text = path.read_text(encoding='utf-8')
start = text.index('static void rtw_mlmeext_disconnect(_adapter *padapter)')
end = text.index('\n}', start) + 2
function = text[start:end]
before = 'else if (MLME_IS_NULL(padapter))\n\t\tself_action = MLME_ACTION_NONE;'
assert function.count(before) == 1
function = function.replace(before, 'else if (MLME_IS_NULL(padapter) || MLME_IS_MONITOR(padapter))\n\t\tself_action = MLME_ACTION_NONE;')
path.write_text(text[:start] + function + text[end:], encoding='utf-8', newline='\n')
change('include/autoconf.h', '/* #define CONFIG_RTW_LED */', '#define CONFIG_RTW_LED')
print('WN722N_CALLBACK_TYPES_MONITOR_DISCONNECT_AND_LED_FIXED; KCFI retained')
