Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-glboth2 | 3/3 | 71.84 | 70.59 | 69.71 | 72.8, 70.9, 71.8 | 14.8 | 0.3 | 0 | 74 | 1.77 | 255 | 71.1 |
| fcr-kcw1 | 3/3 | 73.16 | 71.20 | 70.23 | 74.0, 72.1, 73.8 | 14.5 | 0.2 | 0 | 71 | 1.83 | 255 | 70.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-glboth2 | 218 | retroarch 99, Flycast-emu 78, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 17 | 64 |
| fcr-kcw1 | 206 | retroarch 99, Flycast-emu 66, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 18 | 61 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-glboth2 | 3/3 | 91.99 | 91.00 | 90.80 | 92.1, 91.2, 92.1 | 12.2 | 0.0 | 0 | 71 | 1.48 | 238 | 73.3 |
| fcr-kcw1 | 3/3 | 99.81 | 98.07 | 97.90 | 101.0, 99.9, 99.0 | 10.8 | 0.1 | 0 | 76 | 1.52 | 241 | 72.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-glboth2 | 231 | Flycast-emu 98, retroarch 88, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |
| fcr-kcw1 | 235 | retroarch 98, Flycast-emu 87, deadcast-aica 18, mali-cmar-backe 15, deadcast-parse 15 | 19 | 68 |

### Uncapped: each arm relative to fcr-glboth2

- crazy-taxi fcr-kcw1: median fps 73.16 vs 71.84 (+1.8%), p5 71.20 vs 70.59 (+0.9%), frame p95 14.5 vs 14.8 ms
- sa2 fcr-kcw1: median fps 99.81 vs 91.99 (+8.5%), p5 98.07 vs 91.00 (+7.8%), frame p95 10.8 vs 12.2 ms
