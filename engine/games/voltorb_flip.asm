;RAM:
;c400-c418 Card Properties
;c419 state
;c41a level
;c41b x
;c41c y
;c41d last x
;c41e last y
;c41f cards flipped this game
;c440-c449 total numbers for row/col
;c450-c459 total voltorb for row/col
;c498 coins collected this game

;Card Properties (Bits):
;7-marked 0
;6-marked 1
;5-marked 2
;4-marked 3
;3-highlighted
;2-Card Flipped
;1,0-Card number

;States:
;sounds:
;7 move cursor
;157 game over
;195 flip card
;154 are you sure?
;159 quit
;148 level clear
;34 coin
;91 boom!

SECTION "Voltorb Flip", ROMX

VoltorbFlipGFX:
INCBIN "gfx/misc/voltorb_flip.2bpp"

VoltorbFlipPalette:
	dw $073f, $7fff, $26c4, $0000
	dw $073f, $11ff, $26c4, $0000
	dw $001f, $7fff, $26c4, $0000
	dw $001f, $7fff, $073f, $0000
	dw $001f, $7fff, $7680, $0000
	dw $001f, $7fff, $5134, $0000
	dw $001f, $7fff, $3B69, $0000
	dw $001f, $11ff, $3B69, $0000

VoltorbFlipPaletteBlank:
	dw $7fff, $7fff, $7fff, $7fff
	dw $7fff, $7fff, $7fff, $7fff
	dw $7fff, $7fff, $7fff, $7fff
	dw $7fff, $7fff, $7fff, $7fff
	dw $7fff, $7fff, $7fff, $7fff
	dw $7fff, $7fff, $7fff, $7fff
	dw $7fff, $7fff, $7fff, $7fff
	dw $7fff, $7fff, $7fff, $7fff
	
VoltorbFlip::;this is where the magic happens
	ld a, $d
	ldh [rIE], a
	call VFLoadGFX
	call VFLoadPalette
	call VFInitRAM
	call VFInitMap
	ld hl, $ff40
	set 7, [hl]
	xor a
	ld [hBGMapMode], a
	ld a, 1
	ld [hOAMUpdate], a ;disable sprite update
	ld [wVoltorbFlipLevel], a
	call VFInitLevel
	jp VFMainLoop
	
VFInitLevel:
	ld hl, wVoltorbFlipRowNumberTotals
	ld b, $20
	xor a
	ld [wVoltorbFlipCardsFlipped], a
	ld [wVoltorbFlipRoundCoins], a
	ld [wVoltorbFlipRoundCoins + 1], a
.clearrowcol
	ldi [hl], a
	dec b
	jr nz, .clearrowcol
	ld a, 1
	ld hl, wVoltorbFlipCardProps ;card start
	ld b, 25 ; because there are 25 cars
.set1
	ldi [hl], a ;starts off every card as a 1
	dec b
	jr nz, .set1
	ld a, [wVoltorbFlipLevel] ;level
	cp 5
	jr nc, .highlevel
	add a
	add 7 ;calculate the "base"
	ld c, a
	jr .retry23
.highlevel ;base is calculated differently starting at level 6
	add 12
	ld c, a
.retry23
	ld hl, wVoltorbFlipCardProps ;card start
	ld b, 25 ; because there are 25 cars
.loop23
	call Random
	ld a, [hRandomSub]
	xor $f
	jr z, .generate2
	dec a
	jr nz, .continue23
.generate3
	ld a, [hl]
	cp 1
	jr nz, .continue23 ;only write it if it's a 1
	ld a, 3
	ld [hl], a
	ld a, c
	sub 3
	ld c, a
	jr c, .done
	jr z, .done
	jr .continue23
.generate2
	ld a, [hl]
	cp 1
	jr nz, .continue23 ;only write it if it's a 1
	ld a, 2
	ld [hl], a
	ld a, c
	sub 2
	ld c, a
	jr c, .done
	jr z, .done
	jr .continue23
.continue23
	inc hl
	dec b
	jr nz, .loop23
	jr .retry23
