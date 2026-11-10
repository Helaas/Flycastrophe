Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dcbase | 1/1 | 60.04 | 59.87 | 59.85 | 60.0 | 17.2 | 0.2 | 0 | 53 | 1.45 | 235 | 67.5 |
| fcr-dcRM | 1/1 | 60.04 | 59.97 | 59.96 | 60.0 | 17.3 | 0.3 | 0 | 53 | 1.47 | 234 | 66.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dcbase | 164 | retroarch 79, Flycast-emu 52, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 9 | 15 | 49 |
| fcr-dcRM | 149 | retroarch 64, Flycast-emu 51, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 10 | 15 | 46 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dcbase | 1/1 | 60.04 | 59.88 | 59.85 | 60.0 | 17.3 | 0.5 | 0 | 41 | 1.48 | 226 | 65.6 |
| fcr-dcRM | 1/1 | 60.02 | 59.87 | 59.85 | 60.0 | 17.4 | 0.6 | 0 | 41 | 1.51 | 226 | 65.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dcbase | 134 | retroarch 56, Flycast-emu 48, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 16 | 41 |
| fcr-dcRM | 123 | Flycast-emu 47, retroarch 45, deadcast-aica 11, mali-cmar-backe 10, deadcast-parse 9 | 16 | 39 |

### Each arm against fcr-dcbase (no worse = pass)

- crazy-taxi fcr-dcRM: median fps FAIL (60.04 vs 60.04); frame p95 FAIL (17.3 vs 17.2 ms); underruns FAIL (0.3 vs 0.2 %); startup pass (1.47 vs 1.45 s)
- sa2 fcr-dcRM: median fps FAIL (60.02 vs 60.04); frame p95 FAIL (17.4 vs 17.3 ms); underruns FAIL (0.6 vs 0.5 %); startup pass (1.51 vs 1.48 s)
