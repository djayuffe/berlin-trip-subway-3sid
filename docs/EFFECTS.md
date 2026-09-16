# Effect guide

Each scene owns text-screen rows 0–23 and matching colour RAM; the last row is
left untouched. `partId` selects paired routines in `InitTbl` and `UpdateTbl`.
`PartBarsTbl` controls scene duration in 16-row music bars, transitions fade
from row 12, and the next scene begins at row 0. After each scene update,
`ThreeSIDEffectPolish` applies shared audio-reactive rails: SID1 colours the
top, SID2 a lower rail, and SID3 the side accents.

`sndPulse`, `musicPulse`, `zoomPulse`, and `beatSin` are derived by the IRQ
music clock. Effects consume these values rather than reading SID registers,
which keeps audio and rendering timing separate.

## How scenes are built

Every scene has an initializer and an update routine. Initializers reset local
phase/state and clear or prepare their text cells. Update routines are called
from the frame-driven main loop and either redraw their owned field completely
or first erase the previously plotted cells. No scene changes the IRQ setup,
VIC video mode, SID register ownership, or global scene timer.

The 28 scenes fall into four rendering families:

| Family | Scene IDs | Shared approach |
| --- | --- | --- |
| Full-field procedural | 0–5, 7, 9–16, 18–20, 24–26 | Compute glyph and colour from row, column, phase, and pulse inputs. |
| Particle/state based | 2, 6 | Keep compact star coordinates, erase old cells, then plot updated positions. |
| Mask/table geometry | 8, 12, 17, 21–23, 27 | Read precomputed masks, rails, coordinate frames, or mirrored points. |
| Shared polish | all scenes | `ThreeSIDEffectPolish` adds audio-reactive colour rails after the scene update. |

The active render area is rows 0–23. Scene code therefore avoids using row 24
as a persistent drawing surface, leaving a safe margin for runtime conventions
and future presentation changes.

## 0. 3SID pulse field — `ti_init`, `ti_update`

The opening is a full-field procedural pattern. Character selection combines
cell position, `tiPhase`, and `frameCounter`; colour adds all three SID pulse
values. It is stateless per frame apart from phase, so it never leaves trails.

## 1. Plasma storm — `pl_init`, `pl_update`

Plasma storm redraws an interference-style colour-RAM field as its phase moves.
Its spatial arithmetic produces drifting bands with no bitmap or frame buffer.

## 2. Hyperspace — `hs_init`, `hs_spawn`, `hs_update`

Stars are held in 8.8 fixed-point coordinates and move out from the centre.
`hs_spawn` gives each expired star a new non-zero direction; `hs_update` plots,
colours, and respawns stars when they leave the display.

## 3. XOR moiré — `xr_init`, `xr_update`

The renderer combines row, column, and phase with XOR-like arithmetic. The
result is a sharp diamond/interference pattern that is redrawn completely each
frame.

## 4. Waves — `wv_init`, `wv_update`

Waves displaces horizontal colour bands with phase-based row/column arithmetic.
The full redraw prevents stale colours when a band changes direction.

## 5. Perspective tunnel — `tn_init`, `tn_update`

The tunnel samples `TnXMul`, row-base, and column-warp tables. Advancing depth
and phase turn a character grid into a converging tunnel while keeping all
per-frame operations table-bounded.

## 6. Sine starfield — `ss_init`, `ss_update`, `ss_ptr`

Fast and slow star arrays produce parallax. `ss_update` advances both layers,
and `ss_ptr` converts a star row/column into text and colour pointers. Stars are
reseeded after leaving the active field.

## 7. Fire — `ts_init`, `ts_update`

The fire scene evolves a compact lower-to-upper field using character and
colour updates. Bounded writes create a rising-fire appearance in text mode.

## 8. Heart voyager — `hv_init`, `hv_update`

Heart voyager turns the heart tables into a moving trail. Phase and coordinate
tests decide which cells receive a heart character and which are blanked.

## 9. Multiplex cube — `mc_init`, `mc_update`

This scene layers cube characters under a timed phase. It refreshes every cell
it owns, so moving cube edges cannot retain old colours.

## 10. Yaw-wobble tunnel — `yw_init`, `yw_update`

