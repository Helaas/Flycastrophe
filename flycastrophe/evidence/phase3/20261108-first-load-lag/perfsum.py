#!/usr/bin/env python3
"""Condense Flycastrophe perf lines: perfsum.py LOG [FIRST_LINE_INDEX] [COUNT]"""
import re
import sys

pat = re.compile(
    r'perf +(?P<t>[0-9.]+) s: vblank +(?P<vb>[0-9.]+)/s +(?P<pct>[0-9.]+)% lag +(?P<lag>[-0-9.]+) ms'
    r' \| rendered +(?P<rend>[0-9.]+)/s skipped +(?P<skip>[0-9.]+)/s'
    r' \| emu cpu +(?P<emu>[0-9]+)% waits +(?P<waits>[0-9]+)%'
    r' \| render cpu +(?P<rcpu>[0-9]+)% \| aica cpu +(?P<aica>[0-9]+)%'
    r' \| renders (?P<renders>[0-9]+) \(to textures (?P<rtt>[0-9]+)\) (?P<rms>[0-9.]+) ms max (?P<rmax>[0-9.]+)'
    r' \| textures updated (?P<tex>[0-9]+) \((?P<texkb>[0-9]+) KB, seen before (?P<again>[0-9]+)\)'
    r' \| compiled (?P<comp>[0-9]+) in (?P<compms>[0-9.]+) ms resets (?P<resets>[0-9]+)'
    r'.*late (?P<late>[0-9]+) max (?P<fmax>[0-9.]+) ms')
rows = []
for line in open(sys.argv[1], errors='replace'):
    m = pat.search(line)
    if m:
        rows.append(m.groupdict())
first = int(sys.argv[2]) if len(sys.argv) > 2 else 0
count = int(sys.argv[3]) if len(sys.argv) > 3 else len(rows)
cols = ['t', 'vb', 'lag', 'rend', 'skip', 'emu', 'rcpu', 'aica', 'rms', 'rmax', 'tex', 'texkb', 'again', 'comp', 'compms', 'late', 'fmax']
print(f'{len(rows)} lines')
print(' '.join(f'{c:>6}' for c in cols))
for r in rows[first:first + count]:
    print(' '.join(f'{r[c]:>6}' for c in cols))
