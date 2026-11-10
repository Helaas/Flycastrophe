#!/usr/bin/env python3
"""A FLYCASTROPHE_GLDUMP frame ("width height\n" + RGBA rows as glReadPixels returns them: the renderer draws upside down, so the top row comes first) to an RGB PNG.
usage: raw2png.py IN.raw OUT.png"""
import struct, sys, zlib
data = open(sys.argv[1], 'rb').read()
nl = data.index(b'\n'); w, h = (int(x) for x in data[:nl].split()); px = data[nl + 1:]
assert len(px) == w * h * 4, (len(px), w, h)
rows = []
for y in range(h):
    row = px[y * w * 4:(y + 1) * w * 4]
    rgb = bytearray(w * 3); rgb[0::3] = row[0::4]; rgb[1::3] = row[1::4]; rgb[2::3] = row[2::4]
    rows.append(b'\0' + bytes(rgb))
def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d))
open(sys.argv[2], 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
                              + chunk(b'IDAT', zlib.compress(b''.join(rows), 9)) + chunk(b'IEND', b''))
