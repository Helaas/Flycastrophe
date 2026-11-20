#!/usr/bin/env python3
"""Per run, the perf lines whose emulated time (vblanks / 59.94 since the first line) falls in A-B seconds:
speed over the span (emulated / wall), frames rendered a second, emu and render thread CPU, ms per render,
GL draws, programs and texture binds per render, compiles and cache resets in the span.
usage: span.py A-B LOG...   (A-B empty or 'all': from 3 s of wall time on)"""
import re, sys, statistics
pat = re.compile(r'perf +([0-9.]+) s: vblank +([0-9.]+)/s +([0-9.]+)% .*?rendered +([0-9.]+)/s skipped +([0-9.]+)/s'
                 r'.*?emu cpu +([0-9]+)%.*?render cpu +([0-9]+)%.*?renders (\d+) \(to textures \d+\) ([0-9.]+) ms'
                 r'.*?compiled (\d+) in ([0-9.]+) ms resets (\d+).*?mmu flushes (\d+)\+(\d+) misses (\d+)'
                 r'.*?draws ([0-9.]+) programs ([0-9.]+) textures ([0-9.]+)')
span = sys.argv[1]
for path in sys.argv[2:]:
    rows = []
    for line in open(path, errors='replace'):
        m = pat.search(line)
        if m: rows.append([float(x) for x in m.groups()])
    if not rows:
        print(f'{path}: no perf lines'); continue
    emu, prev = 0.0, rows[0][0]
    for r in rows:
        emu += r[1] * (r[0] - prev) / 59.94; prev = r[0]; r.append(emu)
    if span in ('', 'all'):
        w = [r for r in rows if r[0] >= 3]
    else:
        a, b = (float(x) for x in span.split('-'))
        w = [r for r in rows if a < r[-1] <= b]
    if len(w) < 2:
        print(f'{path}: span not reached ({rows[-1][-1]:.0f} s emulated)'); continue
    wall = w[-1][0] - w[0][0] + (w[1][0] - w[0][0])
    emus = w[-1][-1] - w[0][-1] + (w[1][-1] - w[0][-1])
    rend = [r for r in w if r[7] > 0]
    m = lambda k, rr=w: statistics.mean(r[k] for r in rr)
    # per-render values weighted by renders
    wm = lambda k: sum(r[k] * r[7] for r in rend) / max(1, sum(r[7] for r in rend))
    name = path.rsplit('/', 1)[-1][:-4]
    print(f'{name:28} speed {100*emus/wall:6.1f}% fps {m(3):5.1f} skip {m(4):4.1f} emu {m(5):3.0f}% render {m(6):3.0f}% '
          f'{wm(8):5.2f} ms draws {wm(15):5.0f} progs {wm(16):4.0f} binds {wm(17):5.0f} | compiled {sum(r[9] for r in w):.0f} resets {sum(r[11] for r in w):.0f} '
          f'mmu {sum(r[12] for r in w)/len(w):.0f}+{sum(r[13] for r in w)/len(w):.0f}/s miss {sum(r[14] for r in w)/len(w):.0f}/s')
