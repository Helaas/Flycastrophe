Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-gl0 | 3/3 | 70.58 | 69.13 | 68.58 | 70.8, 70.4, 70.5 | 15.0 | 0.3 | 0 | 72 | 1.82 | 255 | 70.0 |
| fcr-glsm | 3/3 | 71.96 | 70.60 | 69.62 | 71.2, 73.3, 72.0 | 14.8 | 0.2 | 0 | 69 | 1.86 | 255 | 70.6 |
| fcr-orphan | 3/3 | 72.82 | 70.37 | 68.91 | 73.6, 71.2, 74.0 | 14.5 | 0.3 | 0 | 73 | 2.39 | 255 | 71.1 |
| fcr-glboth | 3/3 | 72.87 | 70.82 | 69.67 | 72.4, 73.4, 72.9 | 14.7 | 0.3 | 0 | 74 | 1.79 | 254 | 70.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-gl0 | 215 | retroarch 99, Flycast-emu 76, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 17 | 63 |
| fcr-glsm | 218 | retroarch 98, Flycast-emu 78, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 17 | 64 |
| fcr-orphan | 219 | retroarch 99, Flycast-emu 79, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 17 | 64 |
| fcr-glboth | 219 | retroarch 98, Flycast-emu 79, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 17 | 64 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-gl0 | 3/3 | 92.04 | 91.18 | 91.03 | 92.5, 91.7, 91.7 | 12.1 | 0.1 | 0 | 71 | 1.44 | 243 | 72.2 |
| fcr-glsm | 3/3 | 91.37 | 90.52 | 90.21 | 92.1, 91.2, 91.4 | 12.2 | 0.0 | 0 | 71 | 1.52 | 239 | 72.8 |
| fcr-orphan | 3/3 | 91.94 | 91.12 | 90.82 | 92.4, 91.9, 91.6 | 12.2 | 0.1 | 0 | 71 | 1.50 | 241 | 72.8 |
| fcr-glboth | 3/3 | 91.92 | 90.74 | 90.58 | 91.4, 92.1, 92.3 | 12.2 | 0.1 | 0 | 71 | 1.46 | 242 | 72.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-gl0 | 232 | Flycast-emu 99, retroarch 88, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |
| fcr-glsm | 230 | Flycast-emu 99, retroarch 87, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |
| fcr-orphan | 230 | Flycast-emu 99, retroarch 87, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |
| fcr-glboth | 231 | Flycast-emu 99, retroarch 87, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |

### Uncapped: each arm relative to fcr-gl0

- crazy-taxi fcr-glsm: median fps 71.96 vs 70.58 (+2.0%), p5 70.60 vs 69.13 (+2.1%), frame p95 14.8 vs 15.0 ms
- crazy-taxi fcr-orphan: median fps 72.82 vs 70.58 (+3.2%), p5 70.37 vs 69.13 (+1.8%), frame p95 14.5 vs 15.0 ms
- crazy-taxi fcr-glboth: median fps 72.87 vs 70.58 (+3.2%), p5 70.82 vs 69.13 (+2.4%), frame p95 14.7 vs 15.0 ms
- sa2 fcr-glsm: median fps 91.37 vs 92.04 (-0.7%), p5 90.52 vs 91.18 (-0.7%), frame p95 12.2 vs 12.1 ms
- sa2 fcr-orphan: median fps 91.94 vs 92.04 (-0.1%), p5 91.12 vs 91.18 (-0.1%), frame p95 12.2 vs 12.1 ms
- sa2 fcr-glboth: median fps 91.92 vs 92.04 (-0.1%), p5 90.74 vs 91.18 (-0.5%), frame p95 12.2 vs 12.1 ms
