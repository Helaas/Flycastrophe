Mode: uncapped=1 drive=0 warmup=10s window=45s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rt0 | 1/1 | 77.69 | 63.49 | 60.77 | 77.7 | 16.5 | 3.8 | 2 | 82 | 2.36 | 306 | 71.1 |
| fcr-rt1 | 1/1 | 77.63 | 67.32 | 64.14 | 77.6 | 16.5 | 2.9 | 1 | 84 | 2.33 | 304 | 70.6 |

Replay played to its end (start to exit, lower is faster): fcr-rt0 median 79.64 s (79.64); fcr-rt1 median 78.06 s (78.06)

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rt0 | 215 | retroarch 93, Flycast-emu 77, deadcast-aica 20, mali-cmar-backe 12, deadcast-parse 11 | 19 | 63 |
| fcr-rt1 | 217 | retroarch 92, Flycast-emu 79, deadcast-aica 20, mali-cmar-backe 12, deadcast-parse 11 | 19 | 64 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rt0 | 1/1 | 84.81 | 74.99 | 74.19 | 84.8 | 15.2 | 0.2 | 3 | 68 | 2.13 | 304 | 71.7 |
| fcr-rt1 | 1/1 | 69.92 | 65.14 | 64.68 | 69.9 | 16.0 | 0.2 | 2 | 67 | 1.68 | 303 | 71.1 |

Replay played to its end (start to exit, lower is faster): fcr-rt0 median 71.59 s (71.59); fcr-rt1 median 76.26 s (76.26)

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rt0 | 222 | Flycast-emu 95, retroarch 85, deadcast-aica 16, mali-cmar-backe 14, deadcast-parse 10 | 19 | 65 |
| fcr-rt1 | 222 | retroarch 90, Flycast-emu 89, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 12 | 19 | 65 |

### Uncapped: each arm relative to fcr-rt0

- crazy-taxi fcr-rt1: median fps 77.63 vs 77.69 (-0.1%), p5 67.32 vs 63.49 (+6.0%), frame p95 16.5 vs 16.5 ms
- sa2 fcr-rt1: median fps 69.92 vs 84.81 (-17.6%), p5 65.14 vs 74.99 (-13.1%), frame p95 16.0 vs 15.2 ms
