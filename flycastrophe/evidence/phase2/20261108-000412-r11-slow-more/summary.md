Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 14.84 | 13.76 | 13.47 | 14.8 | 254.2 | 0.5 | 182 | 13 | 1.48 | 228 | 53.8 |
| fcr-r11 | 1/1 | 49.52 | 49.17 | 49.14 | 49.5 | 22.5 | 30.9 | 4 | 44 | 1.60 | 231 | 56.7 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 159 | Flycast-emu 100, retroarch 30, deadcast-aica 21, deadcast-parse 3, mali-cmar-backe 3 | 6 | 46 |
| fcr-r11 | 208 | retroarch 98, Flycast-emu 73, deadcast-aica 16, deadcast-parse 10, mali-cmar-backe 9 | 20 | 62 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 11.82 | 10.45 | 10.06 | 11.8 | 298.2 | 0.3 | 226 | 9 | 1.46 | 221 | 53.1 |
| fcr-r11 | 1/1 | 60.02 | 59.94 | 59.92 | 60.0 | 18.1 | 0.8 | 1 | 41 | 1.47 | 222 | 56.7 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 143 | Flycast-emu 100, retroarch 19, deadcast-aica 18, mali-cmar-backe 2, deadcast-parse 2 | 5 | 42 |
| fcr-r11 | 212 | Flycast-emu 88, retroarch 83, deadcast-aica 16, mali-cmar-backe 11, deadcast-parse 11 | 20 | 63 |

### Each arm against fcr-dyn (no worse = pass)

- crazy-taxi fcr-r11: median fps pass (49.52 vs 14.84); frame p95 pass (22.5 vs 254.2 ms); underruns FAIL (30.9 vs 0.5 %); startup pass (1.60 vs 1.48 s)
- sa2 fcr-r11: median fps pass (60.02 vs 11.82); frame p95 pass (18.1 vs 298.2 ms); underruns FAIL (0.8 vs 0.3 %); startup pass (1.47 vs 1.46 s)
