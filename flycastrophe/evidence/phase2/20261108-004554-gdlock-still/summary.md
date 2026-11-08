Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-m11 | 1/1 | 71.93 | 71.11 | 70.96 | 71.9 | 14.8 | 0.2 | 0 | 64 | 1.44 | 235 | 65.6 |
| fcr-gdlock | 1/1 | 71.28 | 69.84 | 69.67 | 71.3 | 14.9 | 0.3 | 0 | 63 | 1.39 | 234 | 63.3 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-m11 | 219 | retroarch 99, Flycast-emu 79, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 12 | 18 | 64 |
| fcr-gdlock | 216 | retroarch 99, Flycast-emu 76, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-m11 | 1/1 | 90.69 | 90.22 | 90.21 | 90.7 | 12.3 | 0.1 | 0 | 61 | 1.47 | 225 | 68.8 |
| fcr-gdlock | 1/1 | 90.78 | 90.19 | 90.19 | 90.8 | 12.2 | 0.1 | 0 | 61 | 2.02 | 223 | 68.1 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-m11 | 231 | Flycast-emu 99, retroarch 88, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 12 | 18 | 67 |
| fcr-gdlock | 233 | Flycast-emu 99, retroarch 89, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 68 |

### Uncapped: each arm relative to fcr-m11

- crazy-taxi fcr-gdlock: median fps 71.28 vs 71.93 (-0.9%), p5 69.84 vs 71.11 (-1.8%), frame p95 14.9 vs 14.8 ms
- sa2 fcr-gdlock: median fps 90.78 vs 90.69 (+0.1%), p5 90.19 vs 90.22 (-0.0%), frame p95 12.2 vs 12.3 ms
