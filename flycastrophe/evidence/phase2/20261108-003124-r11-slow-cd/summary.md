Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-r11c | 1/1 | 47.00 | 45.45 | 45.33 | 47.0 | 46.0 | 1.2 | 68 | 40 | 1.49 | 229 | 56.7 |
| fcr-r11d | 1/1 | 46.81 | 43.05 | 41.90 | 46.8 | 45.5 | 1.3 | 92 | 41 | 1.49 | 231 | 56.7 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-r11c | 221 | retroarch 94, Flycast-emu 88, deadcast-aica 19, deadcast-parse 10, mali-cmar-backe 9 | 19 | 66 |
| fcr-r11d | 220 | retroarch 92, Flycast-emu 88, deadcast-aica 18, deadcast-parse 10, mali-cmar-backe 9 | 19 | 65 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-r11c | 1/1 | 60.00 | 53.47 | 51.71 | 60.0 | 32.4 | 0.6 | 51 | 37 | 1.50 | 222 | 56.7 |
| fcr-r11d | 1/1 | 59.96 | 52.61 | 50.19 | 60.0 | 39.8 | 0.4 | 50 | 37 | 1.46 | 222 | 56.7 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-r11c | 208 | Flycast-emu 87, retroarch 80, deadcast-aica 16, deadcast-parse 11, mali-cmar-backe 11 | 20 | 62 |
| fcr-r11d | 206 | Flycast-emu 87, retroarch 79, deadcast-aica 16, mali-cmar-backe 11, deadcast-parse 11 | 19 | 62 |

### Each arm against fcr-r11c (no worse = pass)

- crazy-taxi fcr-r11d: median fps FAIL (46.81 vs 47.00); frame p95 pass (45.5 vs 46.0 ms); underruns FAIL (1.3 vs 1.2 %); startup pass (1.49 vs 1.49 s)
- sa2 fcr-r11d: median fps FAIL (59.96 vs 60.00); frame p95 FAIL (39.8 vs 32.4 ms); underruns pass (0.4 vs 0.6 %); startup pass (1.46 vs 1.50 s)
