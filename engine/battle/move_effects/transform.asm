BattleCommand_transform:
	call ClearLastMove

	ld a, BATTLE_VARS_SUBSTATUS2_OPP
	call GetBattleVarAddr
	bit SUBSTATUS_TRANSFORMED, [hl]
	jmp nz, BattleEffect_ButItFailed

	ldh a, [hBattleTurn]
	and a
	ld hl, wEnemyMonSpecies
	ld de, wEnemyMonItem
	jr z, .got_mon_item
	ld hl, wBattleMonSpecies
	ld de, wBattleMonItem
.got_mon_item
	ld a, [hl]
	cp MEWTWO
	jr nz, .not_armored_mewtwo
	ld a, [de]
	cp ARMOR_SUIT
	jmp z, BattleEffect_ButItFailed
.not_armored_mewtwo

	call GetTrueUserAbility
	cp INFILTRATOR
	jr z, .bypass_sub
	ld a, BATTLE_VARS_SUBSTATUS4_OPP
	call GetBattleVarAddr
	bit SUBSTATUS_SUBSTITUTE, [hl]
	jmp nz, BattleEffect_ButItFailed
.bypass_sub
	call CheckHiddenOpponent
	jmp nz, BattleEffect_ButItFailed

	farcall GetDisableEncoreMoves
	push de
	xor a
	ld [wNumHits], a
	ld a, $1
	ld [wBattleAnimParam], a
	ld a, BATTLE_VARS_SUBSTATUS4
	call GetBattleVarAddr
	bit SUBSTATUS_SUBSTITUTE, [hl]
	push af
	jr z, .mimic_substitute
	call CheckUserIsCharging
	jr nz, .mimic_substitute
	ld hl, SUBSTITUTE
	call GetMoveIDFromIndex
	call LoadAnim
.mimic_substitute
	ld a, BATTLE_VARS_SUBSTATUS2
	call GetBattleVarAddr
	set SUBSTATUS_TRANSFORMED, [hl]
	call ResetActorDisable
	ld hl, wBattleMonSpecies
	ld de, wEnemyMonSpecies
	ldh a, [hBattleTurn]
	and a
	jr nz, .got_mon_species
	ld hl, wEnemyMonSpecies
	ld de, wBattleMonSpecies
	xor a
	ld [wCurMoveNum], a
.got_mon_species
	push hl
	ld a, [hli]
	ld [de], a
	inc hl
	inc de
	inc de
	ld bc, NUM_MOVES
	rst CopyBytes

	; copy DVs and personality
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
; move pointer to stats
	ld bc, wBattleMonStats - wBattleMonPP
	add hl, bc
	push hl
	ld h, d
	ld l, e
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld bc, wBattleMonStructEnd - wBattleMonStats
	rst CopyBytes
; init the power points
	ld bc, wBattleMonMoves - wBattleMonStructEnd
	add hl, bc
	call SwapHLDE
	ld bc, wBattleMonPP - wBattleMonStructEnd
	add hl, bc
	ld b, NUM_MOVES
.pp_loop
	ld a, [de]
	inc de
	and a
	jr z, .done_move
	push bc
	ld bc, SKETCH
	call CompareMove
	pop bc
	ld a, 1
	jr z, .done_move
	ld a, 5
.done_move
	ld [hli], a
	dec b
	jr nz, .pp_loop
	pop hl
	ld a, [hl]
	assert wBattleMonForm - wBattleMonSpecies == wEnemyMonForm - wEnemyMonSpecies
	ld bc, wBattleMonForm - wBattleMonSpecies
	add hl, bc
	ld b, [hl]
	ld hl, wNamedObjectIndex
	ld [hli], a
	ld [hl], b
	call GetPokemonName
	ld hl, wEnemyStatLevels
	ld de, wPlayerStatLevels
	ld bc, 8
	call BattleSideCopy
	call _CheckBattleEffects
	jr c, .mimic_anims
	ld a, BATTLE_VARS_SUBSTATUS2
	call GetBattleVar
	bit SUBSTATUS_MINIMIZED, a
	jr nz, .mimic_anims
	; Animation is done "raw" to allow Imposter
	; to use the correct animation
	ld de, TRANSFORM
	call FarPlayBattleAnimation
	jr .after_anim

.mimic_anims
	call BattleCommand_movedelay
	call BattleCommand_raisesubnoanim
.after_anim
	xor a
	ld [wNumHits], a
	ld a, $2
	ld [wBattleAnimParam], a
	pop af
	jr z, .no_substitute
	ld hl, SUBSTITUTE
	call GetMoveIDFromIndex
	call LoadAnim
.no_substitute
	ld hl, TransformedText
	call StdBattleTextbox
	pop de
	farcall SetDisableEncoreMoves

	; Update revealed moves if player transformed: the AI knows what its own moves are...
	ldh a, [hBattleTurn]
	and a
	jr nz, .move_reveal_done
	ld hl, wBattleMonMoves
	ld de, wPlayerUsedMoves
	ld bc, NUM_MOVES
	rst CopyBytes

.move_reveal_done
	; Copy ability. -1 is sentinel used when NG mon is about to switch out.
	ld a, BATTLE_VARS_ABILITY
	call GetBattleVarAddr
	ld a, BATTLE_VARS_ABILITY_OPP
	call GetBattleVar
	inc a
	jr nz, .no_gas
	ld a, NEUTRALIZING_GAS + 1 ; since we decrease a immediately
.no_gas
	dec a
	ld [hl], a
	cp IMPOSTER
	ret z ; avoid infinite loop

	farjp RunEntryAbilitiesInner
