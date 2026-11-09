// Reproduction and regression driver using ../vibeEmu's core.
// The seed save is read into memory; this program never writes cartridge RAM to disk.
use std::{
    collections::HashMap,
    env, fs,
    io::{self, BufRead, Write},
};
use vibe_emu_core::{cartridge::Cartridge, gameboy::GameBoy, hardware::Model};

fn call(gb: &mut GameBoy, syms: &HashMap<String, (u16, u16)>, name: &str) -> (u8, u8) {
    // Execute the ROM routine on the real emulated CPU. Preserve the caller's
    // CPU context, but keep the routine's memory changes and elapsed time.
    let cpu = serde_json::to_vec(&gb.cpu).unwrap();
    let old_bank = gb.mmu.cart.as_ref().unwrap().current_rom_bank();
    let bank_addr = syms["hROMBank"].1;
    let old_hram_bank = gb.mmu.read_byte(bank_addr);
    let (bank, pc) = syms[name];
    gb.mmu.write_byte(0x2000, bank as u8);
    gb.mmu.write_byte(bank_addr, bank as u8);
    gb.cpu.pc = pc;
    gb.cpu.ime = false;
    gb.cpu.halted = false;
    gb.cpu.sp -= 2;
    gb.mmu.write_byte(gb.cpu.sp, 0);
    gb.mmu.write_byte(gb.cpu.sp + 1, 0);
    let deadline = gb.cpu.cycles + 600 * 70224;
    while gb.cpu.pc != 0 {
        gb.cpu.step(&mut gb.mmu);
        assert!(gb.cpu.cycles < deadline, "routine timeout {name}");
    }
    let result = (gb.cpu.a, gb.cpu.f);
    let cycles = gb.cpu.cycles;
    gb.cpu = serde_json::from_slice(&cpu).unwrap();
    gb.cpu.cycles = cycles;
    gb.mmu.write_byte(0x2000, old_bank as u8);
    gb.mmu.write_byte(bank_addr, old_hram_bank);
    result
}

fn event(gb: &mut GameBoy, base: u16, bit: u16, value: bool) {
    let address = base + bit / 8;
    let mask = 1 << (bit % 8);
    let old = gb.mmu.read_byte(address);
    gb.mmu
        .write_byte(address, (old & !mask) | if value { mask } else { 0 });
}

fn get_event(gb: &mut GameBoy, base: u16, bit: u16) -> bool {
    gb.mmu.read_byte(base + bit / 8) & (1 << (bit % 8)) != 0
}

