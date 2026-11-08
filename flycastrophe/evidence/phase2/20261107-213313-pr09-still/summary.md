Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr03 | 2/2 | 63.50 | 61.75 | 61.54 | 63.1, 63.8 | 16.8 | 0.3 | 0 | 57 | 1.08 | 226 | 68.8 |
| fcr-pr09 | 2/2 | 69.90 | 67.77 | 67.56 | 70.5, 69.0 | 15.4 | 0.2 | 0 | 62 | 1.09 | 228 | 70.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr03 | 212 | retroarch 99, Flycast-emu 86, deadcast-aica 14, mali-cmar-backe 11, threaded-ml 2 | 17 | 62 |
| fcr-pr09 | 235 | retroarch 97, Flycast-emu 95, deadcast-aica 15, deadcast-parse 14, mali-cmar-backe 12 | 18 | 68 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr03 | 2/2 | 74.81 | 73.75 | 73.46 | 74.9, 74.8 | 14.4 | 0.3 | 0 | 51 | 1.08 | 228 | 69.4 |
| fcr-pr09 | 2/2 | 72.88 | 71.95 | 71.68 | 73.0, 72.4 | 14.9 | 0.3 | 0 | 50 | 1.06 | 226 | 68.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr03 | 210 | Flycast-emu 99, retroarch 84, deadcast-aica 14, mali-cmar-backe 11, threaded-ml 2 | 17 | 61 |
| fcr-pr09 | 208 | Flycast-emu 100, retroarch 71, deadcast-aica 13, deadcast-parse 12, mali-cmar-backe 11 | 17 | 60 |

### Uncapped: each arm relative to fcr-pr03

- crazy-taxi fcr-pr09: median fps 69.90 vs 63.50 (+10.1%), p5 67.77 vs 61.75 (+9.8%), frame p95 15.4 vs 16.8 ms
- sa2 fcr-pr09: median fps 72.88 vs 74.81 (-2.6%), p5 71.95 vs 73.75 (-2.4%), frame p95 14.9 vs 14.4 ms
