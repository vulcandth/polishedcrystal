#!/usr/bin/env python3
"""Replay issue 1282 in the sibling vibeEmu core without modifying ROM/save files.

Run from any directory. Outputs go to --output (default /tmp/issue1282-replay).
The default seed is the existing local version-11 debug save; see PLAN.md for its
hash and the controlled state setup. Requires Rust, cached Cargo dependencies,
and Pillow for lossless PPM-to-PNG conversion.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--rom", type=Path, default=ROOT / "polishedcrystal-3.2.3.gbc")
parser.add_argument("--sym", type=Path, default=ROOT / "polishedcrystal-3.2.3.sym")
parser.add_argument("--save", type=Path, default=ROOT / "polishedcrystal-debug-3.2.3.sav")
parser.add_argument("--output", type=Path, default=Path("/tmp/issue1282-replay"))
parser.add_argument("--vibe-emu", type=Path, default=ROOT.parent / "vibeEmu")
args = parser.parse_args()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)
commands = []


def add(lines):
    commands.extend(lines.strip().splitlines())


def shot(name):
    # Run with the output directory as cwd, avoiding whitespace in command paths.
    commands.append(f"shot {name}.ppm")


def advance(count, delay=45):
    for _ in range(count):
        add(f"press 8 ef\nrun {delay}")


add("""
# Boot and Continue the local seed save.
run 500
press 8 7f
run 90
press 10 7f
run 100
press 8 ef
run 100
press 8 ef
run 180
until OverworldLoop.loop
# Controlled prerequisite state, set once before any observed dialogue.
# Elite Four, fought Ho-Oh, fought Suicune, received Rainbow Wing.
event 73 1
event 671 1
event 717 1
event 718 1
# Tower Eusine hidden; house Eusine visible (0 means visible).
event 2154 1
event 2156 0
# Native catches of all three beasts and Ho-Oh; no Suicune arrival scene.
write wPlayerCaught 1d
write wTinTower1FSceneID 01
# Enter tower at (6,4), below Eusine. Normal map setup/callbacks execute.
warp 3 4 6 4
run 150
expect wMapGroup 03 04 04 06
expect_event 2154 0
press 8 fb
run 8
press 8 ef
run 60
""")
shot("01-first-farewell")
advance(16)
add("run 180\nexpect_event 2154 1\nexpect_event 2156 0\nexpect wScriptRunning 00")
shot("02-farewell-complete")
add("until OverworldLoop.loop\nwarp 21 32 2 4\nrun 150\nexpect wMapGroup 15 20 04 02")
shot("03-house-after-farewell")
add("press 8 fb\nrun 8\npress 8 ef\nrun 60")
advance(4, 60)
shot("04-stale-rumor")
advance(1, 60)
shot("05-stale-rumor-tower")
advance(12)
add("run 180\nexpect_event 2154 1\nexpect_event 2156 1\nexpect wScriptRunning 00")
add("until OverworldLoop.loop\nwarp 3 4 6 4\nrun 150\nexpect_event 2154 0")
add("press 8 fb\nrun 8\npress 8 ef\nrun 60")
shot("06-repeated-farewell")
advance(16)
add("run 180\nexpect_event 2154 1\nexpect wScriptRunning 00")
# A second return without any intervening house visit also restores Eusine.
add("until OverworldLoop.loop\nwarp 3 5 8 3\nrun 100")
add("until OverworldLoop.loop\nwarp 3 4 6 4\nrun 150\nexpect_event 2154 0")
shot("07-repeat-without-house")
add("expect_event 671 1\nexpect wPlayerCaught 1d\nquit")
command_text = "\n".join(commands) + "\n"
(out / "commands.txt").write_text(command_text)

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


before = {str(p.resolve()): digest(p) for p in (args.rom, args.sym, args.save)}
with tempfile.TemporaryDirectory(prefix="eusine-vibeemu-") as tmp:
    build = Path(tmp)
    (build / "src").mkdir()
    shutil.copyfile(Path(__file__).with_name("probe.rs"), build / "src/main.rs")
    core = args.vibe_emu.resolve() / "crates/vibe-emu-core"
    (build / "Cargo.toml").write_text(
        '[package]\nname = "eusine-probe"\nversion = "0.1.0"\nedition = "2024"\n'
        '[dependencies]\nserde_json = "1"\nvibe-emu-core = { path = ' + json.dumps(str(core)) + ' }\n'
    )
    subprocess.run(["cargo", "build", "--release", "--offline", "--manifest-path", str(build / "Cargo.toml")], check=True)
    run = subprocess.run(
        [str(build / "target/release/eusine-probe"), str(args.rom.resolve()), str(args.sym.resolve()), str(args.save.resolve())],
        input=command_text, text=True, capture_output=True, cwd=out,
    )
    (out / "trace.txt").write_text(run.stdout + run.stderr)
    run.check_returncode()
for path in out.glob("*.ppm"):
    with Image.open(path) as picture:
        picture.save(path.with_suffix(".png"))
after = {str(p.resolve()): digest(p) for p in (args.rom, args.sym, args.save)}
assert before == after, "ROM, symbols, or source save changed"
(out / "inputs.json").write_text(json.dumps(before, indent=2) + "\n")
print(f"Reproduced both replay paths; all assertions passed. Evidence: {out}")
