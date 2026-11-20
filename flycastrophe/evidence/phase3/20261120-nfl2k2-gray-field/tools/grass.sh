#!/usr/bin/env bash
# grass.sh PNG... : for each screenshot, the median-ish colour of the field: pixels that are "grass-like" (green the
# largest channel) averaged over the lower two thirds, and how saturated that is (g minus the mean of r and b).
for f in "$@"; do
  ffmpeg -loglevel error -i "$f" -vf "crop=iw:ih*2/3:0:ih/3,scale=96:48" -f rawvideo -pix_fmt rgb24 - 2>/dev/null | python3 -c "
import sys
d=sys.stdin.buffer.read(); px=[(d[i],d[i+1],d[i+2]) for i in range(0,len(d),3)]
g=[p for p in px if p[1]>p[0] and p[1]>p[2] and 40<p[1]<200]
if not g: print('%-44s no grass'%sys.argv[1]); sys.exit()
r=sum(p[0] for p in g)/len(g); gg=sum(p[1] for p in g)/len(g); b=sum(p[2] for p in g)/len(g)
print('%-44s grass px %4d  rgb %3.0f %3.0f %3.0f  green excess %5.1f'%(sys.argv[1],len(g),r,gg,b,gg-(r+b)/2))" "$f"
done
