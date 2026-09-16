# Architecture and source map

This document covers every active, globally named routine in
[`src/subway.s`](../src/subway.s). Labels beginning with `@` or `.` are local
branches within the routine immediately above them; they are intentionally not
treated as independent functions.

## Runtime flow

```text
BASIC `10 SYS 2061` → `$080d` `BootStart` → `MegaMain`
                                                ↓
                         SetupVIC / TV_MusInit / SeedRand
                       → InstallIRQ
IRQ at raster line 250 → TV_PlayMusic → ComputeVisualPulses → frameReady
MainLoop → snapshot row/beat edges → UpdatePart or StepTransition
         → ThreeSIDEffectPolish → next IRQ frame
```

`BootStart` is an unconditional `JMP MegaMain`, not a fall-through convention.
The source asserts that the BASIC line ends exactly at `$080d`, protecting the
decimal `SYS 2061` target from later loader edits.

The main loop and the IRQ communicate through sticky row/beat flags. The main
loop clears those flags while interrupts are briefly disabled, preventing a
longer visual renderer from losing a musical boundary.

## Frame and scene lifecycle

1. `MegaMain` initializes the video, music, scene 0, and the IRQ.
2. The IRQ executes every PAL frame, runs the music engine, derives pulse data,
   and sets `frameReady`.
3. `MainLoop` waits for that flag, then atomically copies `TV_RowEdge` and
   `TV_BeatEdge` into its private main-loop flags.
4. `UpdatePart` tail-dispatches the selected renderer. Renderers return to the
   main loop rather than owning interrupts or scene timers.
5. At a bar boundary, the scheduler arms the fade. `TransCard` colours the
   frame from row 12 through row 15; the new scene initializes on the next
   row-0 edge.

This separation is deliberate: music timing stays in the IRQ, while the
heavier text/colour RAM work stays outside it.

## Active effects

`partId` selects matching initializer and update entries from `InitTbl` and
`UpdateTbl`. Each scene lasts the number of 16-row bars in `PartBarsTbl`; it
then starts its fade at row 12 and changes scene on the next row 0.

| ID | Init / update | Effect and feature |
| --- | --- | --- |
| 0 | `ti_init` / `ti_update` | 3SID pulse field; character and colour cells react to all three audio pulse values. |
| 1 | `pl_init` / `pl_update` | Plasma storm; interference-style colour-RAM field. |
| 2 | `hs_init` / `hs_update` | Hyperspace; centre-out 8.8 fixed-point stars. `hs_spawn` re-seeds expired stars. |
| 3 | `xr_init` / `xr_update` | XOR moiré; sharp diamond interference pattern. |
| 4 | `wv_init` / `wv_update` | Waves; sine-displaced horizontal colour bands. |
| 5 | `tn_init` / `tn_update` | Perspective tunnel; precomputed X multiplier and barrel-warp tables. |
| 6 | `ss_init` / `ss_update` | Sine starfield; independent fast and slow star layers. `ss_ptr` maps a star to screen/colour RAM. |
| 7 | `ts_init` / `ts_update` | Rising fire / tunnel-safe inline colour renderer. |
| 8 | `hv_init` / `hv_update` | Heart voyager; animated heart trail. |
| 9 | `mc_init` / `mc_update` | Multiplex cube; layered character cube field. |
| 10 | `yw_init` / `yw_update` | Yaw-wobble tunnel; per-column wobble and tint. |
| 11 | `tb_init` / `tb_update` | Turbo boot tunnel; accelerated tunnel cadence. |
| 12 | `gh_init` / `gh_update` | Golden halo heart; heart mask with a gold palette. |
| 13 | `rg_init` / `rg_update` | Raster grid boot; moving grid/raster pattern. |
| 14 | `cg_init` / `cg_update` | Cyber grid; character grid with animated colour field. |
| 15 | `sp_init` / `sp_update` | Safe Tunnel Prime; bounded tunnel variant. |
| 16 | `bo_init` / `bo_update` | Black orbit; masked orbital pattern. |
| 17 | `rc_init` / `rc_update` | Rotor cube; table-defined front/back geometry. |
| 18 | `PortedInit` / `SolarFlareRender` | Solar flare; radial character/colour field. |
| 19 | `PortedInit` / `PrismGateRender` | Prism gate; mirrored geometric gate. |
| 20 | `PortedInit` / `TwistLatticeRender` | Twist lattice; rotating lattice field. |
| 21 | `ic_init` / `ic_update` | Infinity corridor; depth table, colour warp, and animated border/background. |
| 22 | `gt_init` / `gt_update` | Gold trench; rails, glow, crossbars, and vanishing markers. |
| 23 | `cv_init` / `cv_update` | Cube V3 rotor; table-driven two-plane wire cube with a spinning inner core. |
| 24 | `vx_init` / `vx_update` | Vortex; precomputed angle/distance colour field. |
| 25 | `mb_init` / `mb_update` | Mux edge field; multiplexed edge animation. |
| 26 | `rb_init` / `rb_update` | Raster boot; boot-style animated raster field. |
| 27 | `nw_init` / `nw_update` | Wire cube; mirrored glyph pairs, beat-synchronised colour, and animated border. |

## Core and scheduler routines

