#!/usr/bin/env python3
"""Compare two runs' 'Flycastrophe glhash' lines: frames paired by the hash of what they were drawn from.
usage: hashcmp.py A.log B.log"""
import collections, re, sys
pat = re.compile(r'glhash: in ([0-9a-f]+) out ([0-9a-f]+)')
def load(path):
    d = collections.defaultdict(collections.Counter); n = 0
    for line in open(path, errors='replace'):
        m = pat.search(line)
        if m:
            d[m.group(1)][m.group(2)] += 1; n += 1
    return d, n
a, na = load(sys.argv[1]); b, nb = load(sys.argv[2])
common = set(a) & set(b)
same = sum(1 for k in common if set(a[k]) == set(b[k]))
overlap = sum(1 for k in common if set(a[k]) & set(b[k]))
framesB = sum(sum(b[k].values()) for k in common)
okB = sum(c for k in common for o, c in b[k].items() if o in a[k])
print(f'frames {na} vs {nb}; distinct inputs {len(a)} vs {len(b)}; inputs in both {len(common)}: '
      f'same outputs {same}, some output shared {overlap}, none shared {len(common) - overlap}; '
      f"second run's frames with a paired input {framesB}, of which the picture matches one of the first's {okB}")
