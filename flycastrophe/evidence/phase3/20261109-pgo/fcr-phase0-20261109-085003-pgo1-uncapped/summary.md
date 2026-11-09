Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel11 | 2/2 | 71.65 | 70.26 | 70.19 | 71.4, 71.9 | 14.9 | 0.2 | 0 | 74 | 2.12 | 246 | 63.9 |
| fcr-pgo1 | 2/2 | 74.09 | 71.43 | 70.99 | 74.1, 73.6 | 14.6 | 0.2 | 0 | 70 | 1.75 | 244 | 64.4 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel11 | 218 | retroarch 98, Flycast-emu 79, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 64 |
| fcr-pgo1 | 218 | retroarch 98, Flycast-emu 80, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 12 | 18 | 64 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel11 | 2/2 | 90.21 | 89.76 | 89.66 | 90.0, 90.2 | 12.2 | 0.1 | 0 | 71 | 1.48 | 227 | 66.2 |
| fcr-pgo1 | 2/2 | 92.13 | 91.21 | 91.19 | 92.0, 92.1 | 12.0 | 0.1 | 0 | 72 | 1.77 | 227 | 66.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel11 | 227 | Flycast-emu 99, retroarch 85, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 12 | 18 | 66 |
| fcr-pgo1 | 227 | Flycast-emu 99, retroarch 86, deadcast-aica 15, mali-cmar-backe 13, deadcast-parse 13 | 18 | 66 |

### Uncapped: each arm relative to fcr-rel11

- crazy-taxi fcr-pgo1: median fps 74.09 vs 71.65 (+3.4%), p5 71.43 vs 70.26 (+1.7%), frame p95 14.6 vs 14.9 ms
- sa2 fcr-pgo1: median fps 92.13 vs 90.21 (+2.1%), p5 91.21 vs 89.76 (+1.6%), frame p95 12.0 vs 12.2 ms
