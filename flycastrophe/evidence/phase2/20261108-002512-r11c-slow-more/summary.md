Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-r11c | 1/1 | 47.11 | 46.40 | 46.37 | 47.1 | 46.1 | 1.4 | 97 | 40 | 1.52 | 229 | 57.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-r11c | 222 | retroarch 93, Flycast-emu 89, deadcast-aica 19, deadcast-parse 10, mali-cmar-backe 9 | 19 | 66 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-r11c | 1/1 | 60.00 | 49.54 | 46.10 | 60.0 | 40.7 | 0.3 | 72 | 36 | 1.56 | 222 | 57.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-r11c | 207 | Flycast-emu 87, retroarch 79, deadcast-aica 16, deadcast-parse 11, mali-cmar-backe 11 | 19 | 62 |

### Each arm against fcr-r11c (no worse = pass)

