Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-main | 3/3 | 59.77 | 59.03 | 58.96 | 59.9, 59.6, 59.8 | 17.8 | 4.3 | 1 | 54 | 1.09 | 237 | 66.9 |
| fcr-pr02 | 3/3 | 59.83 | 59.32 | 59.15 | 60.1, 59.8, 59.9 | 17.8 | 4.8 | 0 | 54 | 1.13 | 234 | 67.5 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-main | 202 | Flycast-emu 99, retroarch 92, mali-cmar-backe 10, threaded-ml 2 | 18 | 60 |
| fcr-pr02 | 203 | Flycast-emu 98, retroarch 93, mali-cmar-backe 10, threaded-ml 2 | 18 | 60 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-main | 3/3 | 62.66 | 62.00 | 61.78 | 62.5, 63.0, 62.4 | 16.9 | 0.7 | 0 | 44 | 1.08 | 238 | 65.0 |
| fcr-pr02 | 3/3 | 62.97 | 62.16 | 62.16 | 63.5, 63.2, 62.8 | 16.8 | 1.1 | 0 | 44 | 1.13 | 236 | 65.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-main | 183 | Flycast-emu 100, retroarch 70, mali-cmar-backe 11, threaded-ml 2 | 18 | 55 |
| fcr-pr02 | 183 | Flycast-emu 99, retroarch 71, mali-cmar-backe 11, threaded-ml 2 | 18 | 55 |

### Uncapped: each arm relative to fcr-main

- crazy-taxi fcr-pr02: median fps 59.83 vs 59.77 (+0.1%), p5 59.32 vs 59.03 (+0.5%), frame p95 17.8 vs 17.8 ms
- sa2 fcr-pr02: median fps 62.97 vs 62.66 (+0.5%), p5 62.16 vs 62.00 (+0.3%), frame p95 16.8 vs 16.9 ms