.done
	ld a, [wVoltorbFlipLevel]
	add 5 ;number of voltorb
	cp 10
	ld c, a
	jr nc, .retryv
	ld c, 10 ;max of 10 voltorb
.retryv
	ld hl, wVoltorbFlipCardProps ;card start
	ld b, 25 ; because there are 25 cars
.loopv
	call Random
	ld a, [hRandomSub]
	xor $f
	jr z, .generatev
	dec a
	jr nz, .continuev
.generatev
	ld a, [hl]
	cp 1
	jr nz, .continuev ;only write it if it's a 1
	xor a
	ld [hl], a
	dec c
	jr z, .donev
	jr .continuev
.continuev
	inc hl
	dec b
	jr nz, .loopv
	jr .retryv
.donev
	ld de, wVoltorbFlipCardProps
	ld b, $5
	ld hl, wVoltorbFlipColumnNumberTotals
.addrowstart
	ld c, $5
.addrow
	ld a, [de]
	and 3
	push bc
	ld b, a
	ld a, [hl]
	add b
	ld [hl], a
	pop bc
	inc de
	dec c
	jr nz, .addrow
	inc hl
	dec b
	jr nz, .addrowstart
	ld de, wVoltorbFlipCardProps
	ld b, $5
	ld hl, wVoltorbFlipRowNumberTotals
.addcolstart
	ld c, $5
.addcol
	ld a, [de]
	and 3
	push bc
	ld b, a
	ld a, [hl]
	add b
	ldi [hl], a
	pop bc
	inc de
	dec c
	jr nz, .addcol
	ld hl, wVoltorbFlipRowNumberTotals
	dec b
	jr nz, .addcolstart
	ld de, wVoltorbFlipCardProps
	ld b, $5
	ld hl, wVoltorbFlipColumnVoltorbTotals
.voltrowstart
	ld c, $5
.voltrow
	ld a, [de]
	and 3
	jr nz, .rowskip
	inc [hl]
.rowskip
	inc de
	dec c
	jr nz, .voltrow
	inc hl
	dec b
	jr nz, .voltrowstart
	ld de, wVoltorbFlipCardProps
	ld b, $5
	ld hl, wVoltorbFlipRowVoltorbTotals
.voltcolstart
	ld c, $5
.voltcol
	ld a, [de]
	and 3
	jr nz, .colskip
	inc [hl]
.colskip
	inc hl
	inc de
	dec c
	jr nz, .voltcol
	ld hl, wVoltorbFlipRowVoltorbTotals
	dec b
	jr nz, .voltcolstart
	ld hl, $ff41
	ld a, 1
.wait
	ld a, [hl]
	and 3
	cp 1
	jr nz, .wait
	dec hl
	res 7, [hl]
	call VFInitMap
	ld hl, $ff40
	set 7, [hl]
	ret

VFMainLoop:
	call VFRefreshMap
	call VFInput
	jr VFMainLoop
	ld a, $f
	ldh [rIE], a
	ret

VFInput:
	ld hl, wVoltorbFlipCursorX
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	di
	push hl
	call VFRefreshScreen
	pop hl
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	call VFRefreshScreen
	ei
        ld hl, wVoltorbFlipCardProps
        ld a, [wVoltorbFlipCursorX]
        ld b, a
        ld a, [wVoltorbFlipCursorY]
        ld c, a
        add a
        add a
        add c
        add b
        ld e, a
        ld d, 0
        add hl, de
        ld d, h
        ld e, l
	ldh a, [hJoypadDown]
	bit B_PAD_B, a
	jp nz, .bbutton
	ldh a, [hJoypadPressed]
	and a
	ret z
	bit B_PAD_A, a
	jr nz, .abutton
