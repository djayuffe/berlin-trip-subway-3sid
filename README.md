# Berlin Trip Subway 3SID

A C64 text-mode demo with 28 visual scenes and a three-SID soundtrack. It is
assembled with [ACME](https://sourceforge.net/projects/acme-crossass/) and runs
on a PAL C64 or a compatible emulator configured for three SIDs.

## Requirements

- ACME 6502 cross-assembler (`acme`)
- VICE x64sc for local emulation (`x64sc`)

The program addresses SID chips at `$d400`, `$d420`, and `$d440`. A stock
single-SID C64 will render the demo, but only produces the first SID's audio.

## Build and run

```sh
make build
make run
```

`make run` starts VICE with two additional SIDs at the addresses used by the
source. The assembled program is written to
`build/berlin-trip-subway-3sid-v6.0.0.prg`.

## Design

- A single raster IRQ at line 250 provides the 50 Hz music clock and publishes
  a frame-ready flag.
- The main loop consumes row and beat edges atomically, updates one of 28
  dispatch-table-selected scenes, and advances scenes at musical bar
  boundaries.
- SID1 provides bass/sub voices, SID2 provides arpeggio/harmony/shimmer, and
  SID3 provides kick, snare, and hat voices.
- Berlin A and Berlin B are 64-row patterns. At seven PAL frames per row and
  four rows per beat, the tempo is approximately 107 BPM.

The source-level music review is retained in
[`V6_0_0_MUSIC_AUDIT.json`](V6_0_0_MUSIC_AUDIT.json), and the accompanying
arrangement notes are in [`V6_0_0_NOTES.md`](V6_0_0_NOTES.md). See
[`AUDIT.md`](AUDIT.md) for the repository cleanup and verification record, and
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the effect and function map.

## Verification

```sh
make check
```

This rebuilds the PRG and verifies the tracked-source checksums. Run
`make checksums` only after an intentional source or documentation change.
