Issue 1282 implementation validation
===================================

The fix records three permanent milestones: leaving Celadon, starting the Ho-Oh encounter, and acknowledging the tower farewell. One resolver determines Eusine's state and both standing NPCs' visibility. Ho-Oh respawning no longer resets Eusine. Grandpa awards the doll after the farewell and still checks its existing ownership flag.

The baseline reproduction and before/after flowcharts remain in [PLAN.md](PLAN.md). Save version **11** and the SRAM layout are unchanged. The required external v10→v11 migration is documented in [SAVE_PATCHER.md](SAVE_PATCHER.md); that patcher repository was inspected but not modified.

**Build and layout checks**

- Normal and faithful builds succeed with no assembler/linker warnings. Faithful was built in an isolated source copy to avoid sharing normal-variant object files.
- `utils/optimize.py` reports zero findings for the new resolver and changed map/event routines. The `dec a` optimizations have assertions for adjacent state values. The obsolete zero-state check was removed with the early-map writes.
- All 2,268 pre-existing event constants retain their values. The new IDs are 2289–2291, within previously unused tail space. `NUM_EVENTS` remains 2303 and the event array remains 288 bytes.
- All 23,526 existing SRAM/WRAM/HRAM symbols retain their addresses in both builds. `constants/misc_constants.asm`, including `SAVE_VERSION = 11`, is unchanged from the baseline.
- The regression driver verifies matching primary/backup game data, both checksums, the completed-save marker, and version 11 after each of five real `SaveGameData` calls, then cold-boots and Continues those saves.

**Emulator coverage**

Tests use the core from the requested sibling `../vibeEmu`, revision `b7938e412584e2dfa6385eaa27b331533a2e543a`. The driver executes the assembled ROM's actual CPU instructions, callbacks, dialogue, movement, save routines, and field-move/whiteout scripts. It loads the existing local seed into memory and verifies that the ROM, symbols, and seed file are unchanged afterward.

| Check | Executed coverage |
| --- | --- |
| Defensive resolver inputs | 32,768 combinations of the three new bits, Suicune progression, old Ho-Oh fight/native catch, eight beast masks, Wing, League, doll, both visibility bits, and unrelated caught bits. Each combination runs twice for idempotence and checks preservation of **every** event flag except the two house/tower visibility outputs. This deliberately includes impossible histories and invalid new-bit combinations to verify precedence, not gameplay reachability. |
| Original bug | Finish the farewell before visiting Celadon; house remains empty; return to 1F directly and via 2F; Eusine stays absent. |
| Home progression | All eight native beast masks after League; Wing with its actual prerequisites; original notes remain usable. A separate 1F check verifies the League gate before/after League with all beasts caught. |
| Departure movement | House from below/left/above and tower from below/left/right/above, including the player-step-aside paths. Scripts finish without getting stuck. |
| Grandpa | Early searching after League, researching, departed, pending farewell, completed farewell, and repeat conversation after receiving the doll. Only completed farewell awards it. |
| Respawning | Actual `RespawnOneOffs` for research/departed with no prior Ho-Oh encounter, and pending/completed with Ho-Oh caught or uncaught; early search remains early after League. Only uncaught Ho-Oh's fight flag resets. |
| Ho-Oh encounter | Actual prebattle script starting from research, departed, and completed farewell. Left/encounter flags are set before combat; an existing farewell remains set. |
| Battle outcomes | Complete Ho-Oh and Suicune scripts with injected KO, Poké Doll escape, catch, and loss results at the battle engine boundary. Native catch flags change only on catch. Suicune consumes its scene, including on loss. Early-map visibility stays hidden, and the optional Cianwood encounter-consumed flag remains unchanged whether skipped or already consumed. Ho-Oh loss runs the real whiteout warp and leaves farewell pending. |
| Actual battle menu | Run is rejected with “Can’t escape!”; selecting a Poké Doll in the item menu consumes it, returns result `$02`, exits combat, and preserves the pending farewell. Both variants execute this without injecting a battle result. |
| Field-move eligibility | Actual eligibility routines on all ten tower floors and the roof. Rope/Dig allowed on floors with a recorded destination; disallowed on the roof. Fly/Teleport allowed on the roof and disallowed on the floors. |
| Field-move exits | Actual Rope, Dig, Teleport, and Fly scripts, including animations and map setup, in pre-encounter/pending/completed states. Rope/Dig reaches Bellchime Trail; Fly/Teleport reaches the selected Celadon destination. Progress is preserved. |
| Save/Continue | Pending and completed tower, researching and completed house, and pending roof. Uses real save code and a fresh emulated boot, rather than savestate restoration, to verify Continue's cached-object behavior. |