bit B_PAD_SELECT, a
jp nz, VFKeepCoins
bit B_PAD_START, a
jp nz, VFExit
	push af
	ld a, [wVoltorbFlipCursorX]
	ld [wVoltorbFlipLastCursorX], a
	ld a, [wVoltorbFlipCursorY]
	ld [wVoltorbFlipLastCursorY], a
	push de
	ld de, 7
	call PlaySFX
	pop de
	pop af
	bit B_PAD_RIGHT, a
	jp nz, .rightbutton
	bit B_PAD_LEFT, a
	jp nz, .leftbutton
	bit B_PAD_UP, a
	jp nz, .upbutton
	bit B_PAD_DOWN, a
	jp nz, .downbutton
	
	ret

.abutton
	ld a, [de]
	bit 2, a
	ret nz
	set 2, a
	ld [de], a
	and 3
	cp 1
	jr z, .skipintense
	ld a, [wVoltorbFlipRemainingMultipliers]
	cp 1
	jr nz, .skipintense
	call Random
	ld a, [hRandomSub]
	and 3
	jr nz, .skipintense
	push de
	ld de, 154
	call WaitPlaySFX
	pop de
	push bc
	ld c, 120 ;2 seconds
	call DelayFrames
	pop bc
.skipintense
	call VFFlipAnimation
	ld a, [de]
	and 3
	jp z, VFBoom
	call VFMultiplyCoins
	ld hl, wVoltorbFlipCardsFlipped
	ld a, [wVoltorbFlipLevel]
	cp [hl]
	jr z, .skipcardinc
	inc [hl]
.skipcardinc
	ld hl, wVoltorbFlipCardProps
	ld bc, 25
.check23left
	ld a, [hli]
	and 7
	cp 2
	jr nz, .skip2add
	inc b
.skip2add
	cp 3
	jr nz, .skip3add
	inc b
.skip3add
	dec c
	jr nz, .check23left
	ld a, b
	ld [wVoltorbFlipRemainingMultipliers], a ;for the are you sure song
	and a
	ret nz
	call VFRefreshMap
	ld hl, wVoltorbFlipCursorX
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	di
	call VFRefreshScreen
	ei
	ld de, 148 ;level clear
	call WaitPlaySFX
	ld c, 60 ;1 seconds
	call DelayFrames
	ld a, [wVoltorbFlipLevel]
	inc a
	cp 9
	call z, .caplevel
	ld [wVoltorbFlipLevel], a
	ld de, 34
	call WaitPlaySFX
	ld hl, wVoltorbFlipRoundCoins
	ld a, [hli]
	ld d, a
	ld a, [hld]
	ld e, a
	push hl
	ld a, [wCoins]
	ld h, a
	ld a, [wCoins + 1]
	ld l, a
	add hl, de
	push hl
	pop de
	pop hl
	ld a, d
	cp $27
	jr nc, .maybecap
.totalcoins
	ld a, d
	ld [wCoins], a
	ld a, e
	ld [wCoins + 1], a
	call VFInitLevel
	ret	
.caplevel
	dec a
	ret
.maybecap
	cp $27
	jr nz, .capcoins
	ld a, e
	cp $f
	jr nc, .capcoins
	jr .totalcoins
.capcoins
	ld de, $270f
	jr .totalcoins

.bbutton
	and $f0
	ret z
	ld b, a
	ldh a, [hJoypadPressed]
	ld c, a
	ld a, [de]
	bit 7, b
	call nz, .bdown
	bit 6, b
	call nz, .bup
	bit 5, b
	jr nz, .bleft
	bit 4, b
	ret z
.bright
	bit 7, c
	jr nz, .toggle3
	bit 6, c
	jr nz, .toggle1
	ret
.bleft
	bit 7, c
	jr nz, .toggle2
	bit 6, c
	jr nz, .toggle0
	ret
.bup
	bit 5, c
	jr nz, .toggle0
	bit 4, c
	jr nz, .toggle1
	ret
.bdown
	bit 5, c
	jr nz, .toggle2
	bit 4, c
	jr nz, .toggle3
	ret
.toggle0
	xor $80
	ld [de], a
	ret
.toggle1
	xor $40
	ld [de], a
	ret
.toggle2
	xor $20
	ld [de], a
	ret
