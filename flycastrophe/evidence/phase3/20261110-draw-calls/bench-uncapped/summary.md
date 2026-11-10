Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dcbase | 3/3 | 73.15 | 69.35 | 69.35 | 72.8, 73.3, 73.4 | 14.8 | 0.2 | 0 | 65 | 1.09 | 235 | 70.0 |
| fcr-prfinal | 3/3 | 90.74 | 87.87 | 87.55 | 90.7, 91.8, 89.7 | 12.2 | 0.1 | 0 | 79 | 1.14 | 235 | 72.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dcbase | 205 | retroarch 98, Flycast-emu 65, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 12 | 18 | 61 |
| fcr-prfinal | 232 | retroarch 98, Flycast-emu 83, deadcast-aica 19, deadcast-parse 15, mali-cmar-backe 15 | 20 | 68 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dcbase | 3/3 | 99.90 | 96.65 | 96.18 | 99.7, 103.0, 98.2 | 10.9 | 0.1 | 0 | 67 | 1.12 | 227 | 72.8 |
| fcr-prfinal | 3/3 | 112.92 | 111.53 | 111.47 | 112.9, 112.8, 113.1 | 10.5 | 0.1 | 0 | 75 | 1.11 | 229 | 73.3 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dcbase | 234 | retroarch 98, Flycast-emu 86, deadcast-aica 18, mali-cmar-backe 15, deadcast-parse 14 | 19 | 68 |
| fcr-prfinal | 236 | Flycast-emu 98, retroarch 83, deadcast-aica 20, mali-cmar-backe 17, deadcast-parse 16 | 20 | 69 |

### Uncapped: each arm relative to fcr-dcbase

- crazy-taxi fcr-prfinal: median fps 90.74 vs 73.15 (+24.0%), p5 87.87 vs 69.35 (+26.7%), frame p95 12.2 vs 14.8 ms
- sa2 fcr-prfinal: median fps 112.92 vs 99.90 (+13.0%), p5 111.53 vs 96.65 (+15.4%), frame p95 10.5 vs 10.9 ms
