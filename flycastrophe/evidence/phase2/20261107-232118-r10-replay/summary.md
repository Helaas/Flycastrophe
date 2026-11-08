Mode: uncapped=1 drive=0 warmup=10s window=45s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 79.16 | 64.15 | 61.92 | 79.2 | 16.7 | 3.6 | 1 | 81 | 1.43 | 313 | 75.6 |
| fcr-r10 | 1/1 | 79.16 | 64.15 | 62.26 | 79.2 | 16.7 | 3.4 | 1 | 81 | 1.45 | 315 | 74.4 |

Replay played to its end (start to exit, lower is faster): fcr-dyn median 78.22 s (78.22); fcr-r10 median 78.09 s (78.09)

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 216 | retroarch 90, Flycast-emu 79, deadcast-aica 21, mali-cmar-backe 12, deadcast-parse 11 | 19 | 64 |
| fcr-r10 | 216 | retroarch 90, Flycast-emu 80, deadcast-aica 20, mali-cmar-backe 12, deadcast-parse 11 | 19 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 77.86 | 73.58 | 71.89 | 77.9 | 15.3 | 0.1 | 3 | 68 | 1.36 | 316 | 75.0 |
| fcr-r10 | 1/1 | 67.05 | 63.88 | 63.86 | 67.0 | 16.2 | 0.1 | 2 | 65 | 1.45 | 308 | 74.4 |

Replay played to its end (start to exit, lower is faster): fcr-dyn median 72.91 s (72.91); fcr-r10 median 82.14 s (82.14)

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 224 | Flycast-emu 95, retroarch 87, deadcast-aica 16, mali-cmar-backe 14, deadcast-parse 11 | 18 | 66 |
| fcr-r10 | 222 | retroarch 92, Flycast-emu 89, deadcast-aica 15, mali-cmar-backe 12, deadcast-parse 12 | 18 | 65 |

### Uncapped: each arm relative to fcr-dyn

- crazy-taxi fcr-r10: median fps 79.16 vs 79.16 (+0.0%), p5 64.15 vs 64.15 (-0.0%), frame p95 16.7 vs 16.7 ms
- sa2 fcr-r10: median fps 67.05 vs 77.86 (-13.9%), p5 63.88 vs 73.58 (-13.2%), frame p95 16.2 vs 15.3 ms
