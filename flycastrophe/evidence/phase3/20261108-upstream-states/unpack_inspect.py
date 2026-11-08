#!/usr/bin/env python3
"""Unpack the downloaded upstream savestates and read what each one is.

usage: python3 -I unpack_inspect.py DOWNLOADS_DIR

For every downloads/<issue>-<id>/<file>: a zip is extracted (flattened, names that are absolute
or climb out are refused) into <dir>/extracted/, anything else is copied there as is. Each
extracted file is then classified:

  FLYSAVE1  standalone Flycast: 24-byte header (magic, creation date, version, PNG size), PNG,
            then the state, RZip-compressed (or raw in older files)
  RASTATE   RetroArch: sections, the core's data in MEM
  RZIP      RZip without the standalone header
  raw       the core's serialized data as is

and the core's raw data is written next to it as <name>.raw.state, which RetroArch loads as a
legacy (header-less) state. The serialized data starts with its version: V16 is 811, and the
fork loads V16 to V59 (854).
"""
import datetime
import json
import os
import shutil
import struct
import sys
import zipfile
import zlib

RZIP = b'#RZIPv\x01#'
V16 = 811
CURRENT = 854  # V59


def safe_name(name):
    base = os.path.basename(name.replace('\\', '/'))
    if not base or base in ('.', '..') or name.startswith('/') or '..' in name.replace('\\', '/').split('/'):
        return None
    return base


def unrzip(b):
    assert b[:8] == RZIP
    max_chunk, size = struct.unpack_from('<IQ', b, 8)
    p, out = 20, bytearray()
    while p + 4 <= len(b) and len(out) < size:
        (z,) = struct.unpack_from('<I', b, p)
        p += 4
        if z == 0:
            continue
        out += zlib.decompress(b[p:p + z])
        p += z
    return bytes(out[:size])


def classify(b):
    info = {}
    if b[:8] == b'FLYSAVE1':
        created, version, png = struct.unpack_from('<QII', b, 8)
        info.update(kind='FLYSAVE1', header_version=version, png_bytes=png,
                    created=datetime.datetime.utcfromtimestamp(created).strftime('%Y-%m-%d'))
        payload = b[24 + png:]
        if payload[:8] == RZIP:
            info['compressed'] = 'RZip'
            raw = unrzip(payload)
        else:
            raw = payload
    elif b[:8] == b'RASTATE\x01':
        info['kind'] = 'RASTATE'
        p, raw = 8, None
        while p + 8 <= len(b):
            tag, size = b[p:p + 4], struct.unpack_from('<I', b, p + 4)[0]
            p += 8
            if tag == b'MEM ':
                raw = b[p:p + size]
                break
            p += (size + 7) & ~7
        if raw is None:
            info['error'] = 'no MEM section'
            return info, None
    elif b[:8] == RZIP:
        inner = unrzip(b)
        if inner[:8] == b'RASTATE\x01':
            # RetroArch's own compression of a RASTATE file
            info, raw = classify(inner)
            info['kind'] = 'RZIP+RASTATE'
            return info, raw
        info['kind'] = 'RZIP'
        raw = inner
    else:
        info['kind'] = 'raw'
        raw = b
    (version,) = struct.unpack_from('<I', raw, 0)
    info.update(version=version, vname=f'V{version - V16 + 16}' if version >= V16 else str(version),
                raw_bytes=len(raw), loadable=V16 <= version <= CURRENT)
    return info, raw


def main(root):
    report = []
    for d in sorted(os.listdir(root)):
        dpath = os.path.join(root, d)
        if not os.path.isdir(dpath):
            continue
        out = os.path.join(dpath, 'extracted')
        os.makedirs(out, exist_ok=True)
        for f in sorted(os.listdir(dpath)):
            fpath = os.path.join(dpath, f)
            if not os.path.isfile(fpath):
                continue
            if zipfile.is_zipfile(fpath):
                with zipfile.ZipFile(fpath) as z:
                    for m in z.infolist():
                        if m.is_dir():
                            continue
                        name = safe_name(m.filename)
                        if name is None:
                            report.append({'dir': d, 'member': m.filename, 'error': 'refused path'})
                            continue
                        with z.open(m) as src, open(os.path.join(out, name), 'wb') as dst:
                            shutil.copyfileobj(src, dst)
            else:
                shutil.copyfile(fpath, os.path.join(out, f))
        for name in sorted(os.listdir(out)):
            if name.endswith('.raw.state'):
                continue
            b = open(os.path.join(out, name), 'rb').read()
            row = {'dir': d, 'file': name, 'bytes': len(b)}
            try:
                info, raw = classify(b)
                row.update(info)
                if raw is not None:
                    open(os.path.join(out, name + '.raw.state'), 'wb').write(raw)
            except Exception as e:  # not a state, or damaged
                row['error'] = f'{type(e).__name__}: {e}'
            report.append(row)
    json.dump(report, open(os.path.join(root, 'inspect.json'), 'w'), indent=1)
    for r in report:
        print(json.dumps(r))


if __name__ == '__main__':
    main(sys.argv[1])
