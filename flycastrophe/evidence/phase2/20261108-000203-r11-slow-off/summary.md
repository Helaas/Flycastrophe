Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 49.67 | 49.12 | 49.05 | 49.7 | 22.1 | 32.2 | 0 | 44 | 1.56 | 231 | 56.1 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 210 | retroarch 98, Flycast-emu 73, deadcast-aica 17, deadcast-parse 11, mali-cmar-backe 9 | 20 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 60.02 | 59.86 | 59.81 | 60.0 | 18.2 | 0.7 | 1 | 41 | 1.07 | 222 | 56.7 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 212 | Flycast-emu 88, retroarch 83, deadcast-aica 16, mali-cmar-backe 11, deadcast-parse 11 | 20 | 63 |

### Each arm against fcr-dyn (no worse = pass)

