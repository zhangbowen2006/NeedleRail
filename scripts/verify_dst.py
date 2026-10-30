"""Independent reader compatibility check; requires pyembroidery==1.5.1.
No machine is controlled. This checks records, positions, commands and extents.
"""
import json
from pathlib import Path
import xml.etree.ElementTree as ET
import pyembroidery as emb

root = Path(__file__).resolve().parent.parent
records = []
for name in ['outline', 'satin', 'patch']:
    report = json.loads((root / 'outputs' / (name + '.json')).read_text())
    pattern = emb.read_dst(str(root / 'outputs' / (name + '.dst')))
    expected = report['commands']
    mapping = {'stitch': emb.STITCH, 'jump': emb.JUMP, 'color': emb.COLOR_CHANGE, 'end': emb.END}
    # The reader may infer trims from repeated jumps. Disable inference so this
    # check compares actual DST records with our intended command list.
    pattern = emb.read_dst(str(root / 'outputs' / (name + '.dst')), settings={'trim_at': None, 'trim_distance': None, 'clipping': False})
    assert len(pattern.stitches) == len(expected), (name, len(pattern.stitches), len(expected))
    for got, want in zip(pattern.stitches, expected):
        assert got[:2] == [want['x'], want['y']], (name, got, want)
        assert got[2] & emb.COMMAND_MASK == mapping[want['kind']], (name, got, want)
    data = (root / 'outputs' / (name + '.dst')).read_bytes()
    header = data[:512].decode('ascii')
    fields = dict(line.split(':', 1) for line in header.split('\r') if ':' in line)
    assert int(fields['ST']) == len(expected)
    assert int(fields['CO']) == report['color_changes']
    xs = [0] + [c['x'] for c in expected]; ys = [0] + [c['y'] for c in expected]
    assert int(fields['+X']) == max(xs) and int(fields['-X']) == -min(xs)
    assert int(fields['+Y']) == max(ys) and int(fields['-Y']) == -min(ys)
    ET.parse(root / 'outputs' / (name + '.svg'))
    records.append({'name': name, 'decoded_records': len(expected), 'stitches': report['stitches'],
                    'jumps': report['jumps'], 'color_changes': report['color_changes'],
                    'positions_equal': True, 'commands_equal': True, 'header_extents_equal': True})
print(json.dumps({'reader': 'pyembroidery', 'reader_version': '1.5.1', 'cases': records,
                  'physical_machine_test': False}, indent=2))
