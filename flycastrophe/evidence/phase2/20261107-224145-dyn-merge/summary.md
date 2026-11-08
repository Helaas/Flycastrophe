Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr08 | 2/2 | 69.61 | 68.33 | 68.33 | 70.0, 69.2 | 15.4 | 0.1 | 0 | 62 | 1.08 | 221 | 70.0 |
| fcr-dyn | 2/2 | 70.99 | 69.55 | 69.23 | 70.6, 71.0 | 15.0 | 0.2 | 0 | 63 | 1.10 | 238 | 70.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr08 | 231 | retroarch 97, Flycast-emu 94, deadcast-aica 15, mali-cmar-backe 11, deadcast-parse 11 | 18 | 67 |
| fcr-dyn | 213 | retroarch 99, Flycast-emu 74, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 17 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr08 | 2/2 | 73.92 | 72.94 | 72.83 | 74.7, 73.7 | 14.6 | 0.3 | 0 | 51 | 1.09 | 224 | 68.8 |
| fcr-dyn | 2/2 | 91.07 | 90.33 | 90.02 | 91.1, 91.4 | 12.3 | 0.1 | 0 | 62 | 1.08 | 228 | 71.7 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr08 | 208 | Flycast-emu 99, retroarch 73, deadcast-aica 14, mali-cmar-backe 11, deadcast-parse 10 | 17 | 61 |
| fcr-dyn | 232 | Flycast-emu 99, retroarch 90, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 68 |

### Uncapped: each arm relative to fcr-pr08

- crazy-taxi fcr-dyn: median fps 70.99 vs 69.61 (+2.0%), p5 69.55 vs 68.33 (+1.8%), frame p95 15.0 vs 15.4 ms
- sa2 fcr-dyn: median fps 91.07 vs 73.92 (+23.2%), p5 90.33 vs 72.94 (+23.8%), frame p95 12.3 vs 14.6 ms