| Routine | Responsibility |
| --- | --- |
| `MegaMain` | Program entry: banks out BASIC ROM, disables CIA IRQs, prepares video/music/random state, starts scene 0, and installs the raster IRQ. |
| `MainLoop` | Waits for `frameReady`, takes an atomic timing snapshot, renders or transitions, and applies shared 3SID visual polish. |
| `SetupVIC` | Selects VIC bank 0, screen `$0400`, ROM charset view `$1000`, and 40-column text mode. |
| `ClearScreenColor` | Clears all 1,000 text cells and 1,000 colour-RAM cells, restores text mode, and disables sprites. |
| `InstallIRQ` | Installs `MegaMain_IRQ` at the KERNAL IRQ vector and enables VIC raster interrupts. |
| `MegaMain_IRQ` | Acknowledges the raster IRQ, clocks music and visual pulses, raises `frameReady`, reinstalls itself, and chains to the KERNAL. |
| `ThreeSIDEffectPolish` | Adds bass/lead/drum pulse colour rails around every scene. |
| `SetPartTimer` | Converts the selected scene’s bar length into the countdown state used by the main loop. |
| `BeginTransition` | Arms a transition, chooses the next scene modulo 28, and clears border/background. |
| `StepTransition` / `TransCard` | Executes the row-12-to-row-0 colour fade and initializes the next scene. |
| `InitPart` / `UpdatePart` | Indirectly dispatch to the active initializer or update routine. |
| `PrintCenteredAuto` / `PrintCentered` | Measure a `$ff`-terminated screen-code string and render it centred in text and colour RAM. |

## Shared render and utility routines

| Routine | Responsibility |
| --- | --- |
| `PortedInit` | Common clear/reset initializer for the solar, prism, and twist scenes. |
| `SolarFlareRender` | Renders the radial solar-flare scene from phase and palette tables. |
| `PrismGateRender` | Renders the prism-gate scene from phase and palette tables. |
| `TwistLatticeRender` | Renders the twisting lattice scene. |
| `CvClearField` | Clears only the cube rotor’s active rows. |
| `CvBuildGeometry` | Loads one stable frame from `CvFrameGeom` and derives front/back cube coordinates. |
| `CvDrawWireCube` | Draws the two squares and their four depth connectors. |
| `CvDrawCorners` / `CvDrawSpinCore` | Add bright cube corners and eight animated inner-core points. |
| `CvPlotPoint`, `CvHLine`, `CvVLine`, `CvDiagLine` | Low-level cube plotting primitives. |
| `Rand8` / `SeedRand` | Eight-bit pseudo-random generator and CIA-timer seed routine. |
| `Mod40` / `Mod25` | Bounded modulo helpers for screen columns and rows. |
| `ComputeVisualPulses` | Converts music row/phase state into audio-energy, beat-sine, and zoom values for effects. |

## Music and sound routines

| Routine | Responsibility |
| --- | --- |
| `TV_MusInit` | Clears all three SID register ranges, configures instrument envelopes/filters, and starts Berlin A at row 0. |
| `SelectStyle` | Patches pattern-table read operands and selects waveform, speed, filter, volume, PWM, and transpose settings. |
| `MusXpose` | Applies and bounds a semitone transpose before frequency-table lookup. |
| `TV_DecayPulses` | Decays audio and SID visual pulse values at 50 Hz. |
| `TV_PlayMusic` | Master music clock: advances rows/sections, sets beat edges, triggers rows, arpeggiates, and runs filter/PWM/drum updates. |
| `TV_MusFilter` / `TV_MusPwm` | Apply continuous filter and pulse-width modulation to SID1/SID2. |
| `TV_DrumPitch` | Sweeps the kick and applies independent bass/melody sidechain volume reductions. |
| `TV_MusArp` | Plays the three arpeggio lanes and controls SID2 harmony/shimmer voices. |
| `TV_MusRowTrigger` | Reads bass and drum pattern cells for the current row and invokes the appropriate sound triggers. |
| `DrumKick`, `DrumAccentKick`, `DrumSnare`, `DrumHat`, `DrumOpenHat` | Select the drum event envelope and delegate to the core register writers. |
| `DrumKickCore`, `DrumSnareCore`, `DrumHatCore`, `DrumOpenHatCore` | Write SID3 voice registers for the chosen drum sound. |
| `DrumFlash` / `SndAdd` / `TV_MusFlash` | Feed visual pulse energy and perform the beat flash/border decay. |

## Data contracts

- `SCREEN` is `$0400`; `COLOR` is `$d800`; both are treated as 25 rows × 40 columns.
- `SPTR`/`CPTR` are effect scratch pointers; `ZP_MLO..ZP_BHI` are reserved for IRQ music pointers. Do not reuse them across those domains.
- Music pattern value `$ff` means silence. Pattern rows are zero-based and Berlin A/B use 64 rows.
- The assembly-time `$c000` guard prevents code/data from entering the KERNAL ROM region.

## Memory and ownership map

| Range | Owner | Use |
| --- | --- | --- |
| `$0801`–program end | Demo | BASIC stub, boot trampoline, code, and static effect/music data. |
| `$0002`–`$0006` | Main loop | Small temporary values and text-pointer scratch storage. |
| `$00f7`–`$00fa` | IRQ music | Pattern-table pointers; effects must not reuse them. |
| `$00fb`–`$00fe` | Renderers | Screen and colour RAM pointers. |
| `$0400`–`$07e7` | VIC/text renderers | 1,000 screen-code cells. |
| `$1000` | VIC view | ROM character set visible through the selected bank configuration. |
| `$d400`, `$d420`, `$d440` | SID chips | Bass/sub, melodic, and drum register banks. |
| `$d800`–`$dbe7` | VIC/text renderers | 1,000 colour-RAM nibbles. |

The program keeps I/O and KERNAL visible because the IRQ chain continues into
the KERNAL handler. BASIC ROM is banked out during the demo; the PRG itself
does not rely on BASIC after the initial `SYS` call.