.toggle3
	xor $10
	ld [de], a
	ret

.rightbutton
	ld a, b
	inc a
	cp 5
	jr nz, .norowwrap
	xor a
.norowwrap
	ld [wVoltorbFlipCursorX], a
	ret
.leftbutton
	ld a, b
	dec a
	cp $ff
	jr nz, .norowwrap
	ld a, 4
	jr .norowwrap
	
.upbutton
	ld a, c
	dec a
	cp $ff
	jr nz, .nocolwrap
	ld a, 4
.nocolwrap
	ld [wVoltorbFlipCursorY], a
	ret
.downbutton
	ld a, c
	inc a
	cp 5
	jr nz, .nocolwrap
	xor a
	jr .nocolwrap

VFLoadGFX:
	ld hl, $ff41
	ld a, 1
.wait
	ld a, [hl]
	and 3
	cp 1
	jr nz, .wait
	dec hl
	res 7, [hl]
	ld bc, $7f80 ;load the gfx
	ld de, VoltorbFlipGFX
	ld hl, $9000
	call Copy2bpp
	ret
	
VFLoadPalette:
        ldh a, [rSVBK]
        push af
        ld a, BANK(wBGPals2)
        ldh [rSVBK], a
        ld bc, $e408
        ld hl, wBGPals2
        ld de, VoltorbFlipPalette
        call CopyPals
        ld bc, $e408
        ld hl, wOBPals2
        ld de, VoltorbFlipPaletteBlank
        call CopyPals
        pop af
        ldh [rSVBK], a
        call ForceUpdateCGBPals
        ret

VFInitRAM:
        ld hl, wVoltorbFlip
        ld bc, wVoltorbFlipEnd - wVoltorbFlip
	xor a
	call ByteFill
	ld hl, wVoltorbFlipState
	ldi [hl], a ;state
	ld a, 1
	ldi [hl], a ;level
	ld a, 2
	ldi [hl], a ;x
	ldi [hl], a ;y
	ret

VFInitMap:
	ld hl,wTilemap ;blank the screen
	ld bc, $0168
	ld a, 17
	call ByteFill
	ld hl,wAttrmap ;blank the screen
	ld bc, $0168
	ld a, 0
	call ByteFill
	ld b, 10
	di
	xor a
	ldh [rVBK], a
	hlcoord 0, 15
	call .redcounter
	hlcoord 3, 15
	ld a, 6
	call .drawcounter
	hlcoord 6, 15
	ld a, 3
	call .drawcounter
	hlcoord 9, 15
	ld a, 4
	call .drawcounter
	hlcoord 12, 15
	ld a, 5
	call .drawcounter
	hlcoord 15, 0
	call .redcounter
	hlcoord 15, 3
	ld a, 6
	call .drawcounter
	hlcoord 15, 6
	ld a, 3
	call .drawcounter
	hlcoord 15, 9
	ld a, 4
	call .drawcounter
	hlcoord 15, 12
	ld a, 5
	call .drawcounter
	hlcoord 15, 15
	ld de, .coinstring
	call PlaceString
	hlcoord 15, 16
	ld de, .blank
	call PlaceString
	hlcoord 15, 17
	ld de, .blank
	call PlaceString
	ei
	call VFRefreshMap
	di
	xor a
	ldh [rVBK], a
	ld a, 41
	ld [wTilemap + $63], a
	inc a
	ld [wTilemap + $77], a
	inc a
	ld [wTilemap + $8b], a
	inc a
	ld [wTilemap + $9f], a
	inc a
	ld [wTilemap + $b3], a
	ld a, [wVoltorbFlipLevel]
	add 102
	ld [wTilemap + $db], a
	ld b, 0
.loopa
	ld c, 0
.loopb
	call VFRefreshScreen1
	inc c
	ld a, c
	cp 6
	jr nz, .loopb
	inc b
	ld a, b
	cp 7
	jr nz, .loopa
	ei
	ret
.coinstring
	db "COINS@"
