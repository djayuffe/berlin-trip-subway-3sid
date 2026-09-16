# Berlin Trip Subway 3SID

Berlin Trip Subway 3SID is a 28-scene C64 text-mode demo with a timing-locked
three-SID soundtrack. This release packages the assembled PRG and the complete,
audited source needed to reproduce it.

## Highlights

- 28 distinct character-mode effects, including plasma, hyperspace, tunnels,
  hearts, grids, corridors, and table-driven wire cubes.
- Three independent SID roles: bass/sub at `$d400`, arpeggio/harmony at `$d420`,
  and drums at `$d440`.
- Berlin A/B arrangement with 64-row sections, bar-locked scene transitions,
  and approximately 107 BPM PAL timing.
- A single raster IRQ at line 250 keeps music, beat pulses, transitions, and
  effect timing synchronized.
- A fixed `$080d` boot trampoline protects the BASIC `SYS 2061` entry target
  and transfers control to the machine-code initialization routine.

## Running the demo

The PRG is `build/berlin-trip-subway-3sid.prg` inside the archive.
For full sound, configure an emulator or hardware for SIDs at `$d400`, `$d420`,
and `$d440`. With VICE x64sc:

```sh
make run
```

## Verification and source

Run `make check` to rebuild the PRG and validate the tracked-source checksum
manifest. `docs/ARCHITECTURE.md` maps the runtime and global callable routines;
`docs/EFFECTS.md` explains every active effect. `AUDIT.md` records the code and
build cleanup applied before this release.

The source archive also includes the README preview captures and their
checksums, so public documentation remains reproducible with the code.
