Issue 1282 implementation validation
===================================

The fix records three permanent milestones: leaving Celadon, starting the Ho-Oh encounter, and acknowledging the tower farewell. One resolver determines Eusine's state and both standing NPCs' visibility. Ho-Oh respawning no longer resets Eusine. Grandpa awards the doll after the farewell and still checks its existing ownership flag.

The baseline reproduction and before/after flowcharts remain in [PLAN.md](PLAN.md). Save version **11** and the SRAM layout are unchanged. The required external v10→v11 migration is documented in [SAVE_PATCHER.md](SAVE_PATCHER.md); that patcher repository was inspected but not modified.

**Build and layout checks**

- Normal and faithful builds succeed with no assembler/linker warnings. Faithful was built in an isolated source copy to avoid sharing normal-variant object files.
- `utils/optimize.py` reports zero findings for the new resolver and changed map/event routines. The `dec a` optimizations have assertions for adjacent state values; the zero-state check also has an assertion.
- All 2,268 pre-existing event constants retain their values. The new IDs are 2289–2291, within previously unused tail space. `NUM_EVENTS` remains 2303 and the event array remains 288 bytes.
- All 23,526 existing SRAM/WRAM/HRAM symbols retain their addresses in both builds. `constants/misc_constants.asm`, including `SAVE_VERSION = 11`, is unchanged from the baseline.
- The regression driver verifies matching primary/backup game data, both checksums, the completed-save marker, and version 11 after each of five real `SaveGameData` calls, then cold-boots and Continues those saves.

**Emulator coverage**

Tests use the core from the requested sibling `../vibeEmu`, revision `b7938e412584e2dfa6385eaa27b331533a2e543a`. The driver executes the assembled ROM's actual CPU instructions, callbacks, dialogue, movement, save routines, and field-move/whiteout scripts. It loads the existing local seed into memory and verifies that the ROM, symbols, and seed file are unchanged afterward.

| Check | Executed coverage |
| --- | --- |
| Resolver | 32,768 combinations of the three new bits, Suicune progression, old Ho-Oh fight/native catch, eight beast masks, Wing, League, doll, both visibility bits, and unrelated caught bits. Each combination runs twice for idempotence and checks preservation of unrelated event flags. Invalid new-bit combinations verify precedence as well. |
| Original bug | Finish the farewell before visiting Celadon; house remains empty; return to 1F directly and via 2F; Eusine stays absent. |
| Home progression | All eight native beast masks before/after League; Wing received with other prerequisites absent; no premature departure; original notes remain usable. |
| Departure movement | House from below/left/above and tower from below/left/right/above, including the player-step-aside paths. Scripts finish without getting stuck. |
| Grandpa | Researching, departed, pending farewell, completed farewell, and repeat conversation after receiving the doll. Only completed farewell awards it. |
| Respawning | Actual `RespawnOneOffs` for research/departed/pending/completed, each with Ho-Oh caught and uncaught; early search remains early after League. Only uncaught Ho-Oh's fight flag resets. |
| Ho-Oh encounter | Actual prebattle script starting from research, departed, and completed farewell. Left/encounter flags are set before combat; an existing farewell remains set. |
| Battle outcomes | Complete Ho-Oh and Suicune scripts with injected KO, escape, catch, and loss results at the battle engine boundary. Native catch flags change only on catch. Suicune consumes its scene and hides superseded early Eusines, including on loss. Ho-Oh loss runs the real whiteout warp and leaves farewell pending. |
| Field-move eligibility | Actual eligibility routines on all ten tower floors and the roof. Rope/Dig allowed on floors with a recorded destination; disallowed on the roof. Fly/Teleport allowed on the roof and disallowed on the floors. |
| Field-move exits | Actual Rope, Dig, Teleport, and Fly scripts, including animations and map setup, in pre-encounter/pending/completed states. Rope/Dig reaches Bellchime Trail; Fly/Teleport reaches the selected Celadon destination. Progress is preserved. |
| Save/Continue | Pending and completed tower, researching and completed house, and pending roof. Uses real save code and a fresh emulated boot, rather than savestate restoration, to verify Continue's cached-object behavior. |

Per ROM variant, the run includes 49 completed scripts, eight controlled battle results, five save/checksum/Continue checks, and 732 logged passing checks in addition to the exhaustive resolver's internal assertions. Retained commands, logs, hashes, and selected screenshots are under [verification](verification/).

The normal run completed in one process. The first faithful process terminated with exit 143 during the final Suicune fixture, without a failed assertion. That independent fixture and the remaining field-move cases were restarted from the same neutral snapshot and passed. The faithful trace marks the restart; its input hashes were recorded afterward, and the original seed still matches the baseline hash.

**Scope and limits**

This is a debugger-assisted regression suite, not an uninterrupted new-game playthrough. Fixtures supply prerequisites, inventory-independent catch history, party data, and travel positions. The eight battle checks substitute the battle engine's return value; they do not conduct combat, throw balls, or prove catch inventory/box behavior. They exercise the real encounter scripts on either side of that boundary, including the real loss handler.

Field-move checks invoke the eligibility routines and queue the actual exit scripts with valid destinations. They do not navigate party/item menus or assert Escape Rope consumption. Canceled menus, missing moves/items, invalid destinations, failed catches/full boxes, normal early Cianwood battles, loading an older save, and overworld poison handling were reviewed in existing source rather than played end to end. Those paths contain no writes to the new milestones; only the house departure, Ho-Oh battle entry, and farewell acknowledgement advance them. The existing Suicune scene cleanup consumes the optional Route 36/Cianwood/Route 42 sightings, and the new resolver additionally hides superseded early Eusines without fabricating a Cianwood battle win.

Migration inference and converted-save tests belong to the external patcher follow-up described in [SAVE_PATCHER.md](SAVE_PATCHER.md). They are not claimed as passing here. Existing version-11 development saves predating this change cannot be automatically distinguished without another version bump; the handoff documents this separately from released v10 conversion.

**Reproduce the fixed-ROM checks**

From the repository root, after building the desired ROM:

```sh
python3 docs/issue-1282/verify.py
python3 docs/issue-1282/verify.py \
  --rom /path/to/polishedcrystal-faithful-3.2.3.gbc \
  --sym /path/to/polishedcrystal-faithful-3.2.3.sym \
  --output /tmp/issue1282-verify-faithful
```

Requires Rust, locally cached Cargo dependencies, Pillow, and `../vibeEmu`. `--save` selects the seed; the default is the existing local save identified in the baseline report. A different seed may require different title/Continue input timing. Build artifacts and emulated snapshots stay in `/tmp`; no ROM, cartridge save, or emulator snapshot is checked into this deliverable.