.blank
	db "     @"
	
.drawcounter
	push bc
	push hl
	ld bc, $0939
	add hl,bc
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ldi [hl], a
	ldi [hl], a
	ld [hl], a	
	pop hl
	pop bc
	ld a, 23
	ldi [hl], a
	ld a, 246
	ld [hl], a
	ld de, wVoltorbFlipColumnNumberTotals + 5 ;wVoltorbFlipRowNumberTotals is start of total numbers in row
	ld a, e
	sub b
	ld e, a ;load the correct row
	push bc
	ld bc, $0102
	call PrintNum
	pop bc
	dec hl
	dec hl
	ld a, [hl]
	sub $90
	ldi [hl], a
	ld a, [hl]
	sub $90
	ld [hl], a
	ld de, $0012
	add hl, de
	ld a, 9
	ldi [hl], a
	inc a
	ldi [hl], a
	ld a, 23
	add hl, de ;should move us to the bottom row of the counter
	ld a, 25
	ldi [hl], a
	inc a
	ldi [hl], a
	ld de, wVoltorbFlipColumnVoltorbTotals + 5 ;wVoltorbFlipRowVoltorbTotals is start of total voltorb in row
	ld a, e
	sub b
	ld e, a ;load the correct row
	ld a, [de]
	add 102
	ld [hl], a
	dec b
	ret
	
.redcounter
	ld a, 2
	push bc
	push hl
	ld bc, $0939
	add hl,bc
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ldi [hl], a
	ldi [hl], a
	ld [hl], a	
	pop hl
	pop bc
	ld a, 7
	ldi [hl], a
	ld a, 246
	ld [hl], a
	ld de, wVoltorbFlipColumnNumberTotals + 5 ;wVoltorbFlipRowNumberTotals is start of total numbers in row
	ld a, e
	sub b
	ld e, a ;load the correct row
	push bc
	ld bc, $0102
	call PrintNum
	pop bc
	ld de, $0011
	add hl, de
	ld a, 11
	ldi [hl], a
	inc a
	ldi [hl], a
	ld a, 7
	ld [hl], a
	inc de
	add hl, de ;should move us to the bottom row of the counter
	ld a, 27
	ldi [hl], a
	inc a
	ldi [hl], a
	ld de, wVoltorbFlipColumnVoltorbTotals + 5 ;wVoltorbFlipRowVoltorbTotals is start of total voltorb in row
	ld a, e
	sub b
	ld e, a ;load the correct row
	ld a, [de]
	add $f6
	ld [hl], a
	dec b
	ret

VFRefreshMap:
	ld de, wVoltorbFlipCardProps ;start of card properties
	ld bc, $0505 ;5x5 board
	ld hl, wTilemap ;tiles on screen
.g1x1
	push bc
	ld a, [wVoltorbFlipCursorX]
	ld b, a
	ld a, [wVoltorbFlipCursorY]
	ld c, a
	add a
	add a
	add c
	add b
	pop bc
	cp e
	ld a, [de]
	jr z, .highlighted
	res 3, a
	jr .checkflip
.highlighted
	set 3, a
.checkflip
	ld [de], a
	bit 2, a ;is the card flipped
	jp nz, .flipped
	bit 7, a ;is 0 marked?
	jp nz, .marked0
	ld a, 0 ;upper left corner blank
	ldi [hl], a
.g2x1
	push bc
	push hl
	ld bc, $0938
	add hl,bc
	xor a
	ldi [hl], a
	ld a, 6
	ldi [hl], a
	xor a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ld a, 6
	ldi [hl], a
	xor a
	ldi [hl], a
	ld a, 6
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	xor a
	ldi [hl], a
	ld a, 6
	ldi [hl], a
	xor a
	ld [hl], a	
	pop hl
	pop bc
	ld a, 1 ;upper middle blank
	ldi [hl], a	
.g3x1
	ld a, [de]
	bit 6, a ;is 1 marked?
	jp nz, .marked1
	ld a, 2 ;upper right corner blank
	ld [hl], a
