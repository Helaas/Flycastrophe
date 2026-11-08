Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 70.40 | 69.52 | 69.29 | 70.4 | 15.0 | 0.1 | 0 | 63 | 1.09 | 235 | 71.1 |
| fcr-r12 | 1/1 | 71.15 | 69.82 | 69.66 | 71.2 | 15.0 | 0.2 | 0 | 63 | 1.10 | 235 | 69.4 |
| fcr-r14 | 1/1 | 72.14 | 70.42 | 70.31 | 72.1 | 14.8 | 0.1 | 0 | 64 | 1.05 | 235 | 71.1 |
| fcr-r11 | 1/1 | 69.96 | 68.99 | 68.85 | 70.0 | 15.2 | 0.2 | 0 | 63 | 1.09 | 235 | 70.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 212 | retroarch 99, Flycast-emu 74, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 62 |
| fcr-r12 | 214 | retroarch 98, Flycast-emu 76, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 17 | 63 |
| fcr-r14 | 214 | retroarch 98, Flycast-emu 75, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 63 |
| fcr-r11 | 211 | retroarch 98, Flycast-emu 73, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 62 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dyn | 1/1 | 91.86 | 91.55 | 91.54 | 91.9 | 12.3 | 0.1 | 0 | 62 | 1.11 | 223 | 73.9 |
| fcr-r12 | 1/1 | 90.99 | 90.48 | 90.42 | 91.0 | 12.3 | 0.2 | 0 | 62 | 1.49 | 229 | 72.8 |
| fcr-r14 | 1/1 | 91.53 | 91.25 | 91.24 | 91.5 | 12.2 | 0.1 | 0 | 62 | 1.07 | 223 | 72.8 |
| fcr-r11 | 1/1 | 91.20 | 89.98 | 89.64 | 91.2 | 12.3 | 0.1 | 0 | 62 | 1.51 | 224 | 73.3 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dyn | 234 | Flycast-emu 98, retroarch 91, deadcast-aica 16, mali-cmar-backe 14, deadcast-parse 13 | 18 | 68 |
| fcr-r12 | 231 | Flycast-emu 98, retroarch 88, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |
| fcr-r14 | 233 | Flycast-emu 99, retroarch 90, deadcast-aica 16, mali-cmar-backe 14, deadcast-parse 13 | 18 | 68 |
| fcr-r11 | 230 | Flycast-emu 98, retroarch 88, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |

### Uncapped: each arm relative to fcr-dyn

- crazy-taxi fcr-r12: median fps 71.15 vs 70.40 (+1.1%), p5 69.82 vs 69.52 (+0.4%), frame p95 15.0 vs 15.0 ms
- crazy-taxi fcr-r14: median fps 72.14 vs 70.40 (+2.5%), p5 70.42 vs 69.52 (+1.3%), frame p95 14.8 vs 15.0 ms
- crazy-taxi fcr-r11: median fps 69.96 vs 70.40 (-0.6%), p5 68.99 vs 69.52 (-0.8%), frame p95 15.2 vs 15.0 ms
- sa2 fcr-r12: median fps 90.99 vs 91.86 (-0.9%), p5 90.48 vs 91.55 (-1.2%), frame p95 12.3 vs 12.3 ms
- sa2 fcr-r14: median fps 91.53 vs 91.86 (-0.4%), p5 91.25 vs 91.55 (-0.3%), frame p95 12.2 vs 12.3 ms
- sa2 fcr-r11: median fps 91.20 vs 91.86 (-0.7%), p5 89.98 vs 91.55 (-1.7%), frame p95 12.3 vs 12.3 ms
