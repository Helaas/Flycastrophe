# Defaults and GL calls (2026-11-08, #18 and #19)

From Leaf's FlyCast Fast UMRK (2022 Flycast + three renderer patches + PGO), compared with what
Flycastrophe shipped.

**Defaults (#18).** One binary (`fcr-rel`), three option sets, still scenes (`*-defaults-*`):

| Option set | Crazy Taxi uncapped | SA2 uncapped | Capped CPU (CT / SA2) |
| --- | ---: | ---: | --- |
| old defaults: DSP on, anisotropy "4" (2x), delay swap on | 67.75 | 88.12 | 190% / 161%, AICA thread 21% / 20% |
| new defaults: DSP off, anisotropy off, delay swap on | 71.21 (+5.1%) | 88.72 (+0.7%) | 177% / 149%, AICA thread 13% / 11% |
| also delay swap off (the bench config) | 70.08 (+3.4%) | 90.43 (+2.6%) | 178% / 148% |

All hold 60 fps capped. The anisotropy option was read by its position in the list ("4" was 2x,
"2" off); it's read by value now. A run with neither option set saved `reicast_enable_dsp =
"disabled"` and `reicast_anisotropic_filtering = "off"`.

**GL calls (#19)**, against the pinned build (`fcr-pin2`, `*-glcuts-*`): Crazy Taxi uncapped 72.56
vs 70.68 fps (+2.7%, both rounds), SA2 91.02 vs 90.81 (+0.2%); capped, 60 fps both with the GL thread
at 80% both. Virtua Fighter 4's attract (Naomi 2 lighting) draws correctly
(`vf4-pinned-vs-gl-calls.jpg`; the two runs caught different moments of the attract).
