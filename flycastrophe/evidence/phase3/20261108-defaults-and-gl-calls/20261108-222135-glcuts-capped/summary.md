Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pin2 | 1/1 | 60.06 | 59.96 | 59.96 | 60.1 | 17.3 | 0.7 | 0 | 53 | 1.71 | 237 | 68.8 |
| fcr-glcuts | 1/1 | 60.06 | 59.88 | 59.85 | 60.1 | 17.3 | 0.6 | 0 | 53 | 1.73 | 236 | 68.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pin2 | 178 | retroarch 80, Flycast-emu 64, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 10 | 16 | 53 |
| fcr-glcuts | 177 | retroarch 80, Flycast-emu 63, deadcast-aica 13, mali-cmar-backe 10, deadcast-parse 9 | 16 | 52 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pin2 | 1/1 | 60.00 | 59.91 | 59.88 | 60.0 | 17.6 | 0.2 | 0 | 41 | 1.79 | 225 | 66.2 |
| fcr-glcuts | 1/1 | 60.00 | 60.00 | 60.00 | 60.0 | 17.6 | 0.2 | 0 | 41 | 2.32 | 225 | 66.9 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pin2 | 148 | Flycast-emu 61, retroarch 58, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 16 | 45 |
| fcr-glcuts | 148 | Flycast-emu 61, retroarch 57, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 16 | 45 |

### Each arm against fcr-pin2 (no worse = pass)

- crazy-taxi fcr-glcuts: median fps pass (60.06 vs 60.06); frame p95 pass (17.3 vs 17.3 ms); underruns pass (0.6 vs 0.7 %); startup pass (1.73 vs 1.71 s)
- sa2 fcr-glcuts: median fps pass (60.00 vs 60.00); frame p95 pass (17.6 vs 17.6 ms); underruns pass (0.2 vs 0.2 %); startup pass (2.32 vs 1.79 s)
