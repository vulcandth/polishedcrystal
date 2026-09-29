#!/usr/bin/env python3
"""Execute Illusion regression tests against a built ROM, using PyBoy 2.7+.

Usage: python3 tests/illusion.py polishedcrystal-3.2.3.gbc
Install test dependencies with: pip install pyboy pillow
The ROM and its matching .sym file must be built from the same source.
Only presentation/wait routines are stubbed in the logic tests; selection,
abilities, HP damage, party state, and Transform execute the assembled code.
"""
import argparse
import itertools
from pathlib import Path
import re
import unittest

from pyboy import PyBoy

ROOT = Path(__file__).resolve().parents[1]


def constants(filename, initial=0):
    # The first sequential const block is enough for these three ID tables.
    result = {}
    value = initial
    for line in (ROOT / filename).read_text().splitlines():
        match = re.match(r'\s*const (\w+)', line)
        if match:
            result[match[1]] = value
            value += 1
    return result


ABILITY = constants('constants/ability_constants.asm')
MON = constants('constants/pokemon_constants.asm', 1)
MOVE = constants('constants/move_constants.asm')


def nickname(text):
    return [ord(c) - ord('A') + 0x80 if c != ' ' else 0x7f for c in text] + [0x53] * (11 - len(text))


class Battle:
    def __init__(self, rom, graphics=False):
        self.symbols = {}
        for line in rom.with_suffix('.sym').read_text().splitlines():
            if line and not line.startswith(';'):
                loc, name = line.split()
                self.symbols[name] = tuple(int(x, 16) for x in loc.split(':'))
        self.p = PyBoy(str(rom), window='null', sound_emulated=False, log_level='ERROR')
        self.p.set_emulation_speed(0)
        self.graphics = graphics
        self.frame_sink = None
        if graphics:
            self.p.tick(600)
        self.m, self.r = self.p.memory, self.p.register_file
        self.events = []
        if not graphics:
            self.m[0xff50] = 1
            self.m[0xffff] = 0
            self.m[0xff0f] = 0
            self.m[0xff40] = 0
            self.m[0xc000:0xe000] = [0] * 0x2000
            self.m[0xff80:0xffff] = [0] * 0x7f
        self.m[0xff70] = 1
        if graphics:
            self.m[self.addr('wBattle'):self.addr('wBattleEnd')] = [0] * (self.addr('wBattleEnd')-self.addr('wBattle'))
            for name in ['wPlayerIllusion', 'wEnemyIllusion', 'wBattleType', 'wPlayerGender',
                         'wOptions2', 'wSpriteUpdatesEnabled', 'hVBlank', 'hMapAnims',
                         'hSCX', 'hSCY', 'hLCDCPointer', 'hRequested1bpp', 'hRequested2bpp',
                         'hDMATransfer', 'hBGMapUpdate', 'wCurBattleMon', 'wCurPartyMon',
                         'wInBattleTowerBattle', 'wLinkMode', 'wTrainerPal', 'wLowHealthAlarm']:
                self.write(name, 0)
            self.write('hWY', 144)
            self.write('hWX', 7)
            self.write('hBGMapAddress', 0)
            self.m[self.addr('hBGMapAddress')+1] = 0x98
            self.write('wTextboxFlags', 0)
            self.write('wInitialOptions', 0x82)
        self.write('wBattleMode', 2)
        self.write('wTypeModifier', 0x10)
        self.write('wOptions1', 0x80)
        self.write('wPartyCount', 6)
        self.write('wOTPartyCount', 6)
        self.stride = self.addr('wPartyMon2') - self.addr('wPartyMon1')
        for side in range(2):
            for slot in range(6):
                self.party(side, slot, species=MON['DITTO'] if slot == 0 else MON['PIKACHU'])
            prefix = 'wEnemyMon' if side else 'wBattleMon'
            for field in ['Species', 'Form', 'Level']:
                self.write(prefix + field, {'Species': MON['DITTO'], 'Form': 1, 'Level': 50}[field])
            for field in ['HP', 'MaxHP', 'Attack', 'Defense', 'Speed', 'SpAtk', 'SpDef']:
                self.word(prefix + field, 160 if field in ['HP', 'MaxHP'] else 100)
            self.write(prefix + 'Moves', MOVE['TACKLE'])
            self.write(prefix + 'PP', 35)
            self.m[self.addr(prefix+'Nickname'):self.addr(prefix+'Nickname')+11] = nickname('MIMIC' if not side else 'RIVAL')
            self.write('wTempEnemyMonSpecies' if side else 'wTempBattleMonSpecies', MON['DITTO'])
            self.write('wTempEnemyMonForm' if side else 'wTempBattleMonForm', 1)
            self.m[self.addr('wEnemyStatLevels' if side else 'wPlayerStatLevels'):self.addr('wEnemyStatLevels' if side else 'wPlayerStatLevels')+8] = [7]*8
        if not graphics:
            # Keep calculations/state transitions intact; bypass drawing and input waits.
            for name in ['StdBattleTextbox', 'BattleTextbox', 'RefreshBattleHuds',
                         'UpdateHPBarBattleHuds', 'GetMonBackpic', 'GetMonFrontpic',
                         'PlayBattleAnimDE', 'FarPlayBattleAnimation', 'AnimateCurrentMove',
                         'AnimateFailedMove', 'ApplyTilemapInVBlank', 'DelayFrame', 'DelayFrames',
                         'BattleCommand_movedelay', 'BattleCommand_raisesubnoanim',
                         'BeginAndShowUserAbility', 'EndAbility']:
                self.stub(name)
            self.stub('BattleEffect_ButItFailed')

    def addr(self, name):
        return self.symbols[name][1]

    def write(self, name, value):
        self.m[self.addr(name)] = value

    def read(self, name):
        return self.m[self.addr(name)]

    def word(self, name, value):
        self.m[self.addr(name):self.addr(name)+2] = [value >> 8, value & 255]

    def hp(self, side):
        a = self.addr('wEnemyMonHP' if side else 'wBattleMonHP')
        return self.m[a] * 256 + self.m[a+1]

    def party(self, side, slot, *, species=None, hp=160, egg=False, form=1, shiny=False):
        prefix = 'wOTPartyMon1' if side else 'wPartyMon1'
        base = self.addr(prefix) + slot * self.stride
        for field, value in [('Species', species or MON['PIKACHU']), ('Form', form | (0x40 if egg else 0)),
                             ('Personality', 0x80 if shiny else 0), ('Level', 50)]:
            self.m[base + self.addr(prefix+field)-self.addr(prefix)] = value
        for field, value in [('HP', hp), ('MaxHP', 160)]:
            at = base + self.addr(prefix+field)-self.addr(prefix)
            self.m[at:at+2] = [value >> 8, value & 255]
        at = self.addr('wOTPartyMonNicknames' if side else 'wPartyMonNicknames') + slot*11
        self.m[at:at+11] = nickname(('RIVAL' if side else 'MIMIC') if slot == 0 else 'MASK' + chr(ord('A')+slot))

    def stub(self, name):
        bank, addr = self.symbols[name]
        self.m[bank, addr] = 0xc9
        self.p.hook_register(bank, addr, lambda _: self.events.append((name, self.read('hBattleTurn'), self.r.HL)), None)

    def tick(self, frames=1):
        for _ in range(frames):
            self.p.tick(1, self.graphics, False)
            if self.frame_sink is not None:
                self.frame_sink(self.p.screen.image)

    def call(self, name, *, side=None, **registers):
        if side is not None:
            self.write('hBattleTurn', side)
        bank, addr = self.symbols[name]
        self.m[0x2000] = bank or 1
        self.write('hROMBank', bank or 1)
        # PyBoy can finish a title-screen HALT by advancing PC once. A leading
        # NOP safely absorbs that advance before the injected CALL instruction.
        self.m[0, 0x100:0x106] = [0, 0xcd, addr & 255, addr >> 8, 0x18, 0xfe]
        self.r.SP = self.addr('wStackTop')
        self.r.PC = 0x100
        for key, value in registers.items():
            setattr(self.r, key, value)
        for frame in range(600 if self.graphics else 30):
            if self.graphics and frame % 12 == 0:
                self.p.button('a', 1)
            self.tick()
            if self.r.PC == 0x104:
                return
        raise AssertionError(f'{name} did not return: PC={self.r.PC:04x}, SP={self.r.SP:04x}')

    def assign_illusion_to_ditto(self):
        self.assign_ability(MON['DITTO'], ABILITY['ILLUSION'])

    def assign_ability(self, species, ability):
        # Patch only the emulator's ROM image. Production base stats stay unchanged.
        bank, base = self.symbols['BaseData']
        size = self.addr('wCurBaseDataEnd') - self.addr('wCurBaseData')
        ability_offset = self.addr('wBaseAbility1') - self.addr('wCurBaseData')
        at = base + (species-1)*size + ability_offset
        self.m[bank, at:at+3] = [ability] * 3
        self.write('wInitialOptions', self.read('wInitialOptions') | 2)

    def activate(self, side=0):
        self.write('wEnemyAbility' if side else 'wPlayerAbility', ABILITY['ILLUSION'])
        self.call('InitUserIllusion', side=side)

    def close(self):
        self.p.stop(save=False)


