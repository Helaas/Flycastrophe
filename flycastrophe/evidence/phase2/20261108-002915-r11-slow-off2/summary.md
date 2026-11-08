Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 49.48 | 49.26 | 49.24 | 49.5 | 22.2 | 32.7 | 2 | 45 | 1.52 | 230 | 56.1 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 209 | retroarch 98, Flycast-emu 73, deadcast-aica 16, deadcast-parse 11, mali-cmar-backe 9 | 20 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 60.08 | 59.90 | 59.89 | 60.1 | 17.9 | 1.4 | 0 | 41 | 1.55 | 222 | 56.7 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 211 | Flycast-emu 87, retroarch 83, deadcast-aica 16, mali-cmar-backe 11, deadcast-parse 11 | 20 | 63 |

### Each arm against fcr-dyn (no worse = pass)