.g1x2	
	push de
	ld de, $0012
	add hl, de
	pop de
	ld a, 16 ;left middle blank
	ldi [hl], a
.g2x2
	ld a, 17 ;middle blank
	ldi [hl], a
.g3x2
	ld a, 18 ;right middle blank
	ld [hl], a
.g1x3	
	push de
	ld de, $0012
	add hl, de
	pop de
	ld a, [de]
	bit 5, a ;is 2 marked?
	jp nz, .marked2
	ld a, 32 ;lower left corner blank
	ldi [hl], a
.g2x3
	ld a, 33 ;lower middle blank
	ldi [hl], a
.g3x3
	ld a, [de]
	bit 4, a ;is 3 marked?
	jp nz, .marked3
	ld a, 34 ;lower right corner blank
	ld [hl], a
.carddone
	ld a, [de]
	bit 3, a
	jr nz, .highlight
.finishcard
	inc de
	dec c
	jr z, .rowdone
	push de
	ld de, $ffd9
	add hl, de
	pop de
	jp .g1x1
.highlight
	push bc
	push de
	push hl
	ld b, 3
	ld de, $90f
	add hl, de
	ld de, $11
.highlightloopa
	ld c, 3
.highlightloopb
	ld a, [hl]
	inc a
	ldi [hl], a
	dec c
	jr nz, .highlightloopb
	add hl, de
	dec b
	jr nz, .highlightloopa
	pop hl
	pop de
	pop bc
	jr .finishcard
.rowdone
	dec b
	jr z, .done
	ld c, 5
	push de
	ld de, $0006
	add hl, de
	pop de
	jp .g1x1
.done
	hlcoord 15, 16
	ld de, .blank
	call PlaceString
	inc hl
	ld de, wVoltorbFlipRoundCoins ;coins this game
	ld bc, $0204
	call PrintNum
	hlcoord 15, 17
	ld de, .blank
	call PlaceString
	inc hl
	ld de, wCoins
	ld bc, $0204
	call PrintNum
	ret
.coinstring
	db "COINS@"
.blank
	db "    0@"

.flipped
	and $3
	jr z, .voltorb
	ld a, 0
	ldi [hl], a
	push bc
	push hl
	ld bc, $0938
	add hl,bc
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ldi [hl], a
	ldi [hl], a
	ld [hl], a	
	pop hl
	pop bc
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ld a, 16
	ldi [hl], a
	ld a, [de]
	and $3
	add 37
	ldi [hl], a
	ld a, 18
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ld a, 32
	ldi [hl], a
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	jp .carddone
.marked0
	ld a, 6 ;upper left corner marked
	ldi [hl], a
	jp .g2x1
.marked1
	ld a, 8 ;upper right corner marked
	ld [hl], a
	jp .g1x2
.marked2
	ld a, 22 ;lower left corner marked
	ldi [hl], a
	jp .g2x3
.marked3
	ld a, 24 ;lower right corner marked
	ld [hl], a
	jp .carddone
.voltorb
	ld a, 3
	ldi [hl], a
	dec a
	push bc
	push hl
	ld bc, $0938
	add hl,bc
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ldi [hl], a
	ldi [hl], a
	ld [hl], a	
	pop hl
	pop bc
	inc a
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ld a, 19
	ldi [hl], a
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	push de
	ld de, $0012
	add hl, de
	pop de
	ld a, 35
	ldi [hl], a
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	jp .finishcard ;a voltorb card will never have a highlighted palette

VFRefreshScreen: ;bc is the coordinates to refresh (3x3 tiles)
	push bc
	ld a, c
	ld c, 15
	call SimpleMultiply
	ld h, 0
	ld l, a
	add hl, hl
	ld a, b
	add a
	add b
	ld b, 0
	ld c, a
	add hl, hl
	add hl, bc
	pop bc
	push bc
	push hl
	ld de, wTilemap
	add hl, de
	push hl
	ld de, $9800
	ld a, c
	ld c, $18
	call SimpleMultiply
	ld h, 0
	ld l, a
	add hl, hl
	add hl, hl
	ld a, b
	add a
	add b
	ld b, 0
	ld c, a
	add hl, bc
	add hl, de
	push hl
	pop de
	ld hl, $ff41
	ld a, 1
