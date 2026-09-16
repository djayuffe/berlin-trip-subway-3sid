# Audit record

The current source and documentation were reviewed after the initial archive
import.

## Corrections made

- Replaced stale U83R/megademo names and incorrect output paths with the Berlin
  project name and canonical PRG path.
- Added a root Makefile, ignored generated artifacts, and made the release
  wrapper call the same build target.
- Corrected the ACME invocation so `!binary` asset paths resolve from `src/`.
- Documented the required VICE three-SID addresses and corrected the tempo to
  approximately 107 BPM at PAL 50 Hz / seven frames per row.
- Repaired three visual-state defects: the wire-cube and gold-trench effects
  now apply their calculated border/background values, the corridor does the
  same, and the wire-cube mirror colour uses the same beat offset as its glyph.
- Removed disabled split-IRQ, scroller, empty title-card, dead timing-table,
  unused palette, and obsolete compatibility scaffolding.

## Verification

`make check` performs a fresh ACME build and validates the tracked-source
checksum manifest. A bounded VICE console smoke test has also been run using
SID addresses `$d400`, `$d420`, and `$d440`.
