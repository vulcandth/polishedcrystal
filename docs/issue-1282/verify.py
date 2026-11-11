#!/usr/bin/env python3
"""Execute issue 1282 regressions in the sibling vibeEmu core.

The isolated driver runs the built ROM's real CPU routines, map callbacks,
dialogue and exit scripts. Fixtures and battle-result injection are explicit.
No source ROM or save is modified. See VALIDATION.md for scope and results.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--rom", type=Path, default=ROOT / "polishedcrystal-3.2.3.gbc")
parser.add_argument("--sym", type=Path, default=ROOT / "polishedcrystal-3.2.3.sym")
parser.add_argument("--save", type=Path, default=ROOT / "polishedcrystal-debug-3.2.3.sav")
parser.add_argument("--output", type=Path, default=Path("/tmp/issue1282-verify"))
parser.add_argument("--build", type=Path, default=Path("/tmp/issue1282-driver"))
parser.add_argument("--vibe-emu", type=Path, default=ROOT.parent / "vibeEmu")
args = parser.parse_args()
out, build = args.output.resolve(), args.build.resolve()
out.mkdir(parents=True, exist_ok=True)
commands = []


def add(lines):
    commands.extend(lines.strip().splitlines())


def advance():
    add("finish\nrun 180")


def boot():
    add("run 500\npress 8 7f\nrun 90\npress 10 7f\nrun 100")
    add("press 8 ef\nrun 100\npress 8 ef\nrun 180\nuntil OverworldLoop.loop")


def fixture(progress=0, caught=0x1c, fought=0, suicune=1, league=1, wing=1):
    # Necessary fresh-save history invariants, not a claim that the debug seed
    # is a complete organically played save. The matrix separately tests invalid inputs.
    assert progress in (0, 1, 3, 7)
    assert not (caught & 0x10) or suicune
    assert not wing or (league and caught & 0x1c == 0x1c)
    assert not progress or (suicune and league and caught & 0x1c == 0x1c)
    assert progress < 3 or wing
    assert not fought or progress >= 3
    assert not (caught & 1) or (progress >= 3 and fought)
    global fixture_league, fixture_wing
    fixture_league, fixture_wing = league, wing
    add("restore neutral.state")
    for bit, value in [(73, league), (671, fought), (717, suicune), (718, wing),
                       (589, 0), (2154, 1), (2156, 0),
                       (1854, 1), (2143, 1), (2146, 1),
                       (2289, progress & 1), (2290, progress & 2), (2291, progress & 4)]:
        add(f"event {bit} {int(bool(value))}")
    add(f"write wPlayerCaught {caught:02x}\nwrite wTinTower1FSceneID 01")
    add("call UpdateEusineVisibility")


def warp(group, number, x, y):
    assert (group, number) != (21, 32) or fixture_league, "Celadon requires League"
    assert not (group == 3 and 5 <= number <= 13 or (group, number) == (15, 10)) or fixture_wing
    add(f"until OverworldLoop.loop\nwarp {group} {number} {x} {y}\nrun 150")
    add(f"expect wMapGroup {group:02x} {number:02x} {y:02x} {x:02x}")


def script(name):
    add(f"until OverworldLoop.loop\nscript {name}")


def talk_up():
    add("press 8 fb\nrun 8\npress 8 ef\nrun 60")


def state(left, encounter, farewell, tower, house):
    for bit, value in [(2289, left), (2290, encounter), (2291, farewell), (2154, tower), (2156, house)]:
        add(f"expect_event {bit} {value}")


boot()
add("snapshot neutral.state\nmatrix")

# Main issue order: skip the house, encounter Ho-Oh, farewell, visit home.
fixture(progress=3, caught=0x1d, fought=1)
warp(3, 4, 6, 4)
state(1, 1, 0, 0, 1)
talk_up()
add("shot first-farewell.ppm")
advance()
add("expect wScriptRunning 00")
state(1, 1, 1, 1, 1)
warp(21, 32, 2, 4)
state(1, 1, 1, 1, 1)
add("shot house-after-farewell.ppm")
warp(3, 4, 6, 4)
state(1, 1, 1, 1, 1)
add("shot tower-after-farewell.ppm")
warp(3, 5, 8, 3)
warp(3, 4, 6, 4)
state(1, 1, 1, 1, 1)

# Real save routine, cold boot and Continue; object callbacks are skipped.
for name, group, number, x, y, progress in [
    ("pending-tower", 3, 4, 6, 4, 3), ("complete-tower", 3, 4, 6, 4, 7),
    ("home", 21, 32, 2, 4, 0), ("complete-house", 21, 32, 2, 4, 7),
    ("roof", 15, 10, 6, 4, 3),
]:
    fixture(progress=progress, fought=int(progress >= 3))
    warp(group, number, x, y)
    add("until OverworldLoop.loop\ncall SaveGameData\ncall SaveCurrentVersion\nchecksave\nreset")
    boot()
    add(f"expect wMapGroup {group:02x} {number:02x} {y:02x} {x:02x}")
    state(int(progress > 0), int(progress >= 3), int(progress == 7), int(progress != 3), int(progress != 0))
    add(f"shot continue-{name}.ppm")

# Celadon requires League. All native catch masks are reachable there;
# Wing requires League plus all native beasts, and does not bypass that history.
for caught_mask in range(8):
    fixture(caught=caught_mask << 2, wing=0)
    warp(21, 32, 2, 4)
    talk_up()
    advance()
    eligible = caught_mask == 7
    state(int(eligible), 0, 0, 1, int(eligible))
    add("expect wScriptRunning 00")

fixture()
warp(21, 32, 2, 4)
talk_up()
advance()
state(1, 0, 0, 1, 1)

# Unlike Celadon, 1F is reachable before League; retain its eligibility gate.
for league in (0, 1):
    fixture(league=league, wing=0)
    warp(3, 4, 6, 4)
    add(f"expect_event 2155 {league}\nexpect_event 2170 {1 - league}")
    add("expect_event 718 0")
    state(0, 0, 0, 1, 0)

# Early quest is not advanced by the first League completion.
fixture(suicune=0, caught=0, wing=0)
add("call RespawnOneOffs")
warp(21, 32, 2, 4)
state(0, 0, 0, 1, 1)
warp(21, 32, 5, 4)
talk_up()
advance()
add("expect_event 589 0\nexpect wScriptRunning 00")

# Each reachable side of Eusine's departure paths, including player blocking.
for group, number, x, y, facing, progress in [
    (21, 32, 1, 3, "fe", 0), (21, 32, 2, 2, "f7", 0),
    (3, 4, 5, 3, "fe", 3), (3, 4, 7, 3, "fd", 3), (3, 4, 6, 2, "f7", 3),
]:
    fixture(progress=progress)
    warp(group, number, x, y)
    add(f"press 8 {facing}\nrun 8\npress 8 ef\nrun 60")
    advance()
    add("expect wScriptRunning 00")
    state(1, int(progress != 0), int(progress != 0), 1, 1)

# Grandpa's gift is gated by farewell and remains one-time.
for progress in (0, 1, 3, 7):
    fixture(progress=progress, fought=int(progress >= 3))
    warp(21, 32, 5, 4)
    talk_up()
    advance()
    add(f"expect_event 589 {int(progress==7)}\nexpect wScriptRunning 00")
    if progress == 7:
        talk_up()
        advance()
        add("expect_event 589 1\nexpect wScriptRunning 00")

# Respawns preserve every stage; native Ho-Oh catch requires a prior encounter.
for progress in (0, 1, 3, 7):
    for caught in ((0x1c, 0x1d) if progress >= 3 else (0x1c,)):
        fixture(progress=progress, caught=caught, fought=int(progress >= 3))
        add("call RespawnOneOffs")
        state(int(progress>0), int(progress>=3), int(progress==7), int(progress!=3), int(progress!=0))
        add(f"expect_event 671 {caught & 1}")
        warp(3, 4, 6, 4)
        state(int(progress>0), int(progress>=3), int(progress==7), int(progress!=3), int(progress!=0))

# Run the Ho-Oh script up to real battle entry. No milestone is injected here.
for progress in (0, 1, 7):
    fixture(progress=progress)
    warp(15, 10, 6, 4)
    script("TinTowerHoOh")
    add("until Script_startbattle")
    state(1, 1, int(progress==7), int(progress==7), 1)
    add("expect_event 671 1")

# The loss handler executes a real whiteout warp after a controlled battle result.
fixture(progress=3, fought=1)
warp(15, 10, 6, 4)
add("write wLastSpawnMapGroup 04 02\nwrite wBattleResult 01")
script("TinTowerHoOh.nocatch")
add("call Script_reloadmapafterbattle\nrun 90")
advance()
add("expect wMapGroup 04 02\nexpect wScriptRunning 00")
state(1, 1, 0, 0, 1)
warp(21, 32, 2, 4)
state(1, 1, 0, 0, 1)

# Actual battle menus: ordinary Run is rejected; a Poke Doll permits escape.
fixture()
warp(15, 10, 6, 4)
add("write wNumItems 01 61 01 ff")
script("TinTowerHoOh")
add("until StartBattle\nrun 500\npress 8 ef\nrun 180\npress 8 ef\nrun 120")
add("press 8 ef\nrun 180\npress 8 ef\nrun 180\nsnapshot battle-menu.state")
add("press 8 f7\nrun 8\npress 8 fe\nrun 8\npress 8 ef\nrun 40")
add("shot run-rejected.ppm\nexpect wBattleEnded 00\nexpect wBattleResult 00")
state(1, 1, 0, 0, 1)
add("restore battle-menu.state\npress 8 f7\nrun 8\npress 8 ef\nrun 100")
add("press 8 ef\nrun 30\npress 8 ef\nrun 60\nshot doll-escape.ppm")
advance()
add("expect wBattleMode 00\nexpect wBattleResult 02\nexpect wNumItems 00 ff")
add("expect wPlayerCaught 1c")
state(1, 1, 0, 0, 1)
add("shot doll-finished.ppm")

# Exercise complete encounter scripts with controlled battle-engine returns.
# Actual combat/catching is outside this fixture: only its result is supplied.
for result in (0x00, 0x02, 0x40, 0x01):  # KO, Poke Doll escape, catch, loss
    fixture(progress=0, caught=0x1c)
    warp(15, 10, 6, 4)
    add("write wLastSpawnMapGroup 04 02")
    script("TinTowerHoOh")
    add(f"until StartBattle\nbattle_result {result:02x}\nrun 90")
    advance()
    add(f"expect wPlayerCaught {0x1c | int(result == 0x40):02x}")
    add("expect wScriptRunning 00")
    state(1, 1, 0, 0, 1)
    if result == 1:
        add("expect wMapGroup 04 02")

for result in (0x00, 0x02, 0x40, 0x01):
    fixture(progress=0, caught=0, suicune=0, league=0, wing=0)
    # Cianwood's optional battle may have been skipped or consumed (win/loss).
    add(f"event 1457 {int(result in (0x40, 0x01))}")
    add("write wLastSpawnMapGroup 04 02\nwrite wTinTower1FSceneID 00")
    add("until OverworldLoop.loop\nwarp 3 4 7 15\nuntil StartBattle 1800")
    add(f"battle_result {result:02x}\nrun 90")
    advance()
    add("expect_event 717 1\nexpect wTinTower1FSceneID 01\nexpect wScriptRunning 00")
    add(f"expect wPlayerCaught {0x10 if result == 0x40 else 0:02x}")
    for bit in (1854, 2143, 2146):
        add(f"expect_event {bit} 1")
    add(f"expect_event 1457 {int(result in (0x40, 0x01))}")
    state(0, 0, 0, 1, 0)
    if result == 1:
        add("expect wMapGroup 04 02")

# Field move eligibility at every floor and roof, using actual ROM routines.
for floor in range(1, 11):
    fixture(progress=3)
    warp(3, floor + 3, 6, 4)
    add("until OverworldLoop.loop\nwrite wDigWarpNumber 03 10 0f\ncall EscapeRopeOrDig.CheckCanDig 01")
    add("call CheckFlyAllowedOnMap 01 00")
fixture(progress=3)
warp(15, 10, 6, 4)
add("until OverworldLoop.loop\nwrite wDigWarpNumber 03 10 0f\ncall EscapeRopeOrDig.CheckCanDig 02")
add("call CheckFlyAllowedOnMap 00 80")

# Real queued escape and Teleport scripts, with normal animation/map setup.
for exit_script, roof in [("EscapeRopeOrDig.UsedEscapeRopeScript", False),
                          ("EscapeRopeOrDig.UsedDigScript", False),
                          ("TeleportFunction.TeleportScript", True),
                          ("FlyFunction.FlyScript", True)]:
    for progress in (0, 3, 7):
        fixture(progress=progress)
        warp(15 if roof else 3, 10 if roof else 13, 6, 4)
        # Rope/Dig: the recorded Bellchime Trail entrance. Fly/Teleport: Celadon.
        add("write wDigWarpNumber 03 10 0f\nwrite wNextWarp 03 10 0f")
        add("write wDefaultSpawnpoint 0b" if roof else "write wDefaultSpawnpoint ff")
        add("write wCurPartyMon 00")
        script(exit_script)
        add("run 90")
        advance()
        add("expect wScriptRunning 00")
        add("expect wMapGroup 15 07" if roof else "expect wMapGroup 10 0f")
        state(int(progress>0), int(progress>=3), int(progress==7), int(progress!=3), int(progress!=0))

add("quit")
text = "\n".join(commands) + "\n"
(out / "commands.txt").write_text(text)
before = {str(p.resolve()): hashlib.sha256(p.read_bytes()).hexdigest() for p in (args.rom, args.sym, args.save)}
(build / "src").mkdir(parents=True, exist_ok=True)
shutil.copyfile(Path(__file__).with_name("probe.rs"), build / "src/main.rs")
(build / "Cargo.toml").write_text(
    '[package]\nname="eusine-probe"\nversion="0.1.0"\nedition="2024"\n'
    '[dependencies]\nserde_json="1"\nvibe-emu-core={path='
    + json.dumps(str(args.vibe_emu.resolve() / "crates/vibe-emu-core")) + '}\n'
)
subprocess.run(["cargo", "build", "--release", "--offline", "--manifest-path", str(build / "Cargo.toml")], check=True)
with (out / "trace.txt").open("w") as log:
    result = subprocess.run([str(build / "target/release/eusine-probe"), str(args.rom.resolve()),
                             str(args.sym.resolve()), str(args.save.resolve())],
                            input=text, text=True, stdout=log, stderr=subprocess.STDOUT, cwd=out)
after = {str(p.resolve()): hashlib.sha256(p.read_bytes()).hexdigest() for p in (args.rom, args.sym, args.save)}
assert before == after, "Input files changed"
(out / "inputs.json").write_text(json.dumps(before, indent=2) + "\n")
for path in out.glob("*.ppm"):
    with Image.open(path) as picture:
        picture.save(path.with_suffix(".png"))
result.check_returncode()
print(f"All vibeEmu regressions passed. Evidence: {out}")
