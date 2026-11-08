Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-main | 2/2 | 59.90 | 59.05 | 58.73 | 59.5, 60.1 | 17.8 | 3.7 | 2 | 54 | 1.10 | 224 | 68.1 |
| fcr-pr03 | 2/2 | 63.46 | 62.52 | 62.31 | 63.4, 63.5 | 16.7 | 0.3 | 0 | 58 | 1.09 | 226 | 70.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-main | 203 | Flycast-emu 100, retroarch 92, mali-cmar-backe 10, threaded-ml 2 | 18 | 60 |
| fcr-pr03 | 212 | retroarch 99, Flycast-emu 86, deadcast-aica 14, mali-cmar-backe 11, threaded-ml 2 | 18 | 62 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-main | 2/2 | 62.26 | 61.60 | 61.54 | 63.1, 62.2 | 17.0 | 1.0 | 0 | 44 | 1.13 | 225 | 66.9 |
| fcr-pr03 | 2/2 | 74.06 | 73.47 | 73.41 | 74.9, 73.7 | 14.5 | 0.3 | 0 | 51 | 1.31 | 228 | 68.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-main | 182 | Flycast-emu 99, retroarch 70, mali-cmar-backe 11, threaded-ml 2 | 18 | 55 |
| fcr-pr03 | 209 | Flycast-emu 99, retroarch 83, deadcast-aica 14, mali-cmar-backe 11, threaded-ml 1 | 17 | 61 |

### Uncapped: each arm relative to fcr-main

- crazy-taxi fcr-pr03: median fps 63.46 vs 59.90 (+5.9%), p5 62.52 vs 59.05 (+5.9%), frame p95 16.7 vs 17.8 ms
- sa2 fcr-pr03: median fps 74.06 vs 62.26 (+19.0%), p5 73.47 vs 61.60 (+19.3%), frame p95 14.5 vs 17.0 ms
