Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel020 | 1/1 | 92.65 | 91.96 | 91.95 | 92.6 | 11.9 | 0.1 | 0 | 80 | 1.06 | 237 | 64.4 |
| fcr-rel030 | 1/1 | 94.65 | 92.92 | 92.53 | 94.6 | 11.6 | 0.0 | 0 | 80 | 1.11 | 247 | 62.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel020 | 232 | retroarch 98, Flycast-emu 84, deadcast-aica 17, mali-cmar-backe 15, deadcast-parse 15 | 20 | 68 |
| fcr-rel030 | 236 | retroarch 98, Flycast-emu 87, deadcast-aica 18, mali-cmar-backe 16, deadcast-parse 16 | 20 | 69 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel020 | 1/1 | 113.86 | 112.55 | 112.21 | 113.9 | 10.2 | 0.1 | 0 | 75 | 1.06 | 229 | 66.2 |
| fcr-rel030 | 1/1 | 113.79 | 112.41 | 112.21 | 113.8 | 10.3 | 0.1 | 0 | 75 | 1.05 | 228 | 65.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel020 | 233 | Flycast-emu 99, retroarch 83, deadcast-aica 17, mali-cmar-backe 17, deadcast-parse 16 | 20 | 69 |
| fcr-rel030 | 231 | Flycast-emu 99, retroarch 80, deadcast-aica 18, mali-cmar-backe 17, deadcast-parse 16 | 20 | 68 |

### Uncapped: each arm relative to fcr-rel020

- crazy-taxi fcr-rel030: median fps 94.65 vs 92.65 (+2.2%), p5 92.92 vs 91.96 (+1.0%), frame p95 11.6 vs 11.9 ms
- sa2 fcr-rel030: median fps 113.79 vs 113.86 (-0.1%), p5 112.41 vs 112.55 (-0.1%), frame p95 10.3 vs 10.2 ms
