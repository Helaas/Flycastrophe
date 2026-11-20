#!/usr/bin/env python3
"""t5.sh runs: per scene and arm, each round's speed, frames rendered and skipped a second, emulated frames late
(vblank intervals over 17.5 ms) a second and the worst one, from the perf lines in the scene's window; and
RetroArch's presented fps, frame time p95 and dropped frames from the last GET_PERF_INFO.
usage: t5sum.py DIR"""
import glob, os, re, sys, collections, statistics
pat = re.compile(r'perf +([0-9.]+) s: vblank +([0-9.]+)/s +([0-9.]+)% .*?rendered +([0-9.]+)/s skipped +([0-9.]+)/s'
                 r'.*?emu frames late (\d+) max ([0-9.]+) ms')
WIN = {'ct': (5, 99), 'ce': (55, 90), 'nfl': (2, 30), 'armada': (8, 99), 'sr2': (10, 99)}
rows = collections.defaultdict(list)
for path in sorted(glob.glob(os.path.join(sys.argv[1], '*.log'))):
    m = re.match(r'([a-z0-9]+)-(.+)-r(\d)$', os.path.basename(path)[:-4])
    if not m: continue
    scene, label, rnd = m.groups()
    pl = [[float(x) for x in p.groups()] for p in (pat.search(l) for l in open(path, errors='replace')) if p]
    emu, prev = 0.0, pl[0][0] if pl else 0
    for r in pl:
        emu += r[1] * (r[0] - prev) / 59.94; prev = r[0]; r.append(emu)
    a, b = WIN.get(scene, (3, 999))
    w = [r for r in pl if a < r[-1] <= b]
    if len(w) < 2:
        print(path, 'window not reached'); continue
    wall = w[-1][0] - w[0][0]; emus = w[-1][-1] - w[0][-1]
    pi = open(path[:-4] + '.perfinfo').read().strip().splitlines()
    last = pi[-1] if pi else ''
    g = lambda k: (re.search(k + r'=([0-9.]+)', last) or [None, 'nan'])[1]
    mean = lambda k: statistics.mean(r[k] for r in w)
    rows[(scene, label)].append(f"r{rnd} speed {100*emus/wall:5.1f}% rendered {mean(3):5.2f}/s skipped {mean(4):5.2f}/s "
        f"late {mean(5):4.1f}/s worst {max(r[6] for r in w):6.1f} ms | RA fps {float(g('fps')):5.2f} p95 {float(g('frame_time_p95_ms')):5.2f} ms dropped {g('dropped')}")
for (scene, label), rr in sorted(rows.items()):
    for r in rr:
        print(f"{scene:7} {label:12} {r}")
