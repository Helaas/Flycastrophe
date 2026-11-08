Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr09 | 2/2 | 68.45 | 66.26 | 66.22 | 69.6, 67.7 | 15.8 | 0.2 | 0 | 62 | 1.11 | 229 | 69.4 |
| fcr-pr08 | 2/2 | 69.58 | 68.20 | 68.19 | 70.4, 69.0 | 15.4 | 0.2 | 0 | 62 | 1.10 | 224 | 69.4 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr09 | 233 | retroarch 97, Flycast-emu 94, deadcast-aica 15, deadcast-parse 14, mali-cmar-backe 12 | 18 | 68 |
| fcr-pr08 | 231 | retroarch 97, Flycast-emu 94, deadcast-aica 15, mali-cmar-backe 11, deadcast-parse 11 | 18 | 67 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr09 | 2/2 | 72.81 | 72.23 | 72.06 | 72.8, 72.8 | 14.8 | 0.2 | 0 | 50 | 1.06 | 233 | 68.1 |
| fcr-pr08 | 2/2 | 73.19 | 72.77 | 72.64 | 73.4, 73.0 | 14.7 | 0.2 | 0 | 50 | 1.04 | 225 | 68.1 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr09 | 208 | Flycast-emu 99, retroarch 71, deadcast-aica 14, deadcast-parse 12, mali-cmar-backe 11 | 17 | 61 |
| fcr-pr08 | 206 | Flycast-emu 100, retroarch 71, deadcast-aica 13, mali-cmar-backe 11, deadcast-parse 10 | 17 | 60 |

### Uncapped: each arm relative to fcr-pr09

- crazy-taxi fcr-pr08: median fps 69.58 vs 68.45 (+1.6%), p5 68.20 vs 66.26 (+2.9%), frame p95 15.4 vs 15.8 ms
- sa2 fcr-pr08: median fps 73.19 vs 72.81 (+0.5%), p5 72.77 vs 72.23 (+0.8%), frame p95 14.7 vs 14.8 ms
