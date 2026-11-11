Eusine migration for the v3.3.0 save patcher
=========================================

Keep **save version 11**. The version bump for v3.3.0 already happened; this change belongs in the existing **released version 10 → version 11** conversion. It does not require a new save version, a new conversion step, or a change to SRAM layout.

Integration was reviewed against [codex/v3.3.0-save-patch](https://github.com/fellowship-of-the-roms/polished-save-patcher/tree/codex/v3.3.0-save-patch), commit `aa527e3005d137f38ff42ec55ca0fe4a58d2fc9a`. This document is the handoff for that repository; its source has not been modified here.

**Exact integration points**

- Add the Eusine conversion to [`src/patching/PatchVersion10to11.cpp`](https://github.com/fellowship-of-the-roms/polished-save-patcher/blob/aa527e3005d137f38ff42ec55ca0fe4a58d2fc9a/src/patching/PatchVersion10to11.cpp), after event initialization and before primary data is copied to backup and checksums are calculated.
- Read historical evidence from **`save10`**, not the already-modified `save11`. In particular, preserve the old house hidden bit for the departure inference before overwriting it.
- The branch's `LAST_NEW_EVENT` is currently 2286. The game branch now includes unrelated new events 2287–2288 and these Eusine events at 2289–2291. Audit the release's complete new-event range and update initialization accordingly. Run the Eusine inference **after** any range-clearing loop, so that loop cannot erase inferred milestones.
- Extend [`tests/test_version11.py`](https://github.com/fellowship-of-the-roms/polished-save-patcher/blob/aa527e3005d137f38ff42ec55ca0fe4a58d2fc9a/tests/test_version11.py) and [`docs/v3.3.0-save-audit.md`](https://github.com/fellowship-of-the-roms/polished-save-patcher/blob/aa527e3005d137f38ff42ec55ca0fe4a58d2fc9a/docs/v3.3.0-save-audit.md). Refresh destination provenance and symbol resources for the final release; this change preserves existing SRAM symbols, but saved ROM object/script pointers still require the branch's existing cache cleanup.
- Retain the branch's requirement to save **upstairs in a Pokémon Center near the stairs**, clear saved NPC caches, and exit downstairs after conversion. Continue restores object snapshots instead of invoking the normal OBJECTS callback.
- Retain the current validation policy: both checksums must be valid, and interrupted backup writes are rejected with instructions to re-save in the old ROM. This feature does not require changing that policy to automatic backup recovery.

**Event allocation and saved locations**

The three newly allocated bits were unused tail slots. All existing event numbers, `NUM_EVENTS = $8ff`, the 288-byte event array, and saved block sizes remain unchanged. New Game and New Game+ clear these bits through the existing WRAM initialization.

| Event | Decimal | Hex | Byte offset from `wEventFlags` | Mask |
| --- | --- | --- | --- | --- |
| `EVENT_EUSINE_LEFT_CELADON` | 2289 | `$8f1` | `$11e` | `$02` |
| `EVENT_EUSINE_HO_OH_ENCOUNTER` | 2290 | `$8f2` | `$11e` | `$04` |
| `EVENT_EUSINE_HO_OH_FAREWELL` | 2291 | `$8f3` | `$11e` | `$08` |

For the reviewed layout, the event array begins at flat SRAM offset `$25ea` in primary data and `$17ea` in backup data. These new bits occupy byte **`$2708` primary / `$1908` backup**. Use the patcher's symbol-derived `player("wEventFlags")` address rather than hard-coding these offsets; the offsets are cross-checks.

| Existing evidence/output | Event or field | Meaning |
| --- | --- | --- |
| League complete | event 73 (`$49`) | First Elite Four completion |
| Abra Doll owned | event 589 (`$24d`) | Preserve an already-earned reward |
| Current Ho-Oh fight | event 671 (`$29f`) | Resettable; not a permanent story milestone |
| Suicune tower fight | event 717 (`$2cd`) | Home research stage reached |
| Rainbow Wing received | event 718 (`$2ce`) | Permanent Ho-Oh unlock |
| Native Ho-Oh caught | `wPlayerCaught & $01` | Do not substitute Pokédex ownership or party contents |
| Three native beasts caught | `(wPlayerCaught & $1c) == $1c` | Same semantics as `SpecialBeastsCheck` |
| Tower 1F Eusine hidden | event 2154 (`$86a`) | Set means absent |
| House Eusine hidden | event 2156 (`$86c`) | Set means absent |

**Approved inference policy**

Compute `eligible = receivedWing || (beatLeague && caughtAllThreeBeasts)` from the original save. Apply the first matching row:

| Original evidence | New bits: left / encounter / farewell | House hidden | Tower hidden |
| --- | --- | --- | --- |
| Abra Doll owned | 1 / 1 / 1 | 1 | 1 |
| Native Ho-Oh caught OR current fought-Ho-Oh | 1 / 1 / 0 | 1 | 0 |
| Suicune fought AND old house hidden AND eligible | 1 / 0 / 0 | 1 | 1 |
| Suicune fought | 0 / 0 / 0 | 0 | 1 |
| Otherwise | 0 / 0 / 0 | 1 | 1 |

Always overwrite all three newly allocated bits, even when the old reserved bits happen to be set. Never infer farewell completion from the tower hidden bit. Never clear the doll, native-catch flags, fought flags, Rainbow Wing, League completion, or earlier battle-win flags.

Preserve early Eusine visibility and the patcher's existing early-scene translations. No new repair of events 1854, 2143, or 2146 is required: reachable released saves already hide those appearances by this stage. Do not set `EVENT_BEAT_EUSINE`; it records consumption of the optional Cianwood encounter, including a loss. Valid released saves already have the Suicune and sighting scenes consumed after `EVENT_FOUGHT_SUICUNE`; include those cases in tests so conversion does not revive those scenes.

Suggested code for the existing `patchVersion10to11` function, using its existing `flag`, `player`, and `events` helpers:

```cpp
// Run after clearing newly allocated events, using original evidence.
const auto caught = save10.getByte(player("wPlayerCaught"));
const bool suicune = flag(save10, events, 717);
const bool eligible = flag(save10, events, 718)
    || (flag(save10, events, 73) && (caught & 0x1c) == 0x1c);
const bool farewell = flag(save10, events, 589);
const bool encounter = farewell || (caught & 0x01) || flag(save10, events, 671);
const bool left = encounter || (suicune && flag(save10, events, 2156) && eligible);

flag(save11, events, 2289, left);
flag(save11, events, 2290, encounter);
flag(save11, events, 2291, farewell);
flag(save11, events, 2156, !(suicune && !left));
flag(save11, events, 2154, !(encounter && !farewell));
```

Prefer named constants for these IDs in the final patcher implementation. The source/destination event IDs and field offsets used here are stable across the released v10 layout and this v11 change. The existing final primary-to-backup copy, both checksum rewrites, and version-11 write should remain after this block.

**Legacy limitations and logging**

Old saves never stored farewell completion. A hidden tower Eusine can mean a completed farewell or an exit by whiteout/Fly/Rope without hearing it; a visible one can be an old callback replay. The approved policy preserves unseen dialogue, so a legacy player who already heard the farewell may hear it once more after migration. Afterward the new completion bit prevents further replays. An existing Abra Doll is treated as completion to preserve that reward outcome. The old game could award it before the farewell; its ownership is not proof that the farewell was heard.

A later Hall of Fame visit can erase the fought-Ho-Oh evidence after an unsuccessful encounter. If no native catch/doll evidence remains, that history cannot be reconstructed exactly. Log the inferred state and explain this limitation; do not present a visibility heuristic as certainty. Keep the normal conversion automatic. An explicit user-selected completed-story override could be a separate patcher feature, but is not required here.

Already-version-11 development saves are not released v10 inputs. Since the version is intentionally not bumped again, the regular converter cannot identify or auto-upgrade older v11 development builds safely. The existing v10→v11 step should continue rejecting them. If developer-save repair is later offered, it needs an explicit source-build/repair mode and should not silently run on every valid v11 save.

**Required patcher tests**

- Every row of the inference table, both old tower visibility values, all eight old values of the three reserved bits, and contradictory old house visibility.
- Defensive inference cases: all eight beast-caught masks with League and Wing independently present/absent; native Ho-Oh catch independently of current fought-Ho-Oh. These include impossible fresh-save histories and must not be labeled gameplay routes. A traded-only Ho-Oh must not count as native.
- Doll precedence, including a missing fought-Ho-Oh flag after a later League victory; doll remains owned and is never re-awarded.
- Pending farewell after a legacy whiteout or roof exit, and completed farewell with no doll: document that both may map to pending because old history is ambiguous.
- Ho-Oh failed encounter followed by League reset; verify deterministic fallback and no fabricated native catch.
- Preserve unrelated event bits (especially the other five bits sharing byte `$2708`), all native-catch fields, key items, party/box data, early scene progression, and early Eusine visibility (events 1854, 2143, and 2146).
- Check converted primary and backup equality, both checksums, unchanged lengths and save version 11; retain the existing invalid-checksum/interrupted-write/wrong-location/version rejection tests.
- Load representative converted saves in vibeEmu, exit the Pokémon Center, and visit house/tower in both orders. Pending farewell survives another Hall of Fame respawn; completing it suppresses both NPCs and enables Grandpa's one-time doll.

The game regression driver checks the emitted resolver against every combination of milestone bits and relevant old flags, including invalid combinations. It does not substitute for executing the patcher's conversion tests after this handoff is implemented there.
