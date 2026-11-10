#!/usr/bin/env python3
"""Summarize glrun.sh logs: per game and label, emulated speed and frame rate over time windows, render
time, and the GL work per render (means over the lines from T0 s on).
With EMU=a-b[,c-d] in the environment: the speed over those spans of emulated time (seconds since the
first perf line), so runs at different speeds are compared on the same stretch of the game.
usage: [EMU=2-12] glsum.py DIR [T0=5] [windows e.g. 5-15,15-25]"""
import collections, glob, os, re, statistics, sys
d = sys.argv[1]; t0 = float(sys.argv[2]) if len(sys.argv) > 2 else 5.0
wins = [tuple(float(x) for x in w.split('-')) for w in sys.argv[3].split(',')] if len(sys.argv) > 3 else []
perf = re.compile(r'perf +([0-9.]+) s: vblank +([0-9.]+)/s +([0-9.]+)% .*?rendered +([0-9.]+)/s.*?emu cpu +([0-9]+)%.*?render cpu +([0-9]+)%.*?renders (\d+) \(to textures \d+\) ([0-9.]+) ms')
glre = re.compile(r'Flycastrophe gl: renders (\d+) \| per render: (.*?) \| op polys')
mvre = re.compile(r'modvols ([0-9.]+) draws ([0-9.]+)')
msre = re.compile(r'ms per render: (.*)$')
rows = collections.defaultdict(list)
for path in sorted(glob.glob(os.path.join(d, '*.log'))):
    name = os.path.basename(path)[:-4]
    m = re.match(r'(crazy-taxi|sa2|nfl2k2)-(.*)-r(\d+)$', name)
    if not m: continue
    game, label, rnd = m.groups()
    P = []; G = collections.defaultdict(list); t = 0.0
    for line in open(path, errors='replace'):
        m = perf.search(line)
        if m:
            t = float(m.group(1)); P.append(tuple(float(x) for x in m.groups())); continue
        m = glre.search(line)
        if m and t >= t0:
            for k, v in re.findall(r'(\w+) ([0-9.]+)', m.group(2)): G[k].append(float(v))
            mm = mvre.search(line)
            if mm: G['modvols'].append(float(mm.group(1))); G['modvol_draws'].append(float(mm.group(2)))
            mm = msre.search(line)
            if mm:
                for k, v in re.findall(r'(\w+) ([0-9.]+)', mm.group(1)): G['ms_' + k].append(float(v))
    rows[(game, label)].append((P, G))
for (game, label), runs in sorted(rows.items()):
    for i, (P, G) in enumerate(runs, 1):
        w = [p for p in P if p[0] >= t0]
        if not w: continue
        out = f'{game:10} {label:10} r{i} speed {statistics.mean(p[2] for p in w):6.1f}% fps {statistics.mean(p[3] for p in w):6.2f} emu {statistics.mean(p[4] for p in w):3.0f}% render {statistics.mean(p[5] for p in w):3.0f}% {statistics.mean(p[7] for p in w):5.2f} ms'
        for a, b in wins:
            ww = [p for p in P if a <= p[0] < b]
            out += f' | {a:.0f}-{b:.0f}s {statistics.mean(p[2] for p in ww):5.1f}%' if ww else ' | -'
        for span in filter(None, os.environ.get('EMU', '').split(',')):
            a, b = (float(x) for x in span.split('-'))
            # wall time at which the emulated clock (vblanks / 59.94) passes a and b
            emu = 0.0; marks = {}; prev = P[0][0]
            for p in P[1:]:
                dt = p[0] - prev; step = p[1] * dt / 59.94
                for m in (a, b):
                    if m not in marks and emu + step >= m and step > 0:
                        marks[m] = prev + (m - emu) / step * dt
                emu += step; prev = p[0]
            out += f' | emulated {a:.0f}-{b:.0f}s {(b - a) / (marks[b] - marks[a]) * 100:5.1f}%' if a in marks and b in marks else f' | emulated {a:.0f}-{b:.0f}s -'
        print(out)
        if G:
            keys = [k for k in G if not k.startswith('ms_')]
            print('    gl: ' + ' '.join(f'{k} {statistics.mean(G[k]):.0f}' for k in keys))
            ms = [k for k in G if k.startswith('ms_')]
            if ms: print('    ms: ' + ' '.join(f'{k[3:]} {statistics.mean(G[k]):.2f}' for k in ms))
