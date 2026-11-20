#!/usr/bin/env python3
"""window.py DUMP LINK_MAP A-B : the emulation thread's samples between A and B seconds of the run, by where they landed.
Samples in translated code that the dump could not tie to a block (the block was gone by quit) are split by address:
the first 64 KB of the code area is the main loop and the stubs, the rest is a block since dropped."""
import sys, bisect, collections
sys.path.insert(0, '/Volumes/Storage/UMRK/tmp/dc-core-bench/flycastrophe')
import profsum
dump, lmap, span = sys.argv[1:4]
a, b = (float(x) * 1000 for x in span.split('-'))
funcs = profsum.load_link_map(lmap); starts = [f[0] for f in funcs]
maps = []; code = (0, 0); ss = []
for line in open(dump, errors='replace'):
    if line.startswith('map '):
        p = line[4:].split(); lo, hi = (int(x, 16) for x in p[0].split('-'))
        maps.append((lo, hi, int(p[2], 16), p[5] if len(p) > 5 else ''))
    elif line.startswith('code '):
        code = tuple(int(x, 16) for x in line.split()[1:3])
    elif line.startswith('s Flycast-emu '):
        p = line.split()
        ms = int(p[6])
        if a <= ms < b:
            ss.append((int(p[2], 16), int(p[3], 16), int(p[4], 16), [int(x, 16) for x in p[7:]]))
core = [m for m in maps if m[3].endswith('_libretro.so')]
base = min(m[0] - m[2] for m in core)
def where(pc):
    if code[0] <= pc < code[1]: return 'jit', None
    for lo, hi, off, path in maps:
        if lo <= pc < hi:
            if path == core[0][3]:
                va = pc - base; i = bisect.bisect_right(starts, va) - 1
                if i >= 0 and va < funcs[i][0] + funcs[i][1]: return 'core', funcs[i][2]
                return 'core', '?'
            return 'lib', path.rsplit('/', 1)[-1] or '[anon]'
    return 'lib', '[unmapped]'
names = set()
for pc, lr, v, st in ss:
    for x in [pc, lr] + st:
        k, n = where(x)
        if k == 'core': names.add(n)
dm = profsum.demangle(n for n in names if n != '?')
sh = lambda n: dm.get(n, n)[:90]
tot = len(ss); c = collections.Counter(); stubs = collections.Counter(); libfrom = collections.Counter()
for pc, lr, v, st in ss:
    k, n = where(pc)
    if k == 'jit':
        if v: c['jit: live blocks'] += 1
        elif pc - code[0] < 0x10000:
            c['jit: main loop and stubs'] += 1; stubs[(pc - code[0]) & ~0x3f] += 1
        else: c['jit: blocks gone by quit'] += 1
    elif k == 'core': c['core: ' + sh(n)] += 1
    else:
        chain = [lr] + st; who = '[jit]'
        for x in chain:
            k2, n2 = where(x)
            if k2 == 'core': who = sh(n2); break
        c['lib: %s' % n] += 1; libfrom['%s <- %s' % (n, who)] += 1
print(f'{tot} samples in {span} s')
for n, v in c.most_common(28): print(f'  {v*100/tot:5.1f}%  {n}')
print('library time by the core function that called it:')
for n, v in libfrom.most_common(10): print(f'  {v*100/tot:5.1f}%  {n}')
print('main loop and stubs by offset (64-byte buckets):')
for o, v in stubs.most_common(10): print(f'  {v*100/tot:5.1f}%  +{o:#x}')
