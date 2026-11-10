#!/usr/bin/env python3
"""Summarize perf-run.sh logs (<game>-<label>-r<round>.log): per run, the mean emulated speed, frames
rendered a second, the emulation and render threads' CPU, the render time and the GL draws per render,
over the perf lines from T0 seconds on.

With EMU=a-b[,c-d] in the environment: also the speed over those spans of emulated time (seconds since
the first perf line), so runs at different speeds are compared on the same stretch of a game.

usage: [EMU=2-12] perfsum.py DIR [T0=3]"""
import collections
import glob
import os
import re
import statistics
import sys

d = sys.argv[1]
t0 = float(sys.argv[2]) if len(sys.argv) > 2 else 3.0
perf = re.compile(r'perf +([0-9.]+) s: vblank +([0-9.]+)/s +([0-9.]+)% .*?rendered +([0-9.]+)/s.*?emu cpu +([0-9]+)%'
                  r'.*?render cpu +([0-9]+)%.*?renders \d+ \(to textures \d+\) ([0-9.]+) ms.*?draws ([0-9.]+)')
runs = collections.defaultdict(list)
for path in sorted(glob.glob(os.path.join(d, '*.log'))):
    m = re.match(r'(.*)-([^-]+)-r(\d+)$', os.path.basename(path)[:-4])
    if not m:
        continue
    rows = [tuple(float(x) for x in p.groups()) for p in (perf.search(line) for line in open(path, errors='replace')) if p]
    runs[(m.group(1), m.group(2))].append(rows)
for (game, label), rr in sorted(runs.items()):
    for i, rows in enumerate(rr, 1):
        w = [p for p in rows if p[0] >= t0]
        if not w:
            print(f'{game:12} {label:8} r{i} no perf lines')
            continue
        mean = lambda k: statistics.mean(p[k] for p in w)
        out = (f'{game:12} {label:8} r{i} speed {mean(2):6.1f}% rendered {mean(3):6.2f}/s emu {mean(4):3.0f}% render {mean(5):3.0f}%'
               f' {mean(6):5.2f} ms draws {mean(7):5.0f}')
        for span in filter(None, os.environ.get('EMU', '').split(',')):
            a, b = (float(x) for x in span.split('-'))
            # the wall time at which the emulated clock (vblanks / 59.94) passes a and b
            emu = 0.0
            marks = {}
            prev = rows[0][0]
            for p in rows[1:]:
                dt = p[0] - prev
                step = p[1] * dt / 59.94
                for mark in (a, b):
                    if mark not in marks and step > 0 and emu + step >= mark:
                        marks[mark] = prev + (mark - emu) / step * dt
                emu += step
                prev = p[0]
            out += f' | emulated {a:.0f}-{b:.0f} s ' + (f'{(b - a) / (marks[b] - marks[a]) * 100:5.1f}%' if a in marks and b in marks else '-')
        print(out)
