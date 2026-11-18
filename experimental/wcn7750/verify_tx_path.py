"""Verify compiled monitor TX wiring without requiring an optimizer-preserved helper name."""
from pathlib import Path
import json
import re
from elftools.elf.elffile import ELFFile
from elftools.elf.relocation import RelocationSection

evidence = Path('wlan-evidence')
ko = Path('compiled-wlan-NOT-FLASHABLE/qca_cld3_wcn7750.ko')
preprocessed = (evidence / 'wlan_hdd_tx_rx.i').read_text()
assert len(re.findall(r'\bhdd_monitor_mode_tx_inject\s*\(', preprocessed)) >= 2, 'Injection definition/call missing after preprocessing'
command = (evidence / 'wlan_hdd_tx_rx.cmd').read_text()
assert '-DFEATURE_FRAME_INJECTION_SUPPORT' in command, 'Injection compiler flag missing'
result = {'injection_preprocessed_definition_and_call': True, 'injection_compiler_flag': True,
          'monitor_ops': [], 'scope': 'Static compiled-path evidence only; no firmware/radio/runtime claim'}
with ko.open('rb') as stream:
    elf = ELFFile(stream)
    symbols = elf.get_section_by_name('.symtab')
    assert symbols is not None
    for sym in symbols.iter_symbols():
        if not sym.name.startswith('wlan_mon_drv_ops') or not isinstance(sym['st_shndx'], int):
            continue
        # ARM64 net_device_ops offset32 is ndo_start_xmit in this pinned kernel.
        matches = []
        for section in elf.iter_sections():
            if not isinstance(section, RelocationSection) or section['sh_info'] != sym['st_shndx']:
                continue
            table = elf.get_section(section['sh_link'])
            for relocation in section.iter_relocations():
                if relocation['r_offset'] == sym['st_value'] + 32:
                    target = table.get_symbol(relocation['r_info_sym'])
                    matches.append(target.name)
        assert any(name.startswith('hdd_hard_start_xmit') for name in matches), matches
        result['monitor_ops'].append({'name': sym.name, 'ndo_start_xmit_targets': matches})
assert result['monitor_ops'], 'Monitor netdev operations not found in compiled module'
(evidence / 'tx-path-verification.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
