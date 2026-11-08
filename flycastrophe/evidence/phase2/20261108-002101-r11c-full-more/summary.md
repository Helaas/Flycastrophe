Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-r11c | 1/1 | 60.06 | 59.96 | 59.96 | 60.1 | 17.3 | 0.2 | 0 | 51 | 1.47 | 232 | 65.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-r11c | 176 | retroarch 79, Flycast-emu 63, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 10 | 15 | 52 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-r11c | 1/1 | 60.06 | 59.89 | 59.88 | 60.1 | 17.5 | 0.5 | 0 | 41 | 1.47 | 222 | 62.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-r11c | 147 | Flycast-emu 60, retroarch 57, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 15 | 44 |

### Each arm against fcr-r11c (no worse = pass)

