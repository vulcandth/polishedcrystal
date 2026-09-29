; Illusion is presentation state, independent of battle species, stats and ability.
; The one-based party slot is selected ONLY on entry, so reviving a later party
; member cannot change an existing disguise. Zero means no active Illusion.

GetUserIllusion:
; Return a/hl = active disguise slot/value address, z if inactive. Preserves bc/de.
	ldh a, [hBattleTurn]
	and a
	ld hl, wPlayerIllusion
	jr z, .got_side
	ld hl, wEnemyIllusion
.got_side
	ld a, [hl]
	and a
	ret

GetOpponentIllusion:
	call StackCallOpponentTurn
	jr GetUserIllusion

InitUserIllusion:
; Called after loading the incoming battler, before any text or graphics.
	call GetUserIllusion
	ld [hl], 0
	call GetUserAbility
	cp ILLUSION
	ret nz
	ld a, BATTLE_VARS_SUBSTATUS2
	call GetBattleVar
	bit SUBSTATUS_TRANSFORMED, a
	ret nz

	ldh a, [hBattleTurn]
	and a
	ld a, [wPartyCount]
	ld hl, wPartyMon1
	ld de, wCurBattleMon
	jr z, .got_party
	ld a, [wOTPartyCount]
	ld hl, wOTPartyMon1
	ld de, wCurOTMon
.got_party
	ld c, a
	ld a, [de]
	ld b, a
	call FindIllusionTarget
	ld c, a
	call GetUserIllusion
	ld [hl], c
	; fallthrough

RefreshUserIllusionName:
; Battle nickname buffers are the names used by all battle text. The player's
; HUD reads the real party nickname instead. Also used after in-battle evolution.
	call GetUserIllusion
	ret z
	dec a
	jr CopyUserBattleNickname

RestoreUserBattleNickname:
	ldh a, [hBattleTurn]
	and a
	ld a, [wCurBattleMon]
	jr z, CopyUserBattleNickname
	ld a, [wCurOTMon]
CopyUserBattleNickname:
	ld b, a
	ldh a, [hBattleTurn]
	and a
	ld hl, wPartyMonNicknames
	ld de, wBattleMonNickname
	jr z, .got_names
	ld hl, wOTPartyMonNicknames
	ld de, wEnemyMonNickname
.got_names
	ld a, b
	call SkipNames
	ld bc, MON_NAME_LENGTH
	rst CopyBytes
	ret

FindIllusionTarget:
; hl = party, b = incoming slot (zero-based), c = party count.
; Return a = disguise slot (one-based), or zero if none/self. No state changes.
	ld a, c
	and a
	ret z
.loop
	dec c
	push hl
	ld a, c
	call GetPartyLocation
	ld de, MON_IS_EGG
	add hl, de
	bit MON_IS_EGG_F, [hl]
	jr nz, .skip
	ld de, MON_HP - MON_IS_EGG
	add hl, de
	ld a, [hli]
	or [hl]
	jr nz, .found
.skip
	pop hl
	ld a, c
	and a
	jr nz, .loop
	ret
.found
	pop hl
	ld a, c
	sub b
	ret z ; the last eligible party member is the battler itself
	ld a, c
	inc a
	ret

GetEnemySwitchIllusionName:
; OfferSwitch has already buffered the incoming mon's real nickname. Predict
; only its name, without activating or changing either battler's Illusion.
	ldh a, [hBattleTurn]
	push af
	call SetPlayerTurn
	call GetUserAbility
	cp NEUTRALIZING_GAS
	jr z, .done
	ld a, [wEnemySwitchTarget]
	dec a
	ld hl, wOTPartyMon1
	call GetPartyLocation
	ld c, [hl]
	ld de, MON_PERSONALITY
	add hl, de
	call GetAbility
	cp ILLUSION
	jr nz, .done
	ld a, [wEnemySwitchTarget]
	dec a
	ld b, a
	ld a, [wOTPartyCount]
	ld c, a
	ld hl, wOTPartyMon1
	call FindIllusionTarget
	and a
	jr z, .done
	dec a
	ld b, a
	call SetEnemyTurn
	ld a, b
	call CopyUserBattleNickname
.done
	pop af
	ldh [hBattleTurn], a
	ret

GetBattleOrPartyNickname:
; Experience, item and move-learning text uses the active disguise's name.
; Benched recipients and out-of-battle callers keep the real party nickname.
	ld a, [wBattleMode]
	and a
	jr z, .party
	ld a, [wPlayerIllusion]
	and a
	jr z, .party
	ld a, [wCurBattleMon]
	ld b, a
	ld a, [wCurPartyMon]
	cp b
	jr z, .active
.party
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	jmp GetNickname
.active
	ld hl, wBattleMonNickname
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	rst CopyBytes
	ret

CheckNeutralizingGasIllusion:
	call GetUserAbility
	cp NEUTRALIZING_GAS
	ret nz
	; fallthrough

BreakOpponentIllusion:
	call StackCallOpponentTurn
BreakUserIllusion:
	call GetUserIllusion
	ret z
	ld [hl], 0
	call RestoreUserBattleNickname
	ldh a, [hBattleTurn]
	and a
	jr nz, .enemy
	farcall GetMonBackpic
	jr .redraw
.enemy
	farcall GetMonFrontpic
.redraw
	call RefreshBattleHuds
	ld hl, IllusionWoreOffText
	jmp StdBattleTextbox

GetUserBattleAppearance:
	ldh a, [hBattleTurn]
	and a
	jr nz, GetEnemyBattleAppearance
	; fallthrough

GetPlayerBattleAppearance:
; Return the displayed species/form in c/b. Clobbers a, de, hl.
	ld a, [wPlayerIllusion]
	and a
	jr nz, .illusion
	ld a, [wBattleMonSpecies]
	ld c, a
	ld a, [wBattleMonForm]
	ld b, a
	ret
.illusion
	ld hl, wPartyMon1
	jr GetIllusionAppearance

GetEnemyBattleAppearance:
	ld a, [wEnemyIllusion]
	and a
	jr nz, .illusion
	ld a, [wEnemyMonSpecies]
	ld c, a
	ld a, [wEnemyMonForm]
	ld b, a
	ret
.illusion
	ld hl, wOTPartyMon1
GetIllusionAppearance:
	dec a
	call GetPartyLocation
	ld c, [hl]
	ld de, MON_FORM
	add hl, de
	ld b, [hl]
	ret