This tunnel variant adds a phase-dependent horizontal wobble before choosing its
character and colour. The wobble makes the perspective field appear to yaw.

## 11. Turbo boot tunnel — `tb_init`, `tb_update`

Turbo boot tunnel uses a faster phase/depth cadence than the other tunnel
renderers, producing more abrupt forward motion with the same safe text-mode
write model.

## 12. Golden halo heart — `gh_init`, `gh_update`

`HeartShapeMask` defines the silhouette. The renderer reads the mask by row,
adds phase/pulse variation to the palette index, draws gold cells inside it,
and clears the surrounding cells.

## 13. Raster grid boot — `rg_init`, `rg_update`

Raster grid boot steps geometric grid lines through phase and colour tables to
create boot-screen-like raster movement without changing VIC video mode.

## 14. Cyber grid — `cg_init`, `cg_update`

Cyber grid independently selects glyphs from `GridChars` and colours from
`GridColors` using row, column, and phase. The split tables make its character
design and palette cycle independently.

## 15. Safe Tunnel Prime — `sp_init`, `sp_update`

Safe Tunnel Prime combines `SafeTunnelChars`, `SafeTunnelColors`, and bounded
wobble indexes. It is the deliberately range-safe tunnel implementation.

## 16. Black orbit — `bo_init`, `bo_update`

The orbit uses `BlackOrbitMask`, glyph, and colour tables to control illuminated
cells. Phase walks the mask through the field, retaining dark negative space.

## 17. Rotor cube — `rc_init`, `rc_update`

The `RcFront*` and `RcBack*` tables define stable front/back face coordinates.
`rc_update` selects the current frame, draws faces/connectors, and clears cells
outside the selected geometry, avoiding unstable calculated-line rotation.

## 18. Solar flare — `PortedInit`, `SolarFlareRender`

The shared initializer clears the screen and resets `enginePhase`. Solar flare
calculates cell distance from the centre, combines it with phase/audio energy,
and looks up `SolarChars` and `SolarColors` for a bright radial pulse.

## 19. Prism gate — `PortedInit`, `PrismGateRender`

Prism gate uses mirrored coordinate arithmetic and prism character/palette
tables to produce a symmetric gate that changes depth and colour with phase.

## 20. Twist lattice — `PortedInit`, `TwistLatticeRender`

Twist lattice derives a repeated lattice from position and phase, selecting from
`TwistChars` and `TwistColors`. Opposing phase directions create the twist.

## 21. Infinity corridor — `ic_init`, `ic_update`

The corridor reads `DistBase` through row pointers and warps columns with
`NfxColWarp`. Phase and `sndPulse` choose glyphs/colours, background, and
border, so the entire scene responds to the music.

## 22. Gold trench — `gt_init`, `gt_update`

`NfxTrenchLeft` and `NfxTrenchRight` define rails for each row. The update adds
main/inner glow rails, beat-gated crossbars, and a central vanishing line;
interior cells explicitly clear colour RAM to prevent gold trails.

## 23. Cube V3 rotor — `cv_init`, `cv_update`

`cv_update` clears rows 4–22, selects one of 16 geometries with
`CvBuildGeometry`, draws front/back squares through `CvDrawWireCube`, and adds
corners plus an eight-point inner spin core. `CvDiagLine` has independent X/Y
offset tables so each depth vector lands on the rear face.

## 24. Vortex — `vx_init`, `vx_update`

Vortex reads the precomputed `VortexBase` angle/distance field and combines it
with phase to select colours. Precomputation keeps polar-style work out of the
frame loop.

## 25. Mux edge field — `mb_init`, `mb_update`

Mux edge field combines cell position and phase to highlight travelling edges.
It redraws its owned field each frame so the multiplexed edge remains crisp.

## 26. Raster boot — `rb_init`, `rb_update`

Raster boot is a distinct phase-driven boot pattern using `RasterBootChars` and
`RasterBootColors`, separate from the grid and tunnel palettes.

## 27. Wire cube — `nw_init`, `nw_update`

Wire cube clears rows 3–22 and draws twelve paired glyphs at mirrored columns.
Both the mirror position and colour use the same `nw_phase`/`sndPulse` offset,
keeping the halves synchronized. `NfxCoolPalette` drives its reactive border
against a black background.