.wait
	ld a, [hl]
	and 3
	cp 1
	jr nz, .wait
	pop hl
	push de
	ld b, 3
.loopa
	ld c, 3
.loopb
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loopb
	push bc
	ld bc, $1d
	push hl
	push de
	pop hl
	add hl, bc
	push hl
	pop de
	pop hl
	ld bc, $11
	add hl, bc
	pop bc
	dec b
	jr nz, .loopa
	pop de
	pop hl
	ld bc, wAttrmap
	add hl, bc
	ld a, 1
	ldh [rVBK], a
	ld b, 3
.loopc
	ld c, 3
.loopd
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loopd
	push bc
	ld bc, $1d
	push hl
	push de
	pop hl
	add hl, bc
	push hl
	pop de
	pop hl
	ld bc, $11
	add hl, bc
	pop bc
	dec b
	jr nz, .loopc
	xor a
	ldh [rVBK], a
	pop bc
	ret
	
VFRefreshScreen1: ;bc is the coordinates to refresh (3x3 tiles)
	push bc
	ld a, c
	ld c, 15
	call SimpleMultiply
	ld h, 0
	ld l, a
	add hl, hl
	ld a, b
	add a
	add b
	ld b, 0
	ld c, a
	add hl, hl
	add hl, bc
	pop bc
	push bc
	push hl
	ld de, wTilemap
	add hl, de
	push hl
	ld de, $9800
	ld a, c
	ld c, $18
	call SimpleMultiply
	ld h, 0
	ld l, a
	add hl, hl
	add hl, hl
	ld a, b
	add a
	add b
	ld b, 0
	ld c, a
	add hl, bc
	add hl, de
	push hl
	pop de
	pop hl
	push de
	ld b, 3
.loopa
	ld c, 3
.loopb
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loopb
	push bc
	ld bc, $1d
	push hl
	push de
	pop hl
	add hl, bc
	push hl
	pop de
	pop hl
	ld bc, $11
	add hl, bc
	pop bc
	dec b
	jr nz, .loopa
	pop de
	pop hl
	ld bc, wAttrmap
	add hl, bc
	ld a, 1
	ldh [rVBK], a
	ld b, 3
.loopc
	ld c, 3
.loopd
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loopd
	push bc
	ld bc, $1d
	push hl
	push de
	pop hl
	add hl, bc
	push hl
	pop de
	pop hl
	ld bc, $11
	add hl, bc
	pop bc
	dec b
	jr nz, .loopc
	xor a
	ldh [rVBK], a
	pop bc
	ret

VFFlipAnimation:
	push de
	ld de, 195 ;flip sound
	call WaitPlaySFX
	ld de, 3 ;first frame of the flip
.flipframe
        push de
        ld hl, wVoltorbFlipCardProps
        ld a, c
        add a
        add a
        add c
        add b
        ld e, a
        ld d, 0
        add hl, de
        ld d, h
        ld e, l
	ld a, c
	push bc
	ld c, $3C
	call SimpleMultiply
	ld h, 0
	ld l, a
	ld a, b
	add a
	add b
	ld bc, wTilemap
	add hl, bc
	ld b, 0
	ld c, a
	add hl, bc
	pop bc
	ld a, [de]
	set 3, a
	ld [de], a
	
	pop de
	ld a, 48
	add d
	ldi [hl], a
	push bc
	push af
	push hl
	ld bc, $0938
	add hl,bc
	ld a, 1
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	ld bc, $0012
	add hl, bc
	ldi [hl], a
	ldi [hl], a
	ld [hl], a
	add hl, bc
	ldi [hl], a
	ldi [hl], a
	ld [hl], a	
	pop hl
	pop af
	
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	add hl, bc
	ld a, 64
	add d
	ldi [hl], a
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	add hl, bc
	ld a, 80
	add d
	ldi [hl], a
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	pop bc
	push de
	call .finish
	pop de
	ld a, d
	add e
	ld d, a
	cp 12
	jr z, .switchdir
	cp $fd
	jp nz, .flipframe
	pop de
	ret
