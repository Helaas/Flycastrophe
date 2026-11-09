#!/usr/bin/env python3
"""Summarize a Deadcast profiler dump (DEADCAST_PROF) from Flycastrophe.

usage: python3 -I profsum.py DUMP LINK_MAP [--top N] [--sh4 N]

LINK_MAP is the core's linker map (Flycastrophe-pak: LINK_MAP=1 core/build-core.sh), which names the
functions of the stripped core. For each profiled thread it prints where the samples landed (one per
millisecond of the thread's CPU time): the core's functions, translated SH4 code by block, or another
library; for samples in another library (the GL driver, libc), the core function that called it, from
the sample's link register. Then the SH4 blocks that took the most guest cycles, with their code.
"""
import bisect
import collections
import re
import subprocess
import sys


def load_link_map(path):
    funcs = []  # (addr, size, name)
    pending = None
    sec = re.compile(r'^ \.text\.(\S+)(?:\s+0x([0-9a-f]+)\s+0x([0-9a-f]+)\s+\S+)?$')
    cont = re.compile(r'^\s+0x([0-9a-f]+)\s+0x([0-9a-f]+)\s+\S+')
    for line in open(path, errors='replace'):
        m = sec.match(line)
        if m:
            if m.group(2):
                funcs.append((int(m.group(2), 16), int(m.group(3), 16), m.group(1)))
                pending = None
            else:
                pending = m.group(1)
            continue
        if pending:
            m = cont.match(line)
            if m:
                funcs.append((int(m.group(1), 16), int(m.group(2), 16), pending))
            pending = None
    funcs = [f for f in funcs if f[0] != 0 and f[1] != 0]
    funcs.sort()
    return funcs


def demangle(names):
    names = list(names)
    try:
        out = subprocess.run(['c++filt'], input='\n'.join(names), capture_output=True, text=True).stdout.split('\n')
        return dict(zip(names, out))
    except OSError:
        return {n: n for n in names}


def main():
    args = sys.argv[1:]
    top = int(args[args.index('--top') + 1]) if '--top' in args else 25
    nsh4 = int(args[args.index('--sh4') + 1]) if '--sh4' in args else 8
    dump, mapfile = args[0], args[1]
    funcs = load_link_map(mapfile)
    starts = [f[0] for f in funcs]

    maps = []  # (start, end, offset, path)
    code = (0, 0)
    samples = collections.defaultdict(list)
    runs, sh4 = [], collections.defaultdict(list)
    for line in open(dump, errors='replace'):
        if line.startswith('map '):
            parts = line[4:].split()
            lo, hi = (int(x, 16) for x in parts[0].split('-'))
            maps.append((lo, hi, int(parts[2], 16), parts[5] if len(parts) > 5 else ''))
        elif line.startswith('code '):
            a, b = line.split()[1:3]
            code = (int(a, 16), int(b, 16))
        elif line.startswith('s '):
            p = line.split()
            samples[p[1]].append((int(p[2], 16), int(p[3], 16), int(p[4], 16), [int(x, 16) for x in p[7:]]))
        elif line.startswith('run '):
            p = line.split()
            runs.append((int(p[1], 16), int(p[3]), int(p[4]), int(p[5])))
        elif line.startswith('sh4 '):
            p = line.split(None, 3)
            sh4[int(p[1], 16)].append((int(p[2], 16), p[3].strip() if len(p) > 3 else ''))

    core = [m for m in maps if m[3].endswith('flycastrophe_libretro.so') or 'fcr-' in m[3]]
    base = min((m[0] - m[2]) for m in core) if core else 0

    def where(pc):
        if code[0] <= pc < code[1]:
            return 'jit', None
        for lo, hi, off, path in maps:
            if lo <= pc < hi:
                if core and path == core[0][3]:
                    va = pc - base
                    i = bisect.bisect_right(starts, va) - 1
                    if i >= 0 and va < funcs[i][0] + funcs[i][1]:
                        return 'core', funcs[i][2]
                    return 'core', '?core+%x' % va
                return 'lib', path.rsplit('/', 1)[-1] or '[anon]'
        return 'lib', '[unmapped]'

    names = set()
    for th, ss in samples.items():
        for pc, lr, vaddr, stack in ss:
            k, n = where(pc)
            if k == 'core':
                names.add(n)
            k2, n2 = where(lr)
            if k2 == 'core':
                names.add(n2)
    dm = demangle(n for n in names if not n.startswith('?'))

    def short(n):
        n = dm.get(n, n)
        return n if len(n) < 110 else n[:107] + '...'

    for th, ss in sorted(samples.items(), key=lambda kv: -len(kv[1])):
        total = len(ss)
        excl = collections.Counter()
        libcallers = collections.Counter()
        kinds = collections.Counter()
        for pc, lr, vaddr, stack in ss:
            k, n = where(pc)
            kinds[k] += 1
            if k == 'jit':
                excl['[SH4 block %08x]' % vaddr if vaddr else '[dynarec loop/stubs]'] += 1
            elif k == 'core':
                excl[short(n)] += 1
            else:
                excl['<%s>' % n] += 1
                k2, n2 = where(lr)
                caller = short(n2) if k2 == 'core' else ('<%s>' % n2 if k2 == 'lib' else '[jit]')
                libcallers['<%s> from %s' % (n, caller)] += 1
        print(f'== thread {th}: {total} samples (CPU-time timer; the kernel tick caps the rate); '
              + ', '.join(f'{k} {v * 100 / total:.0f}%' for k, v in kinds.most_common()))
        for name, c in excl.most_common(top):
            print(f'  {c * 100 / total:5.1f}%  {name}')
        if libcallers:
            print('  other libraries, by caller:')
            for name, c in libcallers.most_common(12):
                print(f'  {c * 100 / total:5.1f}%  {name}')
        print()

    if runs:
        tot = sum(r[1] * r[2] for r in runs)
        print(f'== SH4 blocks by guest cycles (top {nsh4} of {len(runs)} listed)')
        for vaddr, n, cycles, ops in sorted(runs, key=lambda r: -r[1] * r[2])[:nsh4]:
            print(f'  {n * cycles * 100 / tot:5.1f}%  block {vaddr:08x}: runs {n}, {cycles} cycles, {ops} instructions')
            for pc, text in sh4.get(vaddr, [])[:24]:
                print(f'            {pc:08x}  {text}')


if __name__ == '__main__':
    main()
