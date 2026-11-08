Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 60.08 | 59.88 | 59.85 | 60.1 | 17.3 | 0.6 | 0 | 54 | 1.45 | 233 | 63.3 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 174 | retroarch 79, Flycast-emu 61, deadcast-aica 13, mali-cmar-backe 10, deadcast-parse 9 | 16 | 51 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 60.04 | 59.97 | 59.96 | 60.0 | 17.4 | 0.5 | 0 | 41 | 1.45 | 222 | 63.3 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 147 | Flycast-emu 60, retroarch 58, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 15 | 44 |

### Each arm against fcr-dyn (no worse = pass)

