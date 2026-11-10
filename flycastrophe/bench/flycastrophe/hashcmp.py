#!/usr/bin/env python3
"""Compare two runs' 'Flycastrophe glhash' lines (FLYCASTROPHE_GLHASH=1): frames are paired by the hash
of what they were drawn from, and a pair's pixels must hash the same.

Some frames don't come out the same twice from one build: what the input hash doesn't cover (a render
to a texture) or what no hash can (texels a game never wrote; Spider-Man's intro videos show a column
of them at the right edge). With CONTROL.log, a second run of A's build, the frames A and the control
disagree on are set aside, and only the ones A's build reproduces are compared.

usage: hashcmp.py A.log B.log [CONTROL.log]   (exit status 1 when a compared frame differs)"""
import collections
import re
import sys

pat = re.compile(r'glhash: in ([0-9a-f]+) out ([0-9a-f]+)')


def load(path):
    frames = collections.defaultdict(set)
    count = 0
    for line in open(path, errors='replace'):
        m = pat.search(line)
        if m:
            frames[m.group(1)].add(m.group(2))
            count += 1
    return frames, count


(a, na), (b, nb) = load(sys.argv[1]), load(sys.argv[2])
common = set(a) & set(b)
out = f'frames {na} and {nb}, {len(common)} different frames in both'
if len(sys.argv) > 3:
    control, _ = load(sys.argv[3])
    common &= set(control)
    unstable = {k for k in common if a[k] != control[k]}
    common -= unstable
    out += f', {len(common)} of them reproduced by a second run of the first build ({len(unstable)} not)'
differ = sum(1 for k in common if a[k] != b[k])
print(f'{out}: {len(common) - differ} identical, {differ} differ')
sys.exit(1 if differ else 0)
