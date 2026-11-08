Mode: uncapped=0 drive=0 warmup=5s window=20s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-r11dbg3 | 1/1 | 60.08 | 59.20 | 59.05 | 60.1 | 40.0 | 0.2 | 4 | 44 | 1.77 | 230 | 62.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-r11dbg3 | 176 | retroarch 80, Flycast-emu 62, deadcast-aica 13, mali-cmar-backe 10, deadcast-parse 10 | 16 | 52 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-r11dbg3 | 1/1 | 60.04 | 60.00 | 60.00 | 60.0 | 17.7 | 0.5 | 0 | 37 | 1.50 | 223 | 62.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-r11dbg3 | 147 | Flycast-emu 60, retroarch 58, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 15 | 44 |

### Each arm against fcr-r11dbg3 (no worse = pass)