Per ROM variant, the updated run includes 43 completed scripts, eight controlled battle results, five save/checksum/Continue checks, and 679 logged passing checks in addition to the exhaustive resolver's internal assertions. Both updated runs completed in a single process. Retained commands, logs, hashes, and selected screenshots are under [verification](verification/). The current evidence replaces the original publication's results, which used impossible fixture combinations and included an interrupted faithful run.

The fixture generator now asserts necessary fresh-save history invariants: valid milestone combinations, native Suicune implies its scene, Wing implies League and all native beasts, later milestones imply their prerequisites, and native Ho-Oh implies an encounter and fought flag. Debugger travel to Celadon requires League; upper tower/roof travel requires Wing. These checks prevent the specific invented scenarios found in review; they are not proof of every unrelated field in the debug seed.

**Scope and limits**

This is a debugger-assisted regression suite, not an uninterrupted new-game playthrough. Fixtures supply prerequisites, inventory-independent catch history, party data, and travel positions. The eight battle checks substitute the battle engine's return value; they do not conduct combat, throw balls, or prove catch inventory/box behavior. They exercise the real encounter scripts on either side of that boundary, including the real loss handler. The separate Run/Poké Doll check uses the actual battle and item menus. Battle Teleport and Roar rejection were verified in source, not selected in battle.

Field-move checks invoke the eligibility routines and queue the actual exit scripts with valid destinations. They do not navigate party/item menus or assert Escape Rope consumption. Canceled menus, missing moves/items, invalid destinations, failed catches/full boxes, normal early Cianwood battles, loading an older save, and overworld poison handling were reviewed in existing source rather than played end to end. Those paths contain no writes to the new milestones; only the house departure, Ho-Oh battle entry, and farewell acknowledgement advance them. The existing Suicune scene cleanup consumes the optional Route 36/Cianwood/Route 42 sightings. Existing progression already hides early Eusine appearances before this stage; the new resolver does not write their visibility or encounter-consumed flags. The Cianwood encounter flag is set before battle and remains set on loss, so it is not strictly a win flag.

Migration inference and converted-save tests belong to the external patcher follow-up described in [SAVE_PATCHER.md](SAVE_PATCHER.md). They are not claimed as passing here. Existing version-11 development saves predating this change cannot be automatically distinguished without another version bump; the handoff documents this separately from released v10 conversion.

**Reproduce the fixed-ROM checks**

Build the ROM in the code checkout and run the driver from the documentation checkout, passing absolute paths (replace `/path/to` with your checkout locations):

```sh
python3 /path/to/docs-checkout/docs/issue-1282/verify.py \
  --rom /path/to/code-checkout/polishedcrystal-3.2.3.gbc \
  --sym /path/to/code-checkout/polishedcrystal-3.2.3.sym \
  --save /path/to/code-checkout/polishedcrystal-debug-3.2.3.sav \
  --vibe-emu /path/to/vibeEmu \
  --output /tmp/issue1282-verify-normal
```

For faithful, supply the faithful ROM and symbols built in an isolated copy and a separate output directory. Both drivers support `--vibe-emu` so the documentation worktree need not sit next to the emulator checkout.

Requires Rust, locally cached Cargo dependencies, Pillow, and `../vibeEmu`. `--save` selects the seed; the default is the existing local save identified in the baseline report. A different seed may require different title/Continue input timing. Build artifacts and emulated snapshots stay in `/tmp`; no ROM, cartridge save, or emulator snapshot is checked into this deliverable.
