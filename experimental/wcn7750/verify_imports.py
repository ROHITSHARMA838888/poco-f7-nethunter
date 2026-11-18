from pathlib import Path
table = {}
for p in (Path('inherited-evidence/Module.symvers'), Path('experimental/wcn7750/infinity-wlan-extra.symvers')):
    for line in p.read_text().splitlines():
        fields = line.split()
        if len(fields) >= 2:
            crc, symbol = int(fields[0], 16), fields[1]
            assert symbol not in table or table[symbol] == crc, symbol
            table[symbol] = crc
imports = [line.split() for line in Path('wlan-evidence/imported-crcs.txt').read_text().splitlines()]
assert imports
for crc, symbol in imports:
    assert symbol in table and int(crc, 16) == table[symbol], symbol
print(f'All {len(imports)} imports match supplied Infinity kernel/vendor CRC inputs')
