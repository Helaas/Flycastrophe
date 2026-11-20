# Delay Frame Swapping on and off, as played (2026-11-19)

The core defaults `reicast_delay_frame_swapping` to enabled, and the card's `Flycastrophe.opt` has it
enabled with Auto Skip Frame on "more", while every bench configuration had both disabled. The question
was whether the shipped setting costs speed, and what turning it off would cost the picture. Result:
no speed difference anywhere, a small picture cost when off, so **the default stays enabled** and no
default was changed.

The 0.2.0 release core (sha256 `db68e7da…`) for speed; a dev build of `1d7ef4ed` with one diagnostic
counter (branch `agent/delay-swap`, `4b6eeeab`, not for merging) for the picture. One MLP1, as played:
vsync and audio sync on, performance governors.

## Speed

`tools/t5.sh`: each scene once per arm, round 2 in reverse order. Per arm, Delay Frame Swapping on or
off and Auto Skip Frame disabled or "more" (`tools/t5-*.cfg`, otherwise the bench options).
`tools/t5sum.py` makes `summary.txt` from the perf lines and RetroArch's GET_PERF_INFO. Rounds 1 / 2:

| Scene | skip | swap delayed (shipped) | swap not delayed |
| --- | --- | ---: | ---: |
| Crazy Taxi, still scene | off | 100.1 / 100.2%, 60.03 fps | 100.1 / 100.2%, 60.03 fps |
| City Escape, 55-90 s | off | 99.7 / 99.6%, p95 18.1 / 17.8 ms | 99.6 / 99.5%, p95 18.0 / 18.0 ms |
| City Escape | more | 99.9 / 99.9%, 0.29 / 0.26 skipped/s | 100.0 / 100.0%, 0.26 / 0.18 skipped/s |
| NFL 2K2, saved play | off | 94.8 / 94.3% | 94.3 / 92.5% |
| NFL 2K2 | more | 99.2 / 99.2%, 4.6 / 5.0 skipped/s | 99.1 / 99.0%, 4.8 / 5.4 skipped/s |
| Armada, over the base | off | 100.3 / 100.3% | 100.3 / 100.3% |
| Sega Rally 2 attract | off | 73.6 / 73.4% | 74.3 / 74.1% |
| Sega Rally 2 | more | 76.1 / 75.7% | 76.3 / 76.3% |

Late frames and the worst frame time are in `summary.txt` and match within the spread too. Sega Rally
2 was the 30 fps candidate, but its attract race is limited by the SH4 thread (50-76% speed), not a
clean 30 fps lock.

## Picture

`device-checks/frame-check.sh` can pair frames across the two settings, but it can't see the
difference: it hashes a frame when it is drawn, not when it is shown. With the swap not delayed, the
core shows a frame as soon as it is drawn to the screen's framebuffer, including one the game draws
over or never flips to. So the diagnostic build counts those (`tools/t5pic.sh`, 25 games booted from
the BIOS with no input, about 55 s each, `picture/unflipped-renders.txt`):

- 0-2 such frames per game: Dead or Alive 2 2; Sega Rally 2, Sonic Adventure, Capcom vs. SNK and
  Virtua Fighter 4 1 each; all others 0. All at boot and logo transitions, so each is a possible
  one-frame flash.
- Spider-Man's intro videos: none.
- Screenshots at fixed times in the six games run both ways look the same (kept with the bench, not
  here).

## Conclusion

- Keep Delay Frame Swapping enabled. Turning it off buys no speed on the MLP1 and can show a stray
  frame at a transition.
- A changed default would not reach a card that already has a `Flycastrophe.opt` anyway.
- The bench can run the shipped setting from now on; it makes no measurable difference. Keep Auto
  Skip Frame off for render measurements, since skipping hides render cost.
