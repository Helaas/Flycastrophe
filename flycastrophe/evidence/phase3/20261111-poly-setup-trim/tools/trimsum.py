import re, sys, glob, statistics
pat = re.compile(r'perf\s+([\d.]+) s: vblank\s+([\d.]+)/s\s+([\d.]+)%.*?rendered\s+([\d.]+)/s.*?render cpu\s+(\d+)%.*?renders (\d+) \(to textures \d+\) ([\d.]+) ms.*?draws (\d+)')
def rows(f):
    out = []
    for l in open(f, errors='replace'):
        m = pat.search(l)
        if m: out.append((float(m[1]), float(m[2]), float(m[3]), float(m[4]), int(m[5]), int(m[6]), float(m[7]), int(m[8])))
    return out
def wavg(rs, i):  # weighted by renders
    n = sum(r[5] for r in rs)
    return sum(r[i]*r[5] for r in rs)/n if n else 0
print('City Escape capped (renders-weighted ms per render)')
for arm in ('base', 'trim'):
    for r in (1, 2):
        rs = rows(f'speed/sa2ce-{arm}-r{r}.log')
        h = [x for x in rs if x[7] >= 1000]; m = [x for x in rs if x[7] >= 700]
        print(f'  {arm} r{r}: >=1000 draws: {len(h)} s, {wavg(h,6):.2f} ms, render cpu {statistics.mean(x[4] for x in h):.0f}%, speed {statistics.mean(x[2] for x in h):.1f}% | >=700 draws: {len(m)} s, {wavg(m,6):.2f} ms')
    allr = sum((rows(f'speed/sa2ce-{arm}-r{r}.log') for r in (1,2)), [])
    h = [x for x in allr if x[7] >= 1000]; m = [x for x in allr if x[7] >= 700]
    print(f'  {arm} both: >=1000: {wavg(h,6):.2f} ms, render cpu {statistics.mean(x[4] for x in h):.1f}%, speed {statistics.mean(x[2] for x in h):.1f}% | >=700: {wavg(m,6):.2f} ms')
print('Uncapped still scenes (seconds 3 on)')
for g in ('crazy-taxi', 'sa2'):
    for arm in ('base', 'trim'):
        per = []
        allr = []
        for r in (1, 2, 3):
            rs = [x for x in rows(f'speed-uncapped/{g}-{arm}-r{r}.log') if x[0] >= 3]
            per.append(statistics.mean(x[3] for x in rs)); allr += rs
        print(f'  {g} {arm}: fps ' + ', '.join(f'{p:.1f}' for p in per) + f' mean {statistics.mean(per):.1f} | {wavg(allr,6):.2f} ms per render, render cpu {statistics.mean(x[4] for x in allr):.0f}%')
