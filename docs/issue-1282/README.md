Eusine event-order fix: review materials
======================================

This branch contains the investigation, test harness, and evidence for [Rangi42/polishedcrystal#1282](https://github.com/Rangi42/polishedcrystal/issues/1282). The game changes are published separately on [`fix/1282-eusine-event-order`](https://github.com/vulcandth/polishedcrystal/tree/fix/1282-eusine-event-order), for a draft pull request against upstream `master`.

- [Reproduction, approved plan, and scenario analysis](PLAN.md)
- Flowcharts: [before](before.svg) and [after](after.svg)
- [Implementation validation and test limitations](VALIDATION.md)
- [Required v3.3.0 save-patcher changes](SAVE_PATCHER.md)
- Evidence: [broken baseline](evidence/) and [fixed variants](verification/)

The source base is `0e73a0d5f13b4cc97d924c17ee2e239f20318aef`. This documentation branch intentionally does not contain the game fix. Build the ROM on the code branch and pass its ROM and symbol paths to `verify.py` here; `reproduce.py` instead expects the original baseline ROM. Both drivers use the sibling `../vibeEmu` source and an existing local save, as described in the reports. ROMs, cartridge saves, and emulator snapshots are not published.

Implemented and documented with assistance from **ChatGPT Astra** (`Codex:gpt-6-astra`), using vibeEmu for testing.
