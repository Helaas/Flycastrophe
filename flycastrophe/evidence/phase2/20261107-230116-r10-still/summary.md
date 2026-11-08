Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 2/2 | 70.98 | 69.60 | 69.60 | 70.8, 71.3 | 15.0 | 0.2 | 0 | 63 | 1.08 | 235 | 69.4 |
| fcr-r10 | 2/2 | 70.84 | 69.01 | 68.97 | 70.1, 71.6 | 15.2 | 0.2 | 0 | 64 | 1.07 | 235 | 70.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 213 | retroarch 98, Flycast-emu 74, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 18 | 63 |
| fcr-r10 | 213 | retroarch 98, Flycast-emu 75, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 2/2 | 91.48 | 90.91 | 90.82 | 91.1, 92.2 | 12.3 | 0.2 | 0 | 62 | 1.08 | 223 | 71.7 |
| fcr-r10 | 2/2 | 90.21 | 89.53 | 89.31 | 90.2, 90.2 | 12.4 | 0.1 | 0 | 61 | 1.11 | 224 | 71.7 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 232 | Flycast-emu 98, retroarch 89, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 68 |
| fcr-r10 | 230 | Flycast-emu 99, retroarch 88, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 12 | 18 | 67 |

### Uncapped: each arm relative to fcr-dyn

- crazy-taxi fcr-r10: median fps 70.84 vs 70.98 (-0.2%), p5 69.01 vs 69.60 (-0.9%), frame p95 15.2 vs 15.0 ms
- sa2 fcr-r10: median fps 90.21 vs 91.48 (-1.4%), p5 89.53 vs 90.91 (-1.5%), frame p95 12.4 vs 12.3 ms