fn main() {
    let args: Vec<_> = env::args().collect();
    let syms: HashMap<String, (u16, u16)> = fs::read_to_string(&args[2])
        .unwrap()
        .lines()
        .filter_map(|l| {
            let mut p = l.split_whitespace();
            let loc = p.next()?;
            let name = p.next()?;
            let (bank, addr) = loc.split_once(':')?;
            Some((
                name.to_string(),
                (
                    u16::from_str_radix(bank, 16).ok()?,
                    u16::from_str_radix(addr, 16).ok()?,
                ),
            ))
        })
        .collect();
    let mut gb = GameBoy::new(Model::Cgb(Default::default()));
    let mut cart = Cartridge::from_bytes(fs::read(&args[1]).unwrap());
    let save = fs::read(&args[3]).unwrap();
    let n = cart.ram.len();
    cart.ram.copy_from_slice(&save[..n]);
    gb.mmu.load_cart(cart);
    let addr = |s: &str| {
        syms.get(s)
            .map(|x| x.1)
            .unwrap_or_else(|| u16::from_str_radix(s, 16).unwrap())
    };
    for line in io::stdin().lock().lines() {
        let line = line.unwrap();
        let p: Vec<_> = line.split_whitespace().collect();
        if p.is_empty() || p[0].starts_with('#') {
            continue;
        }
        match p[0] {
            "checksave" => {
                let ram = &gb.mmu.cart.as_ref().unwrap().ram;
                let offset = |name: &str| {
                    let (bank, address) = syms[name];
                    bank as usize * 0x2000 + (address - 0xa000) as usize
                };
                let primary = &ram[offset("sGameData")..offset("sGameDataEnd")];
                let backup = &ram[offset("sBackupGameData")..offset("sBackupGameDataEnd")];
                assert_eq!(primary, backup);
                for (data, checksum) in [(primary, "sChecksum"), (backup, "sBackupChecksum")] {
                    let sum = data.iter().fold(0u16, |s, &v| s.wrapping_add(v as u16));
                    let pos = offset(checksum);
                    assert_eq!(sum, u16::from_le_bytes([ram[pos], ram[pos + 1]]));
                }
                let pos = offset("sSaveVersion");
                assert_eq!(&ram[pos..pos + 2], &[0, 11]);
                assert_eq!(ram[offset("sWritingBackup")], 0);
                println!("PASS coherent primary/backup, both checksums, save version 11");
            }
            "battle_result" => {
                // Replace only the battle engine's return at its entry point;
                // surrounding encounter scripts and loss handling run normally.
                let (bank, pc) = syms["StartBattle"];
                assert_eq!(gb.cpu.pc, pc);
                assert_eq!(gb.mmu.cart.as_ref().unwrap().current_rom_bank(), bank);
                let result = u8::from_str_radix(p[1], 16).unwrap();
                gb.mmu.write_byte(addr("wBattleResult"), result);
                let lo = gb.mmu.read_byte(gb.cpu.sp) as u16;
                let hi = gb.mmu.read_byte(gb.cpu.sp + 1) as u16;
                gb.cpu.sp += 2;
                gb.cpu.pc = lo | (hi << 8);
                println!("Injected battle engine result {result:02x}");
            }
            "finish" => {
                let mut frames = 0;
                while gb.mmu.wram[1][(addr("wScriptRunning") - 0xd000) as usize] != 0 {
                    gb.mmu
                        .input
                        .set_state(if frames % 30 < 3 { 0xef } else { 0xff });
                    let target = gb.cpu.cycles + 70224;
                    while gb.cpu.cycles < target {
                        gb.cpu
                            .run_for_dots(&mut gb.mmu, (target - gb.cpu.cycles).min(4096) as u16);
                    }
                    frames += 1;
                    assert!(frames < 12000, "script did not finish");
                }
                gb.mmu.input.set_state(255);
                println!("PASS script returned to idle after {frames} frames");
            }
            "call" => {
                let (a, f) = call(&mut gb, &syms, p[1]);
                if p.len() > 2 {
                    assert_eq!(a, u8::from_str_radix(p[2], 16).unwrap(), "{} A", p[1]);
                }
                if p.len() > 3 {
                    assert_eq!(
                        f & 0x80,
                        u8::from_str_radix(p[3], 16).unwrap(),
                        "{} Z",
                        p[1]
                    );
                }
                println!("PASS call {} A={a:02x} F={f:02x}", p[1]);
            }
            "script" => {
                let (bank, pc) = syms[p[1]];
                gb.mmu.write_byte(addr("hScriptBank"), bank as u8);
                gb.mmu.write_byte(addr("hScriptPos"), pc as u8);
                gb.mmu.write_byte(addr("hScriptPos") + 1, (pc >> 8) as u8);
                gb.mmu.write_byte(addr("wScriptRunning"), 255);
                gb.mmu.write_byte(addr("wScriptMode"), 1);
                gb.mmu.write_byte(addr("wScriptStackSize"), 0);
            }
            "snapshot" => {
                fs::write(p[1], gb.save_state().unwrap()).unwrap();
            }
            "restore" => {
                gb.load_state(&fs::read(p[1]).unwrap()).unwrap();
            }
            "reset" => {
                let ram = gb.mmu.cart.as_ref().unwrap().ram.clone();
                gb = GameBoy::new(Model::Cgb(Default::default()));
                let mut cart = Cartridge::from_bytes(fs::read(&args[1]).unwrap());
                cart.ram = ram;
                gb.mmu.load_cart(cart);
            }
            "matrix" => {
                let snapshot = gb.save_state().unwrap();
                let base = addr("wEventFlags");
                // Eight new-bit combinations, Suicune, old Ho-Oh fight/catch,
                // eight beast masks, Wing, League, doll, both visibility bits.
                for case in 0u32..32768 {
                    let progress = case & 7;
                    let suicune = case & 8 != 0;
                    for (shift, bit) in [
                        (0, 2289),
                        (1, 2290),
                        (2, 2291),
                        (3, 717),
                        (4, 671),
                        (9, 718),
                        (10, 73),
                        (11, 589),
                        (12, 2154),
                        (13, 2156),
                    ] {
                        event(&mut gb, base, bit, case & (1 << shift) != 0);
                    }
                    // Include unrelated caught bits as well as the native masks.
                    gb.mmu.write_byte(
                        addr("wPlayerCaught"),
                        (((case >> 6) as u8 & 7) << 2)
                            | ((case >> 5) as u8 & 1)
                            | if case & 16384 != 0 { 0xe2 } else { 0 },
                    );
                    let expected = if progress & 4 != 0 {
                        4
                    } else if progress & 2 != 0 {
                        3
                    } else if progress & 1 != 0 {
                        2
                    } else if suicune {
                        1
                    } else {
                        0
                    };
                    let flags_before: Vec<_> =
                        (0..288).map(|i| gb.mmu.read_byte(base + i)).collect();
                    for _ in 0..2 {
                        let (a, _) = call(&mut gb, &syms, "UpdateEusineVisibility");
                        assert_eq!(a, expected, "case {case}");
                        assert_eq!(
                            gb.mmu.read_byte(addr("hScriptVar")),
                            expected,
                            "case {case}"
                        );
                        assert_eq!(
                            get_event(&mut gb, base, 2154),
                            expected != 3,
                            "tower case {case}"
                        );
                        assert_eq!(
                            get_event(&mut gb, base, 2156),
                            expected != 1,
                            "house case {case}"
                        );
                    }
                    for bit in 0..2303 {
                        let allowed = bit == 2154
                            || bit == 2156
                            || (expected != 0 && [1854, 2143, 2146].contains(&bit));
                        if !allowed {
                            assert_eq!(
                                get_event(&mut gb, base, bit),
                                flags_before[(bit / 8) as usize] & (1 << (bit % 8)) != 0,
                                "unrelated event {bit}, case {case}"
                            );
                        }
                    }
                }
                gb.load_state(&snapshot).unwrap();
                println!(
                    "PASS 32768 state combinations, idempotence, and unrelated event preservation"
                );
            }
            "run" | "press" => {
                let frames: u64 = p[1].parse().unwrap();
                let state = if p[0] == "press" {
                    u8::from_str_radix(p[2], 16).unwrap()
                } else {
                    255
                };
                gb.mmu.input.set_state(state);
                let target = gb.cpu.cycles + frames * 70224;
                while gb.cpu.cycles < target {
                    gb.cpu
                        .run_for_dots(&mut gb.mmu, (target - gb.cpu.cycles).min(4096) as u16);
                }
                gb.mmu.input.set_state(255);
            }
            "read" => {
                let a = addr(p[1]);
                let n: u16 = p.get(2).unwrap_or(&"1").parse().unwrap();
                let old = gb.mmu.wram_bank;
                gb.mmu.wram_bank = 1;
                print!("{}={:04x}:", p[1], a);
                for i in 0..n {
                    print!(" {:02x}", gb.mmu.read_byte(a + i));
                }
                println!();
                gb.mmu.wram_bank = old;
            }
            "write" => {
                let a = addr(p[1]);
                let old = gb.mmu.wram_bank;
                gb.mmu.wram_bank = 1;
                for (i, v) in p[2..].iter().enumerate() {
                    gb.mmu
                        .write_byte(a + i as u16, u8::from_str_radix(v, 16).unwrap());
                }
                gb.mmu.wram_bank = old;
            }
            "event" => {
                let bit: u16 = p[1].parse().unwrap();
                let a = addr("wEventFlags") + bit / 8;
                let old = gb.mmu.wram_bank;
                gb.mmu.wram_bank = 1;
                let mut v = gb.mmu.read_byte(a);
                if p[2] == "1" {
                    v |= 1 << (bit % 8);
                } else {
                    v &= !(1 << (bit % 8));
                }
                gb.mmu.write_byte(a, v);
                gb.mmu.wram_bank = old;
            }
            "expect_event" => {
                let bit: u16 = p[1].parse().unwrap();
                let a = addr("wEventFlags") + bit / 8;
                let old = gb.mmu.wram_bank;
                gb.mmu.wram_bank = 1;
                let actual = (gb.mmu.read_byte(a) >> (bit % 8)) & 1;
                assert_eq!(actual, p[2].parse::<u8>().unwrap(), "event {}", bit);
                gb.mmu.wram_bank = old;
                println!("PASS event {} = {}", bit, actual);
            }
            "expect" => {
                let a = addr(p[1]);
                let old = gb.mmu.wram_bank;
                gb.mmu.wram_bank = 1;
                for (i, v) in p[2..].iter().enumerate() {
                    assert_eq!(
                        gb.mmu.read_byte(a + i as u16),
                        u8::from_str_radix(v, 16).unwrap(),
                        "{} byte {}",
                        p[1],
                        i
                    );
                }
                gb.mmu.wram_bank = old;
                println!("PASS {}", line);
            }
            "until" => {
                let (bank, a) = syms[p[1]];
                let frames = p.get(2).map_or(600, |v| v.parse::<u64>().unwrap());
                let target = gb.cpu.cycles + frames * 70224;
                while gb.cpu.pc != a
                    || (a >= 0x4000 && gb.mmu.cart.as_ref().unwrap().current_rom_bank() != bank)
                {
                    gb.cpu.step(&mut gb.mmu);
                    assert!(gb.cpu.cycles < target, "breakpoint timeout {}", p[1]);
                }
                println!("break {} pc={:04x}", p[1], gb.cpu.pc);
            }
            "warp" => {
                let old = gb.mmu.wram_bank;
                gb.mmu.wram_bank = 1;
                for (name, v) in [
                    ("wMapGroup", p[1]),
                    ("wMapNumber", p[2]),
                    ("wXCoord", p[3]),
                    ("wYCoord", p[4]),
                ] {
                    gb.mmu.write_byte(addr(name), v.parse::<u8>().unwrap());
                }
                gb.mmu.write_byte(addr("wDefaultSpawnpoint"), 255);
                gb.mmu.write_byte(addr("hMapEntryMethod"), 0xf1);
                gb.mmu.write_byte(addr("wMapStatus"), 1);
                gb.mmu.wram_bank = old;
            }
            "shot" => {
                let mut data = b"P6\n160 144\n255\n".to_vec();
                for &px in gb.mmu.ppu.framebuffer() {
                    data.extend_from_slice(&[(px >> 16) as u8, (px >> 8) as u8, px as u8]);
                }
                fs::write(p[1], data).unwrap();
            }
            "quit" => break,
            _ => panic!("unknown command {}", p[0]),
        }
        println!("ok {} pc={:04x} dots={}", line, gb.cpu.pc, gb.cpu.cycles);
        io::stdout().flush().unwrap();
    }
}
