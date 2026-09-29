# Illusion ROM regression tests

These tests execute the assembled Game Boy code using PyBoy. Build the ROM and
its matching `.sym` file with RGBDS 1.0.4 before running them.

```sh
python3 -m venv /tmp/polishedcrystal-tests
/tmp/polishedcrystal-tests/bin/pip install -r tests/requirements.txt
make -j4
/tmp/polishedcrystal-tests/bin/python tests/illusion.py polishedcrystal-3.2.3.gbc -v
/tmp/polishedcrystal-tests/bin/python tests/illusion_screenshots.py \
    polishedcrystal-3.2.3.gbc docs/illusion/screenshots --clips docs/illusion/clips
```

`illusion.py` initializes deterministic battle fixtures and invokes routines from
the supplied ROM. Drawing and input waits are replaced with return instructions
in the logic tests; the ability, party-selection, damage, item-healing and
Transform routines execute normally. Failed Transform is intercepted at the
failure-message boundary. The checks include 728 combinations of living,
fainted and Egg party members across both sides, actual Revive healing,
Substitute breaking before a later hit, and Neutralizing Gas entering before
lethal Spikes damage.

`illusion_screenshots.py` runs both complete send-outs, picture loading,
HUDs, move text, Transform failure/success, attack damage and a Gas switch-in
with the renderer enabled. It uses real button input to advance text and does
not stub game routines. It asserts the rendered nickname tiles, active ability
state and battle identity, then saves native 160×144 screenshots. The fixture
uses link-style trainer naming for send-out text; it does not establish or test
a two-emulator link connection.

The optional `--clips` argument requires `ffmpeg` on PATH. It records five
silent H.264 MP4 clips from every rendered emulator frame at 60 fps, scaled to
640×576 with nearest-neighbor scaling. Each clip includes a two-second final
hold. These are controlled routine-level scenarios, with fixed damage and move
choices, rather than a recording of a full battle played through the menus.

The tests can assign Illusion to Ditto (and Neutralizing Gas to Koffing) in the
emulator's private ROM image. They never edit the supplied ROM, save files or
production species data. Tests use the normal and shiny Alolan Raichu data to
check that form/personality palette selection stays independent of battle stats.

Pass another build's ROM path to test faithful, debug, monochrome or VC builds.
Run `make tidy` before switching build modifiers: the repository Makefile reuses
object filenames across these configurations.