class IllusionTests(unittest.TestCase):
    def setUp(self):
        self.b = Battle(ROM)

    def tearDown(self):
        self.b.close()

    def test_all_party_orders_both_sides(self):
        b = self.b
        checked = 0
        for side in range(2):
            b.write('wEnemyAbility' if side else 'wPlayerAbility', ABILITY['ILLUSION'])
            b.write('wPlayerAbility' if side else 'wEnemyAbility', 0)
            for count in range(1, 7):
                b.write('wOTPartyCount' if side else 'wPartyCount', count)
                for tail in itertools.product(range(3), repeat=count-1):
                    states = (1,) + tail  # 0=fainted, 1=alive, 2=Egg (even with HP)
                    for slot, state in enumerate(states):
                        b.party(side, slot, hp=160 if state else 0, egg=state == 2)
                    expected = max(i for i, state in enumerate(states) if state == 1)
                    b.call('InitUserIllusion', side=side)
                    self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), expected+1 if expected else 0, (side, states))
                    self.assertEqual(b.read('hBattleTurn'), side)
                    checked += 1
        print(f'  checked {checked} party configurations', flush=True)

    def test_last_eligible_is_self_and_switch_reset(self):
        b = self.b
        for side in range(2):
            b.write('wCurOTMon' if side else 'wCurBattleMon', 5)
            b.activate(side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 0)
            b.write('wCurOTMon' if side else 'wCurBattleMon', 0)
            b.activate(side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 6)
            b.write('wEnemyAbility' if side else 'wPlayerAbility', 0)
            b.call('InitUserIllusion', side=side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 0)

    def test_revive_does_not_reselect(self):
        b = self.b
        for side in range(2):
            b.party(side, 5, hp=0)
            b.activate(side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 5)
            # Restore the later party member's HP, as Revive does.
            b.party(side, 5, hp=0, species=MON['CHARIZARD'])
            if side == 0:
                b.write('wCurPartyMon', 5)
                b.write('wMonType', 0)
                b.call('IsMonFainted')
                b.call('ReviveHalfHP')
                at = b.addr('wPartyMon1HP') + 5*b.stride
                self.assertEqual(b.m[at]*256+b.m[at+1], 80)
            else:
                b.party(side, 5, hp=80, species=MON['CHARIZARD'])
            b.call('GetEnemyBattleAppearance' if side else 'GetPlayerBattleAppearance')
            self.assertEqual(b.r.C, MON['PIKACHU'])
            b.call('RunEntryAbilitiesInner', side=side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 5)
            # Re-entry may select the revived member.
            b.call('InitUserIllusion', side=side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 6)

    def test_gas_blocks_entry_and_does_not_reactivate(self):
        b = self.b
        for side in range(2):
            b.write('wPlayerAbility' if side else 'wEnemyAbility', ABILITY['NEUTRALIZING_GAS'])
            b.activate(side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 0)
            b.call('SuppressUserAbilities', side=1-side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 0)

    def test_gas_dismisses_existing_disguise(self):
        b = self.b
        b.activate()
        b.write('wEnemyAbility', ABILITY['NEUTRALIZING_GAS'])
        b.call('NeutralizingGasAbility', side=1)
        self.assertEqual(b.read('wPlayerIllusion'), 0)
        self.assertEqual(b.read('hBattleTurn'), 1)
        self.assertEqual(b.m[b.addr('wBattleMonNickname'):b.addr('wBattleMonNickname')+11], nickname('MIMIC'))

    def test_direct_damage_reveals_both_sides_once(self):
        b = self.b
        for side in range(2):
            b.activate(side)
            b.word('wCurDamage', 10)
            b.call('TakeDamage', side=1-side)
            self.assertEqual(b.hp(side), 150)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 0)
            reveals = [e for e in b.events if e[0] == 'StdBattleTextbox' and e[2] == b.addr('IllusionWoreOffText')]
            b.word('wCurDamage', 10)
            b.call('TakeDamage', side=1-side)
            self.assertEqual(b.hp(side), 140)
            self.assertEqual(len([e for e in b.events if e[0] == 'StdBattleTextbox' and e[2] == b.addr('IllusionWoreOffText')]), len(reveals))

    def test_zero_damage_and_substitute_do_not_reveal(self):
        b = self.b
        b.activate()
        b.word('wCurDamage', 0)
        b.call('TakeDamage', side=1)
        self.assertEqual(b.read('wPlayerIllusion'), 6)
        b.write('wMoveHitState', 2)
        b.word('wPlayerSubstituteHP', 30)
        b.word('wCurDamage', 10)
        b.call('TakeDamage', side=1)
        self.assertEqual(b.hp(0), 160)
        self.assertEqual(b.read('wPlayerIllusion'), 6)
        self.assertEqual(b.read('wPlayerSubstituteHP')*256+b.m[b.addr('wPlayerSubstituteHP')+1], 20)

    def test_poison_burn_spikes_and_self_damage_do_not_reveal(self):
        b = self.b
        for side in range(2):
            for routine, status in [('HandlePoison.do_it', 8), ('HandleBurn.do_it', 16), ('SpikesDamage', 0), ('TakeOpponentDamage', 0)]:
                b.word('wEnemyMonHP' if side else 'wBattleMonHP', 160)
                b.write('wEnemyMonStatus' if side else 'wBattleMonStatus', status)
                b.write('wEnemyHazards' if side else 'wPlayerHazards', 0x10)
                b.word('wCurDamage', 10)
                b.activate(side)
                b.call(routine, side=side)
                self.assertLess(b.hp(side), 160, (side, routine))
                self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 6, routine)

    def test_transformed_user_cannot_activate(self):
        b = self.b
        for side in range(2):
            b.write('wEnemySubStatus2' if side else 'wPlayerSubStatus2', 0x10)
            b.activate(side)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 0)
            b.call('GetUserAbility', side=side)
            self.assertEqual(b.r.A, 0)

    def test_transform_target_disguised_fails_then_revealed_succeeds(self):
        b = self.b
        for side in range(2):
            b.write('wPlayerSubStatus2', 0)
            b.write('wEnemySubStatus2', 0)
            b.activate(1-side)
            b.events.clear()
            b.call('BattleCommand_transform', side=side)
            self.assertTrue(any(e[0] == 'BattleEffect_ButItFailed' for e in b.events))
            self.assertEqual(b.read('wEnemySubStatus2' if side else 'wPlayerSubStatus2') & 0x10, 0)
            b.call('BreakUserIllusion', side=1-side)
            b.events.clear()
            b.call('BattleCommand_transform', side=side)
            self.assertFalse(any(e[0] == 'BattleEffect_ButItFailed' for e in b.events))
            self.assertEqual(b.read('wEnemySubStatus2' if side else 'wPlayerSubStatus2') & 0x10, 0x10)
            self.assertEqual(b.read('wEnemyIllusion' if side else 'wPlayerIllusion'), 0)

    def test_successful_transform_dismisses_users_own_illusion(self):
        b = self.b
        b.activate()
        b.call('BattleCommand_transform', side=0)
        self.assertEqual(b.read('wPlayerIllusion'), 0)
        self.assertEqual(b.read('wPlayerSubStatus2') & 0x10, 0x10)

    def test_appearance_and_names_do_not_change_battle_identity(self):
        b = self.b
        for side in range(2):
            b.party(side, 5, species=MON['RAICHU'], form=2, shiny=True)
            prefix = 'wEnemyMon' if side else 'wBattleMon'
            before = b.m[b.addr(prefix):b.addr(prefix+'StructEnd')]
            b.activate(side)
            b.call('GetEnemyBattleAppearance' if side else 'GetPlayerBattleAppearance')
            self.assertEqual((b.r.C, b.r.B), (MON['RAICHU'], 2))
            self.assertEqual(b.m[b.addr(prefix):b.addr(prefix+'StructEnd')], before)
            self.assertEqual(b.m[b.addr(prefix+'Nickname'):b.addr(prefix+'Nickname')+11], nickname('MASKF'))
            b.call('GetEnemyMonPersonality' if side else 'GetPartyMonPersonality')
            self.assertEqual(b.m[b.r.HL], 0x80)

    def test_preview_does_not_modify_active_disguise(self):
        b = self.b
        b.assign_illusion_to_ditto()
        b.write('wEnemySwitchTarget', 1)
        b.write('wEnemyIllusion', 4)
        b.call('GetEnemySwitchIllusionName', side=0)
        self.assertEqual(b.m[b.addr('wEnemyMonNickname'):b.addr('wEnemyMonNickname')+11], nickname('MASKF'))
        self.assertEqual(b.read('wEnemyIllusion'), 4)
        self.assertEqual(b.read('hBattleTurn'), 0)
        b.m[b.addr('wEnemyMonNickname'):b.addr('wEnemyMonNickname')+11] = nickname('RIVAL')
        b.write('wPlayerAbility', ABILITY['NEUTRALIZING_GAS'])
        b.call('GetEnemySwitchIllusionName', side=1)
        self.assertEqual(b.m[b.addr('wEnemyMonNickname'):b.addr('wEnemyMonNickname')+11], nickname('RIVAL'))
        self.assertEqual(b.read('wEnemyIllusion'), 4)

    def test_message_names_active_benched_and_outside_battle(self):
        b = self.b
        b.activate()
        b.call('GetBattleOrPartyNickname')
        self.assertEqual(b.m[b.addr('wStringBuffer1'):b.addr('wStringBuffer1')+11], nickname('MASKF'))
        b.write('wCurPartyMon', 2)
        b.call('GetBattleOrPartyNickname')
        self.assertEqual(b.m[b.addr('wStringBuffer1'):b.addr('wStringBuffer1')+11], nickname('MASKC'))
        b.write('wCurPartyMon', 0)
        b.write('wBattleMode', 0)
        b.call('GetBattleOrPartyNickname')
        self.assertEqual(b.m[b.addr('wStringBuffer1'):b.addr('wStringBuffer1')+11], nickname('MIMIC'))

    def test_item_name_uses_disguise_without_changing_base_data(self):
        b = self.b
        b.activate()
        b.write('wCurPartySpecies', MON['DITTO'])
        b.call('UseItem_GetBaseDataAndNickParameters')
        self.assertEqual(b.m[b.addr('wStringBuffer1'):b.addr('wStringBuffer1')+11], nickname('MASKF'))
        self.assertEqual(b.read('wCurSpecies'), MON['DITTO'])
        b.write('wBattleMode', 0)
        b.call('UseItem_GetBaseDataAndNickParameters')
        self.assertEqual(b.m[b.addr('wStringBuffer1'):b.addr('wStringBuffer1')+11], nickname('MIMIC'))

    def test_lethal_damage_and_mold_breaker_reveal(self):
        b = self.b
        b.activate()
        b.write('wEnemyAbility', ABILITY['MOLD_BREAKER'])
        b.write('wMoveState', 0x44)  # both sides ignoring ignorable abilities
        b.word('wCurDamage', 200)
        b.call('TakeDamage', side=1)
        self.assertEqual(b.hp(0), 0)
        self.assertEqual(b.read('wPlayerIllusion'), 0)
        self.assertEqual(b.read('wWhichMonFaintedFirst'), 1)

    def test_clear_battle_ram_resets_both_disguises(self):
        b = self.b
        b.activate(0)
        b.activate(1)
        b.call('ClearBattleRAM')
        self.assertEqual((b.read('wPlayerIllusion'), b.read('wEnemyIllusion')), (0, 0))

    def test_transformed_gas_does_not_suppress(self):
        b = self.b
        b.write('wEnemyAbility', ABILITY['NEUTRALIZING_GAS'])
        b.write('wEnemySubStatus2', 0x10)
        b.activate()
        self.assertEqual(b.read('wPlayerIllusion'), 6)
        b.call('CheckNeutralizingGasIllusion', side=1)
        self.assertEqual(b.read('wPlayerIllusion'), 6)

    def test_gas_arrival_before_lethal_hazards(self):
        b = self.b
        b.activate()
        b.write('wEnemyAbility', ABILITY['NEUTRALIZING_GAS'])
        b.word('wEnemyMonHP', 1)
        b.write('wEnemyHazards', 0x10)
        b.call('CheckNeutralizingGasIllusion', side=1)
        self.assertEqual(b.read('wPlayerIllusion'), 0)
        b.call('SpikesDamage', side=1)
        self.assertEqual(b.hp(1), 0)
        b.call('SuppressUserAbilities', side=1)
        self.assertEqual(b.read('wPlayerIllusion'), 0)

    def test_substitute_break_then_next_hit_reveals(self):
        b = self.b
        b.activate()
        b.write('wPlayerSubStatus4', 0x10)
        b.word('wPlayerSubstituteHP', 5)
        b.word('wCurDamage', 10)
        b.call('BattleCommand_applydamage', side=1)
        self.assertEqual(b.read('wPlayerIllusion'), 6)
        self.assertEqual(b.read('wPlayerSubStatus4') & 0x10, 0)
        self.assertEqual(b.hp(0), 160)
        b.word('wCurDamage', 10)
        b.call('BattleCommand_applydamage', side=1)
        self.assertEqual(b.read('wPlayerIllusion'), 0)
        self.assertEqual(b.hp(0), 150)

    def test_palette_uses_disguise_form_shininess_and_dvs(self):
        b = self.b
        for side in range(2):
            b.party(side, 5, species=MON['RAICHU'], form=2, shiny=True)
            b.activate(side)
            party = 'wOTPartyMon1' if side else 'wPartyMon1'
            personality = b.addr(party+'Personality') + 5*b.stride
            b.call('GetMonNormalOrShinyPalettePointer', A=MON['RAICHU'], B=personality >> 8, C=personality & 255)
            expected = b.r.HL
            b.call('GetEnemyFrontpicPalettePointer' if side else 'GetBattlemonBackpicPalettePointer')
            self.assertEqual(b.r.HL, expected)
            b.call('GetEnemyPaletteDVs' if side else 'GetPlayerPaletteDVs')
            self.assertEqual(b.r.HL, b.addr(party+'DVs') + 5*b.stride)
            self.assertEqual((b.r.D, b.r.E), (2, MON['RAICHU']))
            # A trainer portrait must still select its trainer palette.
            b.write('wTempEnemyMonSpecies' if side else 'wTempBattleMonSpecies', 0)
            routine = 'GetEnemyFrontpicPalettePointer' if side else 'GetBattlemonBackpicPalettePointer'
            b.call(routine)
            portrait = b.r.HL
            b.write('wEnemyIllusion' if side else 'wPlayerIllusion', 0)
            b.call(routine)
            self.assertEqual(b.r.HL, portrait)

    def test_ability_flags(self):
        b = self.b
        for routine in ['AbilityCanBeCopied', 'AbilityCanBeTraced', 'AbilityCanBeSwapped']:
            b.call(routine, A=ABILITY['ILLUSION'])
            self.assertFalse(b.r.F & 0x80, routine)
        b.call('AbilityCanBeSuppressed', A=ABILITY['ILLUSION'])
        self.assertTrue(b.r.F & 0x80)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    args, remaining = parser.parse_known_args()
    ROM = args.rom.resolve()
    unittest.main(argv=[__file__] + remaining)
