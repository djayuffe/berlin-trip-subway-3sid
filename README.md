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
source. The assembled program is always written to
`build/berlin-trip-subway-3sid.prg`; only versioned release archives use a
version in their filename.

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

## Effect previews

### Verified boot-path capture

This frame was captured after the BASIC loader executed `SYS 2061`, passed
through the fixed `$080d` boot jump, and reached `MegaMain` initialization.

![Running effect reached through the verified boot path](assets/boot-path-effect.png)

### Pulse-field palette phases

These are two VICE captures of the opening **3SID pulse field** at different
music-driven palette phases. They are cropped to the C64 viewport; no desktop
or emulator controls are included.

| Magenta pulse phase | Blue pulse phase |
| --- | --- |
| ![Magenta phase of the 3SID pulse field](assets/3sid-pulse-field-magenta.png) | ![Blue phase of the 3SID pulse field](assets/3sid-pulse-field-blue.png) |

The effect fills the text screen with `SafeTunnelChars` and derives its colour
index from the frame counter plus the three SID pulse values. This makes the
geometry stable enough to read while the palette responds to the soundtrack.

The source-level music review is retained in
[`V6_0_0_MUSIC_AUDIT.json`](V6_0_0_MUSIC_AUDIT.json), and the accompanying
arrangement notes are in [`V6_0_0_NOTES.md`](V6_0_0_NOTES.md). See
[`AUDIT.md`](AUDIT.md) for the repository cleanup and verification record, and
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the effect and function map.
[`docs/EFFECTS.md`](docs/EFFECTS.md) describes the rendering and timing of every
active scene.
Release-specific setup and contents are documented in
[`RELEASE_NOTES.md`](RELEASE_NOTES.md).

## Verification

```sh
make check
```

This rebuilds the PRG and verifies the tracked-source checksums. Run
`make checksums` only after an intentional source or documentation change.
