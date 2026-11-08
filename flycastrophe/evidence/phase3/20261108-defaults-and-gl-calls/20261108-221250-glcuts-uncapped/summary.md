Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pin2 | 2/2 | 70.68 | 68.71 | 68.01 | 70.5, 70.8 | 15.1 | 0.3 | 0 | 63 | 1.68 | 238 | 70.6 |
| fcr-glcuts | 2/2 | 72.56 | 70.67 | 70.00 | 72.0, 73.0 | 14.9 | 0.2 | 0 | 64 | 2.01 | 237 | 71.1 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pin2 | 215 | retroarch 98, Flycast-emu 76, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 63 |
| fcr-glcuts | 218 | retroarch 98, Flycast-emu 78, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 12 | 18 | 64 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pin2 | 2/2 | 90.81 | 90.04 | 90.04 | 91.0, 90.4 | 12.4 | 0.0 | 0 | 61 | 1.46 | 226 | 72.2 |
| fcr-glcuts | 2/2 | 91.02 | 89.85 | 89.85 | 91.1, 91.0 | 12.4 | 0.1 | 0 | 61 | 1.84 | 228 | 72.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pin2 | 231 | Flycast-emu 99, retroarch 88, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |
| fcr-glcuts | 230 | Flycast-emu 98, retroarch 87, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |

### Uncapped: each arm relative to fcr-pin2

- crazy-taxi fcr-glcuts: median fps 72.56 vs 70.68 (+2.7%), p5 70.67 vs 68.71 (+2.8%), frame p95 14.9 vs 15.1 ms
- sa2 fcr-glcuts: median fps 91.02 vs 90.81 (+0.2%), p5 89.85 vs 90.04 (-0.2%), frame p95 12.4 vs 12.4 ms
