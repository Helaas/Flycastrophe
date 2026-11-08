Mode: uncapped=1 drive=0 warmup=5s window=10s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel | 1/1 | 866.57 | 827.81 | 823.51 | 866.6 | 2.5 | 0.0 | 0 | 35 | 1.07 | 209 | 59.4 |
| gles | 1/1 | 849.30 | 815.33 | 811.56 | 849.3 | 2.5 | 0.0 | 0 | 36 | 1.11 | 184 | 58.3 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel | 121 | retroarch 79, mali-cmar-backe 39, deadcast-aica 2 | 34 | 43 |
| gles | 119 | retroarch 79, mali-cmar-backe 40 | 34 | 42 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel | 1/1 | 864.37 | 823.99 | 819.50 | 864.4 | 2.5 | 0.0 | 0 | 36 | 1.04 | 209 | 60.0 |
| gles | 1/1 | 852.21 | 815.11 | 810.98 | 852.2 | 2.5 | 0.0 | 0 | 36 | 1.17 | 181 | 59.4 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel | 120 | retroarch 79, mali-cmar-backe 39, deadcast-aica 2 | 34 | 43 |
| gles | 118 | retroarch 79, mali-cmar-backe 39 | 35 | 42 |

### Uncapped: each arm relative to fcr-rel

- crazy-taxi gles: median fps 849.30 vs 866.57 (-2.0%), p5 815.33 vs 827.81 (-1.5%), frame p95 2.5 vs 2.5 ms
- sa2 gles: median fps 852.21 vs 864.37 (-1.4%), p5 815.11 vs 823.99 (-1.1%), frame p95 2.5 vs 2.5 ms
