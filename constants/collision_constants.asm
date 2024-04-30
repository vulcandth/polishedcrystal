; collision permissions (see data/collision/collision_permissions.asm)
DEF LAND_TILE  EQU %00 ; 'and a' checks
DEF WATER_TILE EQU %01 ; 'dec a' checks
DEF WALL_TILE  EQU %10

; collision data types (see data/tilesets/*_collision.asm)
; CollisionPermissionTable indexes (see data/collision/collision_permissions.asm)
DEF COLL_FLOOR             EQU $00
DEF COLL_VOID              EQU $01
DEF COLL_COAST_SAND        EQU $02
DEF COLL_WALL              EQU $07
DEF COLL_LONG_GRASS        EQU $14
DEF COLL_HEADBUTT_TREE     EQU $15
DEF COLL_TALL_GRASS        EQU $18
DEF COLL_OVERHEAD          EQU $1c
DEF COLL_ICE               EQU $23
DEF COLL_WHIRLPOOL         EQU $24
DEF COLL_BUOY              EQU $27
DEF COLL_WATER             EQU $29
DEF COLL_WATERFALL         EQU $33
DEF COLL_CURRENT_RIGHT     EQU $38
DEF COLL_CURRENT_LEFT      EQU $39
DEF COLL_CURRENT_UP        EQU $3a
DEF COLL_CURRENT_DOWN      EQU $3b
DEF COLL_HOLE              EQU $60
DEF COLL_WARP_CARPET_DOWN  EQU $70
DEF COLL_DOOR              EQU $71
DEF COLL_LADDER            EQU $72
DEF COLL_AWNING            EQU $73
DEF COLL_WARP_CARPET_LEFT  EQU $76
DEF COLL_WARP_CARPET_UP    EQU $78
DEF COLL_STAIRCASE         EQU $7a
DEF COLL_CAVE              EQU $7b
DEF COLL_WARP_PANEL        EQU $7c
DEF COLL_WARP_CARPET_RIGHT EQU $7e
DEF COLL_STOP_SPIN         EQU $80
DEF COLL_SPIN_UP           EQU $81
DEF COLL_SPIN_DOWN         EQU $82
DEF COLL_SPIN_LEFT         EQU $83
DEF COLL_SPIN_RIGHT        EQU $84
DEF COLL_PUDDLE            EQU $85
DEF COLL_COUNTER           EQU $90
DEF COLL_BOOKSHELF         EQU $91
DEF COLL_TRASH_CAN         EQU $92
DEF COLL_PC                EQU $93
DEF COLL_RADIO             EQU $94
DEF COLL_TOWN_MAP          EQU $95
DEF COLL_MART_SHELF        EQU $96
DEF COLL_TV                EQU $97
DEF COLL_POKECENTER_SIGN   EQU $98
DEF COLL_MART_SIGN         EQU $99
DEF COLL_VENDING_MACHINE   EQU $9a
DEF COLL_FRIDGE            EQU $9b
DEF COLL_SINK              EQU $9c
DEF COLL_WINDOW            EQU $9d
DEF COLL_STOVE             EQU $9e
DEF COLL_INCENSE           EQU $9f
DEF COLL_LEDGE_RIGHT       EQU $a0
DEF COLL_LEDGE_LEFT        EQU $a1
DEF COLL_LEDGE_UP          EQU $a2
DEF COLL_LEDGE_DOWN        EQU $a3
DEF COLL_LEDGE_DOWN_RIGHT  EQU $a4
DEF COLL_LEDGE_DOWN_LEFT   EQU $a5
DEF COLL_LEDGE_UP_RIGHT    EQU $a6
DEF COLL_LEDGE_UP_LEFT     EQU $a7
DEF COLL_RIGHT_WALL        EQU $b0
DEF COLL_LEFT_WALL         EQU $b1
DEF COLL_TOP_WALL          EQU $b2
DEF COLL_BOTTOM_WALL       EQU $b3
DEF COLL_BOTTOM_RIGHT_WALL EQU $b4
DEF COLL_BOTTOM_LEFT_WALL  EQU $b5
DEF COLL_TOP_RIGHT_WALL    EQU $b6
DEF COLL_TOP_LEFT_WALL     EQU $b7
DEF COLL_STAIRS_RIGHT_DOWN EQU $c0
DEF COLL_STAIRS_LEFT_DOWN  EQU $c1
DEF COLL_STAIRS_RIGHT_UP   EQU $c2
DEF COLL_STAIRS_LEFT_UP    EQU $c3
DEF COLL_CHERRY_LEAVES     EQU $d0
DEF COLL_ELEVATOR_BUTTON   EQU $d1

; collision data type nybbles
DEF HI_NYBBLE_WATER           EQU $20
DEF HI_NYBBLE_CURRENT         EQU $30
DEF HI_NYBBLE_WARPS           EQU $70
DEF HI_NYBBLE_LEDGES          EQU $a0
DEF HI_NYBBLE_SIDE_WALLS      EQU $b0
DEF HI_NYBBLE_SIDEWAYS_STAIRS EQU $c0
