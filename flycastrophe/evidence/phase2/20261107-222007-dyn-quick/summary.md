Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr08 | 1/1 | 70.69 | 69.45 | 69.23 | 70.7 | 15.3 | 0.1 | 0 | 63 | 1.03 | 224 | 65.6 |
| fcr-dyn | 1/1 | 70.60 | 69.87 | 69.81 | 70.6 | 15.1 | 0.1 | 0 | 63 | 1.11 | 238 | 62.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr08 | 232 | retroarch 98, Flycast-emu 94, deadcast-aica 15, mali-cmar-backe 12, deadcast-parse 11 | 18 | 67 |
| fcr-dyn | 212 | retroarch 98, Flycast-emu 74, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 18 | 62 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr08 | 1/1 | 73.11 | 72.60 | 72.55 | 73.1 | 14.7 | 0.3 | 0 | 50 | 1.09 | 224 | 65.0 |
| fcr-dyn | 1/1 | 90.80 | 90.61 | 90.61 | 90.8 | 12.2 | 0.1 | 0 | 61 | 1.19 | 228 | 67.5 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr08 | 205 | Flycast-emu 100, retroarch 70, deadcast-aica 13, mali-cmar-backe 11, deadcast-parse 10 | 17 | 60 |
| fcr-dyn | 230 | Flycast-emu 98, retroarch 89, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 12 | 18 | 67 |

### Uncapped: each arm relative to fcr-pr08

- crazy-taxi fcr-dyn: median fps 70.60 vs 70.69 (-0.1%), p5 69.87 vs 69.45 (+0.6%), frame p95 15.1 vs 15.3 ms
- sa2 fcr-dyn: median fps 90.80 vs 73.11 (+24.2%), p5 90.61 vs 72.60 (+24.8%), frame p95 12.2 vs 14.7 ms
