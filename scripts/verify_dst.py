"""Independent reader compatibility check; requires pyembroidery==1.5.1.
No machine is controlled. This checks records, positions, commands and extents.
"""
import json
import argparse
from importlib.metadata import version
from pathlib import Path
import xml.etree.ElementTree as ET
import pyembroidery as emb

reader_version = version('pyembroidery')
if reader_version != '1.5.1':
    raise SystemExit(f'Expected pyembroidery 1.5.1, found {reader_version}; install the pinned reader before verification')

root = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser()
parser.add_argument('--directory', type=Path, default=root / 'outputs')
directory = parser.parse_args().directory
records = []
for name in ['outline', 'satin', 'patch']:
    report = json.loads((directory / (name + '.json')).read_text())
    expected = report['commands']
    mapping = {'stitch': emb.STITCH, 'jump': emb.JUMP, 'color': emb.COLOR_CHANGE, 'end': emb.END}
    # The reader may infer trims from repeated jumps. Disable inference so this
    # check compares actual DST records with our intended command list.
    pattern = emb.read_dst(str(directory / (name + '.dst')), settings={'trim_at': None, 'trim_distance': None, 'clipping': False})
    assert len(pattern.stitches) == len(expected), (name, len(pattern.stitches), len(expected))
    for got, want in zip(pattern.stitches, expected):
        assert got[:2] == [want['x'], want['y']], (name, got, want)
        assert got[2] & emb.COMMAND_MASK == mapping[want['kind']], (name, got, want)
    data = (directory / (name + '.dst')).read_bytes()
    header = data[:512].decode('ascii')
    fields = dict(line.split(':', 1) for line in header.split('\r') if ':' in line)
    assert int(fields['ST']) == len(expected)
    assert int(fields['CO']) == report['color_changes']
    xs = [0] + [c['x'] for c in expected]; ys = [0] + [c['y'] for c in expected]
    assert int(fields['+X']) == max(xs) and int(fields['-X']) == -min(xs)
    assert int(fields['+Y']) == max(ys) and int(fields['-Y']) == -min(ys)
    ET.parse(directory / (name + '.svg'))
    records.append({'name': name, 'decoded_records': len(expected), 'stitches': report['stitches'],
                    'jumps': report['jumps'], 'color_changes': report['color_changes'],
                    'positions_equal': True, 'commands_equal': True, 'header_extents_equal': True})
print(json.dumps({'reader': 'pyembroidery', 'reader_version': reader_version, 'cases': records,
                  'physical_machine_test': False}, indent=2))
