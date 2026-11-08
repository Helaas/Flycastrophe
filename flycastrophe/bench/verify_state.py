#!/usr/bin/env python3
"""verify_state.py FILE... : check a RetroArch RZIP state is complete
(header total > 0, every chunk inflates, inflated total == header total)."""
import struct, sys, zlib
rc = 0
for p in sys.argv[1:]:
    b = open(p, 'rb').read()
    ok = b[:8] == b'#RZIPv\x01#'
    total = struct.unpack_from('<Q', b, 12)[0] if ok else 0
    off, out = 20, 0
    try:
        while ok and off < len(b):
            cl = struct.unpack_from('<I', b, off)[0]; off += 4
            out += len(zlib.decompress(b[off:off + cl])); off += cl
    except Exception:
        ok = False
    ok = ok and total > 0 and out == total and off == len(b)
    print(f"{'OK ' if ok else 'BAD'} {p} header_total={total} inflated={out}")
    rc |= 0 if ok else 1
sys.exit(rc)
