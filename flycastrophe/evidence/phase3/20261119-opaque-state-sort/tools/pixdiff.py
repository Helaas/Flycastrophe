#!/usr/bin/env python3
"""pixdiff.py A.raw B.raw [OUT.png]: pixels that differ between two GLDUMP frames ("w h\\n" + RGBA rows), their box
and the largest channel difference; OUT.png marks them (needs Pillow, optional)."""
import sys
def load(p):
    d = open(p, 'rb').read(); nl = d.index(b'\n'); w, h = map(int, d[:nl].split()); return w, h, d[nl+1:]
w, h, a = load(sys.argv[1]); _, _, b = load(sys.argv[2])
n = 0; mx = 0; x0 = y0 = 10**9; x1 = y1 = -1; diff = []
for i in range(0, w * h * 4, 4):
    if a[i:i+4] != b[i:i+4]:
        n += 1; px = i // 4; x, y = px % w, h - 1 - px // w
        mx = max(mx, max(abs(a[i+c] - b[i+c]) for c in range(3)))
        x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y); diff.append((x, y))
print(f"{n} of {w*h} pixels differ" + (f", box {x0},{y0}-{x1},{y1}, max channel difference {mx}" if n else ""))
