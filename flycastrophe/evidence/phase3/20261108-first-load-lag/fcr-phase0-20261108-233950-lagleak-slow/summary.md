Mode: uncapped=0 drive=1 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-b37 | 3/3 | 41.12 | 21.04 | 19.81 | 37.6, 47.5, 34.6 | 49.3 | 1.9 | 976 | 49 | 2.78 | 278 | 55.6 |
| fcr-leak | 3/3 | 59.62 | 37.47 | 35.16 | 60.0, 59.6, 51.1 | 27.7 | 3.9 | 155 | 60 | 2.76 | 266 | 56.1 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-b37 | 196 | Flycast-emu 91, retroarch 67, deadcast-aica 22, mali-cmar-backe 9, deadcast-parse 7 | 16 | 58 |
| fcr-leak | 217 | Flycast-emu 86, retroarch 86, deadcast-aica 23, mali-cmar-backe 11, deadcast-parse 9 | 20 | 65 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-b37 | 3/3 | 59.30 | 31.20 | 27.41 | 36.0, 59.9, 60.0 | 34.6 | 0.9 | 511 | 46 | 2.15 | 261 | 55.0 |
| fcr-leak | 3/3 | 60.04 | 41.43 | 32.13 | 60.1, 60.0, 47.2 | 18.0 | 1.7 | 192 | 49 | 2.17 | 253 | 55.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-b37 | 192 | Flycast-emu 89, retroarch 64, deadcast-aica 17, mali-cmar-backe 11, deadcast-parse 8 | 19 | 59 |
| fcr-leak | 202 | Flycast-emu 91, retroarch 71, deadcast-aica 18, mali-cmar-backe 12, deadcast-parse 9 | 20 | 62 |

### Each arm against fcr-b37 (no worse = pass)

- crazy-taxi fcr-leak: median fps pass (59.62 vs 41.12); frame p95 pass (27.7 vs 49.3 ms); underruns FAIL (3.9 vs 1.9 %); startup pass (2.76 vs 2.78 s)
- sa2 fcr-leak: median fps pass (60.04 vs 59.30); frame p95 pass (18.0 vs 34.6 ms); underruns FAIL (1.7 vs 0.9 %); startup pass (2.17 vs 2.15 s)
