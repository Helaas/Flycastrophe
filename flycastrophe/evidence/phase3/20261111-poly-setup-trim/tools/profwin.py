#!/usr/bin/env python3
"""profwin.py DUMP LINK_MAP THREAD MS_FROM MS_TO [--top N] [--inside SUBSTR]
A thread's samples of a Deadcast profiler dump within a time window: where the pc was (core function,
or another library with the first core function up the stack), and with --inside the hottest offsets
inside the core functions whose name contains SUBSTR."""
import bisect, collections, sys
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../bench/flycastrophe'))
import profsum
args = sys.argv[1:]
top = int(args[args.index('--top') + 1]) if '--top' in args else 30
inside = args[args.index('--inside') + 1] if '--inside' in args else None
dump, mapfile, thread, t0, t1 = args[0], args[1], args[2], int(args[3]), int(args[4])
funcs = profsum.load_link_map(mapfile); starts = [f[0] for f in funcs]
maps = []; samples = []; code = (0, 0)
for line in open(dump, errors='replace'):
    if line.startswith('map '):
        p = line[4:].split(); lo, hi = (int(x, 16) for x in p[0].split('-'))
        maps.append((lo, hi, int(p[2], 16), p[5] if len(p) > 5 else ''))
    elif line.startswith('code '):
        a, b = line.split()[1:3]; code = (int(a, 16), int(b, 16))
    elif line.startswith('s '):
        p = line.split()
        if p[1] == thread and t0 <= int(p[6]) < t1:
            samples.append((int(p[2], 16), int(p[3], 16), [int(x, 16) for x in p[7:]]))
core = [m for m in maps if m[3].endswith('flycastrophe_libretro.so') or 'fcr-' in m[3]]
base = min((m[0] - m[2]) for m in core) if core else 0
def where(pc):
    if code[0] <= pc < code[1]: return 'jit', None, 0
    for lo, hi, off, path in maps:
        if lo <= pc < hi:
            if core and path == core[0][3]:
                va = pc - base; i = bisect.bisect_right(starts, va) - 1
                if i >= 0 and va < funcs[i][0] + funcs[i][1]: return 'core', funcs[i][2], va - funcs[i][0]
                return 'core', '?core+%x' % va, 0
            return 'lib', path.rsplit('/', 1)[-1] or '[anon]', 0
    return 'lib', '[unmapped]', 0
names = set()
res = []
for pc, lr, stack in samples:
    k, n, off = where(pc)
    caller = None
    if k != 'core':
        for a in [lr] + stack:
            k2, n2, _ = where(a)
            if k2 == 'core': caller = n2; break
    res.append((k, n, off, caller))
    if k == 'core': names.add(n)
    if caller: names.add(caller)
dm = profsum.demangle(n for n in names if n and not n.startswith('?'))
def short(n):
    n = dm.get(n, n) or '?'
    return n if len(n) < 100 else n[:97] + '...'
total = len(res)
print(f'{thread}: {total} samples in {t0}-{t1} ms')
kinds = collections.Counter(k for k, *_ in res)
print('  ' + ', '.join(f'{k} {v*100/total:.1f}%' for k, v in kinds.most_common()))
excl = collections.Counter()
for k, n, off, caller in res:
    excl[short(n) if k == 'core' else f'<{n}> from {short(caller) if caller else "?"}'] += 1
for name, c in excl.most_common(top): print(f'  {c*100/total:5.1f}%  {name}')
if inside:
    offs = collections.Counter()
    for k, n, off, caller in res:
        if k == 'core' and inside in short(n): offs[(short(n)[:60], off & ~0xf)] += 1
    print(f'hottest 16-byte spots inside *{inside}*:')
    for (n, off), c in offs.most_common(40): print(f'  {c*100/total:5.2f}%  {n} +0x{off:x}')