.switchdir
	ld de, $06fd
	jp .flipframe
.finish
	ld hl, wVoltorbFlipCursorX
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	di
	push hl
	call VFRefreshScreen
	pop hl
	ei
	call DelayFrame
	ret
VFBoom:
	call VFRefreshMap
	ld hl, wVoltorbFlipCursorX
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	di
	call VFRefreshScreen
	ei
	ld de, 91
	call WaitPlaySFX
	ld de, 157
	call WaitPlaySFX
	ld c, 240 ;4 seconds
	call DelayFrames
	ld a, [wVoltorbFlipCardsFlipped]
	and a
	jr z, .level0
.reset
	ld [wVoltorbFlipLevel], a
	call VFInitLevel
	ret
.level0
	ld a, 1
	jr .reset
	
VFMultiplyCoins:
	push bc
	push de
	push hl
	push af
	ld a, [wVoltorbFlipRoundCoins]
	ld d, a
	ld a, [wVoltorbFlipRoundCoins + 1]
	ld e, a
	pop af
	cp 2
	jr z, .coinsound
	cp 3
	jr z, .coinsound
.resume
	push af
	ld b, a
	ld hl, 0
	and a
	jr z, .doneadd
.keepadd
	add hl, de
	dec b
	jr nz, .keepadd
.doneadd
	ld a, h
	cp $27
	jr nc, .maybecap
	ld d, l
	or d
	jr z, .initcoins
	pop af
.updatecoins
	ld a, h
	ld [wVoltorbFlipRoundCoins], a
	ld a, l
	ld [wVoltorbFlipRoundCoins + 1], a
	call VFRefreshMap
	push bc
	ld bc, $505
	di
	call VFRefreshScreen
	ld bc, $605
	call VFRefreshScreen
	ei
	pop bc
	pop hl
	pop de
	pop bc
	ret
.initcoins
	pop af
	ld h, 0
	ld l, a
	jr .updatecoins
.coinsound
	push de
	ld de, 34
	call WaitPlaySFX
	pop de
	jr .resume
.maybecap
	cp $27
	jr nz, .capcoins
	ld a, l
	cp $f
	jr nc, .capcoins
	pop af
	jr .updatecoins
.capcoins
	pop af
	ld hl, $270f
	jr .updatecoins

VFKeepCoins:
	ld de, 159 ;level clear
	call WaitPlaySFX
	ld c, 120 ;2 seconds
	call DelayFrames
	ld a, [wVoltorbFlipCardsFlipped]
	and a
	jr z, .fixlevel
.setlevel
	ld [wVoltorbFlipLevel], a
	ld de, 34
	call WaitPlaySFX
	ld hl, wVoltorbFlipRoundCoins
	ld a, [hli]
	ld d, a
	ld a, [hld]
	ld e, a
	push hl
	ld a, [wCoins]
	ld h, a
	ld a, [wCoins + 1]
	ld l, a
	add hl, de
	push hl
	pop de
	pop hl
	ld a, d
	cp $27
	jr nc, .maybecap
.totalcoins
	ld a, d
	ld [wCoins], a
	ld a, e
	ld [wCoins + 1], a
	call VFInitLevel
	ret	
.maybecap
	cp $27
	jr nz, .capcoins
	ld a, e
	cp $f
	jr nc, .capcoins
	jr .totalcoins
.capcoins
	ld de, $270f
	jr .totalcoins
.fixlevel
	inc a
	jr .setlevel
VFExit:
	call VFKeepCoins
	ld a, 1
	ld [hBGMapMode], a
	ld a, $f
	ldh [rIE], a
	xor a
	ld [hOAMUpdate], a ;enable sprite update
	pop af
	ret
