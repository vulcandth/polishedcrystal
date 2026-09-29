#!/usr/bin/env python3
"""Render Illusion integration scenarios without stubbing the battle engine.

Usage: python3 tests/illusion_screenshots.py ROM.gbc OUTPUT_DIRECTORY [--clips DIRECTORY]
Requires the same dependencies and matching .sym file as illusion.py.
"""
import argparse
from contextlib import contextmanager
import subprocess
from pathlib import Path

from illusion import ABILITY, MON, MOVE, Battle, nickname


@contextmanager
def record(battle, directory, name):
    """Stream every emulator frame to ffmpeg, with a readable final hold."""
    if directory is None:
        yield
        return
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / (name + '.mp4')
    encoder = subprocess.Popen([
        'ffmpeg', '-hide_banner', '-loglevel', 'error', '-y',
        '-f', 'rawvideo', '-pixel_format', 'rgb24', '-video_size', '160x144',
        '-framerate', '60', '-i', 'pipe:0', '-an',
        '-vf', 'scale=640:576:flags=neighbor', '-c:v', 'libx264', '-crf', '18',
        '-pix_fmt', 'yuv420p', '-movflags', '+faststart', str(path),
    ], stdin=subprocess.PIPE)
    battle.frame_sink = lambda frame: encoder.stdin.write(frame.convert('RGB').tobytes())
    try:
        yield
        battle.tick(120)
    finally:
        battle.frame_sink = None
        encoder.stdin.close()
        if encoder.wait():
            raise RuntimeError(f'ffmpeg could not encode {path}')


def render(rom, output, clips=None):
    output.mkdir(parents=True, exist_ok=True)
    b = Battle(rom.resolve(), graphics=True)

    def capture(filename):
        b.call('ApplyTilemapInVBlank')
        b.tick(3)
        b.p.screen.image.save(output / filename)

    def used_move(side, name):
        at = b.addr('wStringBuffer2')
        b.m[at:at+11] = nickname(name)
        b.write('wEnemyMoveStruct' if side else 'wPlayerMoveStruct', MOVE[name])
        b.call('DisplayUsedMoveText', side=side)

    def rename(side, slot, name):
        at = b.addr('wOTPartyMonNicknames' if side else 'wPartyMonNicknames') + slot*11
        b.m[at:at+11] = nickname(name)

    try:
        b.assign_illusion_to_ditto()
        b.party(0, 5, species=MON['PIKACHU'])
        b.party(1, 5, species=MON['CHARIZARD'])
        rename(0, 5, 'SPARK')
        rename(1, 5, 'BLAZE')
        for routine in ['DisableLCD', 'ClearTileMap', 'ClearSprites', 'LoadStandardFont',
                        'LoadFrame', 'EnableLCD', 'LoadBattleFontsHPBar']:
            b.call(routine)

        with record(b, clips, '01-disguises'):
            # Use the link-style trainer name, bypassing story-specific trainer dialog.
            # This runs both sides locally; it does not simulate a link connection.
            b.write('wLinkMode', 1)
            at = b.addr('wOTPlayerName')
            b.m[at:at+11] = nickname('TESTER')
            b.write('wEnemySwitchTarget', 1)
            b.call('SendInUserPkmn', side=1)
            b.write('wPlayerSwitchTarget', 1)
            b.call('SendInUserPkmn', side=0)
            assert (b.read('wPlayerIllusion'), b.read('wEnemyIllusion')) == (6, 6)
            assert b.read('wBattleMonSpecies') == b.read('wEnemyMonSpecies') == MON['DITTO']
            b.write('wLinkMode', 0)
            used_move(0, 'TACKLE')
            # Check the actual rendered tilemap as well as taking a screenshot.
            tilemap = b.addr('wTilemap')
            assert b.m[tilemap+7*20+11:tilemap+7*20+16] == nickname('MIMIC')[:5]
            assert b.m[tilemap+1:tilemap+6] == nickname('BLAZE')[:5]
            assert b.m[tilemap+14*20+1:tilemap+14*20+6] == nickname('SPARK')[:5]
            capture('disguised.png')

        with record(b, clips, '02-transform-blocked'):
            used_move(0, 'TRANSFORM')
            b.call('BattleCommand_transform', side=0)
            assert not b.read('wPlayerSubStatus2') & 0x10
            assert b.read('wEnemyIllusion') == 6
            capture('transform-failed.png')

        with record(b, clips, '03-attack-reveal'):
            used_move(1, 'TACKLE')
            b.call('PlayBattleAnimDE', side=1, D=0, E=MOVE['TACKLE'])
            b.word('wCurDamage', 10)
            b.call('TakeDamage', side=1)
            assert b.hp(0) == 150 and b.read('wPlayerIllusion') == 0
            assert b.read('wEnemyIllusion') == 6
            capture('player-revealed.png')

        with record(b, clips, '04-gas-reveal'):
            # Switch in an actual Gas user through the same entry path as gameplay.
            b.assign_ability(MON['KOFFING'], ABILITY['NEUTRALIZING_GAS'])
            b.party(0, 1, species=MON['KOFFING'])
            rename(0, 1, 'GAS')
            b.write('wPlayerSwitchTarget', 2)
            b.call('SendInUserPkmn', side=0)
            assert b.read('wPlayerAbility') == ABILITY['NEUTRALIZING_GAS']
            assert b.read('wEnemyIllusion') == 0
            assert b.m[b.addr('wEnemyMonNickname'):b.addr('wEnemyMonNickname')+11] == nickname('RIVAL')
            capture('gas-revealed.png')

        with record(b, clips, '05-transform-after-reveal'):
            used_move(0, 'TRANSFORM')
            b.call('BattleCommand_transform', side=0)
            assert b.read('wPlayerSubStatus2') & 0x10
            assert b.read('wBattleMonSpecies') == MON['DITTO']
            assert b.read('wPlayerIllusion') == 0
            b.call('GetUserAbility', side=0)
            assert b.r.A == 0  # copied Illusion cannot function while transformed
            capture('transform-revealed.png')
        print(f'PASS: complete send-outs, HUD/text, damage, Gas switch-in and Transform; screenshots in {output}')
    finally:
        b.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--clips', type=Path, help='also record silent MP4 clips (requires ffmpeg)')
    args = parser.parse_args()
    render(args.rom, args.output, args.clips)
