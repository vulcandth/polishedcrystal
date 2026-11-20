SECTION "Tileset Headers", ROMX

MACRO tileset
	dbas \1Meta, \1Coll, \1Attr
	dba \1GFX0, \1GFX1, \1GFX2
	fardw \1Anim
ENDM

Tilesets::
; entries correspond to TILESET_* constants (see constants/tileset_constants.asm)
	table_width TILESET_LENGTH
	farbank _AnimateTileset
	tileset TilesetJohtoTraditional
	tileset TilesetJohtoModern
	tileset TilesetJohtoCoast
	tileset TilesetJohtoOutlands
	tileset TilesetJohtoAncient
	tileset TilesetJohtoSacred
	tileset TilesetBattleTowerOutside
	tileset TilesetSnowtopMountain
	tileset TilesetKanto
	tileset TilesetKantoNorth
	tileset TilesetKantoUrban
	tileset TilesetIndigoPlateau
	tileset TilesetShamoutiIsland
	tileset TilesetValenciaIsland
	tileset TilesetFarawayIsland
	tileset TilesetJohtoHouse
	tileset TilesetKantoHouse
	tileset TilesetTraditionalHouse
	tileset TilesetPokeCenter
	tileset TilesetPokeComCenter
	tileset TilesetMart
	tileset TilesetGate
	tileset TilesetGym
	tileset TilesetMagnetTrain
	tileset TilesetChampionsRoom
	tileset TilesetPort
	tileset TilesetLab
	tileset TilesetFacility
	tileset TilesetMansion
	tileset TilesetGameCorner
	tileset TilesetDecor
	tileset TilesetMuseum
	tileset TilesetHotel
	tileset TilesetTower
	tileset TilesetBattleTowerInside
	tileset TilesetRadioTower
	tileset TilesetLighthouse
	tileset TilesetUnderground
	tileset TilesetCave
	tileset TilesetQuietCave
	tileset TilesetVolcano
	tileset TilesetIcePath
	tileset TilesetTunnel
	tileset TilesetForest
	tileset TilesetPark
	tileset TilesetSafariZone
	tileset TilesetRuinsOfAlph
	tileset TilesetPokemonMansion
	tileset TilesetBattleFactory
	tileset TilesetHiddenGrotto
	tileset TilesetPeaks
	tileset TilesetHideout
	tileset TilesetKantoGym
	assert_table_length NUM_TILESETS


SECTION "Tileset Graphics - johto common vram0", ROMX

TilesetJohtoTraditionalGFX0::
TilesetJohtoModernGFX0::
TilesetJohtoCoastGFX0::
TilesetJohtoOutlandsGFX0::
TilesetJohtoAncientGFX0::
TilesetJohtoSacredGFX0::
TilesetBattleTowerOutsideGFX0:: INCBIN "gfx/tilesets/johto_common.2bpp.lzp"


SECTION "Tileset Graphics - johto traditional vram1", ROMX

TilesetJohtoTraditionalGFX1::
TilesetJohtoSacredGFX1:: INCBIN "gfx/tilesets/johto_traditional.johto_common.2bpp.vram0.lzp"


SECTION "Tileset Graphics - johto traditional vram2", ROMX

TilesetJohtoTraditionalGFX2::
TilesetJohtoSacredGFX2:: INCBIN "gfx/tilesets/johto_traditional.johto_common.2bpp.vram1.lzp"


SECTION "Tileset Data - johto traditional", ROMX

TilesetJohtoTraditionalMeta:: INCBIN "data/tilesets/johto_traditional_metatiles.bin.tlz"
TilesetJohtoTraditionalAttr:: INCBIN "data/tilesets/johto_traditional_attributes.bin.tlz"
TilesetJohtoTraditionalColl:: INCBIN "data/tilesets/johto_traditional_collision.bin.lzp"


SECTION "Tileset Graphics - johto modern vram1", ROMX

TilesetJohtoModernGFX1::
TilesetJohtoCoastGFX1:: INCBIN "gfx/tilesets/johto_modern.johto_common.2bpp.vram0.lzp"


SECTION "Tileset Graphics - johto modern vram2", ROMX

TilesetJohtoModernGFX2::
TilesetJohtoCoastGFX2:: INCBIN "gfx/tilesets/johto_modern.johto_common.2bpp.vram1.lzp"


SECTION "Tileset Data - johto modern", ROMX

TilesetJohtoModernMeta:: INCBIN "data/tilesets/johto_modern_metatiles.bin.tlz"
TilesetJohtoModernAttr:: INCBIN "data/tilesets/johto_modern_attributes.bin.tlz"
TilesetJohtoModernColl:: INCBIN "data/tilesets/johto_modern_collision.bin.lzp"


SECTION "Tileset Data - johto coast", ROMX

TilesetJohtoCoastMeta:: INCBIN "data/tilesets/johto_coast_metatiles.bin.tlz"
TilesetJohtoCoastAttr:: INCBIN "data/tilesets/johto_coast_attributes.bin.tlz"
TilesetJohtoCoastColl:: INCBIN "data/tilesets/johto_coast_collision.bin.lzp"


SECTION "Tileset Graphics - johto outlands vram1", ROMX

TilesetJohtoOutlandsGFX1:: INCBIN "gfx/tilesets/johto_outlands.johto_common.2bpp.vram0.lzp"


SECTION "Tileset Graphics - johto outlands vram2", ROMX

TilesetJohtoOutlandsGFX2:: INCBIN "gfx/tilesets/johto_outlands.johto_common.2bpp.vram1.lzp"


SECTION "Tileset Data - johto outlands", ROMX

TilesetJohtoOutlandsMeta:: INCBIN "data/tilesets/johto_outlands_metatiles.bin.tlz"
TilesetJohtoOutlandsAttr:: INCBIN "data/tilesets/johto_outlands_attributes.bin.tlz"
TilesetJohtoOutlandsColl:: INCBIN "data/tilesets/johto_outlands_collision.bin.lzp"


SECTION "Tileset Graphics - johto ancient vram1", ROMX

TilesetJohtoAncientGFX1:: INCBIN "gfx/tilesets/johto_ancient.johto_common.2bpp.vram0.lzp"


SECTION "Tileset Data - johto ancient", ROMX

TilesetJohtoAncientMeta:: INCBIN "data/tilesets/johto_ancient_metatiles.bin.tlz"
TilesetJohtoAncientAttr:: INCBIN "data/tilesets/johto_ancient_attributes.bin.tlz"
TilesetJohtoAncientColl:: INCBIN "data/tilesets/johto_ancient_collision.bin.lzp"


SECTION "Tileset Data - johto sacred", ROMX

TilesetJohtoSacredMeta:: INCBIN "data/tilesets/johto_sacred_metatiles.bin.tlz"
TilesetJohtoSacredAttr:: INCBIN "data/tilesets/johto_sacred_attributes.bin.tlz"
TilesetJohtoSacredColl:: INCBIN "data/tilesets/johto_sacred_collision.bin.lzp"


SECTION "Tileset Graphics - battle tower outside vram1", ROMX

TilesetBattleTowerOutsideGFX1:: INCBIN "gfx/tilesets/battle_tower_outside.johto_common.2bpp.lzp"


SECTION "Tileset Data - battle tower outside", ROMX

TilesetBattleTowerOutsideMeta:: INCBIN "data/tilesets/battle_tower_outside_metatiles.bin.tlz"
TilesetBattleTowerOutsideAttr:: INCBIN "data/tilesets/battle_tower_outside_attributes.bin.tlz"
TilesetBattleTowerOutsideColl:: INCBIN "data/tilesets/battle_tower_outside_collision.bin.lzp"


SECTION "Tileset Graphics - kanto common vram0", ROMX

TilesetKantoGFX0::
TilesetKantoNorthGFX0::
TilesetKantoUrbanGFX0::
TilesetIndigoPlateauGFX0:: INCBIN "gfx/tilesets/kanto_common.2bpp.lzp"


SECTION "Tileset Graphics - kanto vram1", ROMX

TilesetKantoGFX1:: INCBIN "gfx/tilesets/kanto.kanto_common.2bpp.lzp"


SECTION "Tileset Data - kanto", ROMX

TilesetKantoMeta:: INCBIN "data/tilesets/kanto_metatiles.bin.tlz"
TilesetKantoAttr:: INCBIN "data/tilesets/kanto_attributes.bin.tlz"
TilesetKantoColl:: INCBIN "data/tilesets/kanto_collision.bin.lzp"


SECTION "Tileset Graphics - kanto north vram1", ROMX

TilesetKantoNorthGFX1:: INCBIN "gfx/tilesets/kanto_north.kanto_common.2bpp.lzp"


SECTION "Tileset Data - kanto north", ROMX

TilesetKantoNorthMeta:: INCBIN "data/tilesets/kanto_north_metatiles.bin.tlz"
TilesetKantoNorthAttr:: INCBIN "data/tilesets/kanto_north_attributes.bin.tlz"
TilesetKantoNorthColl:: INCBIN "data/tilesets/kanto_north_collision.bin.lzp"


SECTION "Tileset Graphics - kanto urban vram1", ROMX

TilesetKantoUrbanGFX1:: INCBIN "gfx/tilesets/kanto_urban.kanto_common.2bpp.lzp"


SECTION "Tileset Data - kanto urban", ROMX

TilesetKantoUrbanMeta:: INCBIN "data/tilesets/kanto_urban_metatiles.bin.tlz"
TilesetKantoUrbanAttr:: INCBIN "data/tilesets/kanto_urban_attributes.bin.tlz"
TilesetKantoUrbanColl:: INCBIN "data/tilesets/kanto_urban_collision.bin.lzp"


SECTION "Tileset Graphics - indigo plateau vram1", ROMX

TilesetIndigoPlateauGFX1:: INCBIN "gfx/tilesets/indigo_plateau.kanto_common.2bpp.lzp"


SECTION "Tileset Data - indigo plateau", ROMX

TilesetIndigoPlateauMeta:: INCBIN "data/tilesets/indigo_plateau_metatiles.bin.tlz"
TilesetIndigoPlateauAttr:: INCBIN "data/tilesets/indigo_plateau_attributes.bin.tlz"
TilesetIndigoPlateauColl:: INCBIN "data/tilesets/indigo_plateau_collision.bin.lzp"


SECTION "Tileset Graphics - shamouti island vram0", ROMX

TilesetShamoutiIslandGFX0:: INCBIN "gfx/tilesets/shamouti_island.2bpp.vram0.lzp"


SECTION "Tileset Graphics - shamouti island vram1", ROMX

TilesetShamoutiIslandGFX1:: INCBIN "gfx/tilesets/shamouti_island.2bpp.vram1.lzp"


SECTION "Tileset Data - shamouti island", ROMX

TilesetShamoutiIslandMeta:: INCBIN "data/tilesets/shamouti_island_metatiles.bin.tlz"
TilesetShamoutiIslandAttr:: INCBIN "data/tilesets/shamouti_island_attributes.bin.tlz"
TilesetShamoutiIslandColl:: INCBIN "data/tilesets/shamouti_island_collision.bin.lzp"


SECTION "Tileset Graphics - valencia island vram0", ROMX

TilesetValenciaIslandGFX0:: INCBIN "gfx/tilesets/valencia_island.2bpp.vram0.lzp"


SECTION "Tileset Graphics - valencia island vram1", ROMX

TilesetValenciaIslandGFX1:: INCBIN "gfx/tilesets/valencia_island.2bpp.vram1.lzp"


SECTION "Tileset Data - valencia island", ROMX

TilesetValenciaIslandMeta:: INCBIN "data/tilesets/valencia_island_metatiles.bin.tlz"
TilesetValenciaIslandAttr:: INCBIN "data/tilesets/valencia_island_attributes.bin.tlz"
TilesetValenciaIslandColl:: INCBIN "data/tilesets/valencia_island_collision.bin.lzp"


SECTION "Tileset Graphics - faraway island vram0", ROMX

TilesetFarawayIslandGFX0:: INCBIN "gfx/tilesets/faraway_island.2bpp.vram0.lzp"


SECTION "Tileset Graphics - faraway island vram1", ROMX

TilesetFarawayIslandGFX1:: INCBIN "gfx/tilesets/faraway_island.2bpp.vram1.lzp"


SECTION "Tileset Data - faraway island", ROMX

TilesetFarawayIslandMeta:: INCBIN "data/tilesets/faraway_island_metatiles.bin.tlz"
TilesetFarawayIslandAttr:: INCBIN "data/tilesets/faraway_island_attributes.bin.tlz"
TilesetFarawayIslandColl:: INCBIN "data/tilesets/faraway_island_collision.bin.lzp"


SECTION "Tileset Graphics - johto house vram0", ROMX

TilesetJohtoHouseGFX0:: INCBIN "gfx/tilesets/johto_house.2bpp.vram0.lzp"


SECTION "Tileset Graphics - johto house vram1", ROMX

TilesetJohtoHouseGFX1:: INCBIN "gfx/tilesets/johto_house.2bpp.vram1.lzp"


SECTION "Tileset Data - johto house", ROMX

TilesetJohtoHouseMeta:: INCBIN "data/tilesets/johto_house_metatiles.bin.tlz"
TilesetJohtoHouseAttr:: INCBIN "data/tilesets/johto_house_attributes.bin.tlz"
TilesetJohtoHouseColl:: INCBIN "data/tilesets/johto_house_collision.bin.lzp"


SECTION "Tileset Graphics - kanto house vram0", ROMX

TilesetKantoHouseGFX0:: INCBIN "gfx/tilesets/kanto_house.2bpp.vram0.lzp"


SECTION "Tileset Graphics - kanto house vram1", ROMX

TilesetKantoHouseGFX1:: INCBIN "gfx/tilesets/kanto_house.2bpp.vram1.lzp"


SECTION "Tileset Data - kanto house", ROMX

TilesetKantoHouseMeta:: INCBIN "data/tilesets/kanto_house_metatiles.bin.tlz"
TilesetKantoHouseAttr:: INCBIN "data/tilesets/kanto_house_attributes.bin.tlz"
TilesetKantoHouseColl:: INCBIN "data/tilesets/kanto_house_collision.bin.lzp"


SECTION "Tileset Graphics - traditional house vram0", ROMX

TilesetTraditionalHouseGFX0:: INCBIN "gfx/tilesets/traditional_house.2bpp.vram0.lzp"


SECTION "Tileset Graphics - traditional house vram1", ROMX

TilesetTraditionalHouseGFX1:: INCBIN "gfx/tilesets/traditional_house.2bpp.vram1.lzp"


SECTION "Tileset Data - traditional house", ROMX

TilesetTraditionalHouseMeta:: INCBIN "data/tilesets/traditional_house_metatiles.bin.tlz"
TilesetTraditionalHouseAttr:: INCBIN "data/tilesets/traditional_house_attributes.bin.tlz"
TilesetTraditionalHouseColl:: INCBIN "data/tilesets/traditional_house_collision.bin.lzp"


SECTION "Tileset Graphics - pokecenter vram0", ROMX

TilesetPokeCenterGFX0:: INCBIN "gfx/tilesets/pokecenter.2bpp.vram0.lzp"


SECTION "Tileset Graphics - pokecenter vram1", ROMX

TilesetPokeCenterGFX1:: INCBIN "gfx/tilesets/pokecenter.2bpp.vram1.lzp"


SECTION "Tileset Data - pokecenter", ROMX

TilesetPokeCenterMeta:: INCBIN "data/tilesets/pokecenter_metatiles.bin.tlz"
TilesetPokeCenterAttr:: INCBIN "data/tilesets/pokecenter_attributes.bin.tlz"
TilesetPokeCenterColl:: INCBIN "data/tilesets/pokecenter_collision.bin.lzp"


SECTION "Tileset Graphics - pokecom center vram0", ROMX

TilesetPokeComCenterGFX0:: INCBIN "gfx/tilesets/pokecom_center.2bpp.vram0.lzp"


SECTION "Tileset Graphics - pokecom center vram1", ROMX

TilesetPokeComCenterGFX1:: INCBIN "gfx/tilesets/pokecom_center.2bpp.vram1.lzp"


SECTION "Tileset Data - pokecom center", ROMX

TilesetPokeComCenterMeta:: INCBIN "data/tilesets/pokecom_center_metatiles.bin.tlz"
TilesetPokeComCenterAttr:: INCBIN "data/tilesets/pokecom_center_attributes.bin.tlz"
TilesetPokeComCenterColl:: INCBIN "data/tilesets/pokecom_center_collision.bin.lzp"


SECTION "Tileset Graphics - mart vram0", ROMX

TilesetMartGFX0:: INCBIN "gfx/tilesets/mart.2bpp.vram0.lzp"


SECTION "Tileset Graphics - mart vram1", ROMX

TilesetMartGFX1:: INCBIN "gfx/tilesets/mart.2bpp.vram1.lzp"


SECTION "Tileset Data - mart", ROMX

TilesetMartMeta:: INCBIN "data/tilesets/mart_metatiles.bin.tlz"
TilesetMartAttr:: INCBIN "data/tilesets/mart_attributes.bin.tlz"
TilesetMartColl:: INCBIN "data/tilesets/mart_collision.bin.lzp"


SECTION "Tileset Graphics - gate vram0", ROMX

TilesetGateGFX0:: INCBIN "gfx/tilesets/gate.2bpp.vram0.lzp"


SECTION "Tileset Graphics - gate vram1", ROMX

TilesetGateGFX1:: INCBIN "gfx/tilesets/gate.2bpp.vram1.lzp"


SECTION "Tileset Data - gate", ROMX

TilesetGateMeta:: INCBIN "data/tilesets/gate_metatiles.bin.tlz"
TilesetGateAttr:: INCBIN "data/tilesets/gate_attributes.bin.tlz"
TilesetGateColl:: INCBIN "data/tilesets/gate_collision.bin.lzp"


SECTION "Tileset Graphics - gym vram0", ROMX

TilesetGymGFX0:: INCBIN "gfx/tilesets/gym.2bpp.vram0.lzp"


SECTION "Tileset Graphics - gym vram1", ROMX

TilesetGymGFX1:: INCBIN "gfx/tilesets/gym.2bpp.vram1.lzp"


SECTION "Tileset Graphics - gym vram2", ROMX

TilesetGymGFX2:: INCBIN "gfx/tilesets/gym.2bpp.vram2.lzp"


SECTION "Tileset Data - gym", ROMX

TilesetGymMeta:: INCBIN "data/tilesets/gym_metatiles.bin.tlz"
TilesetGymAttr:: INCBIN "data/tilesets/gym_attributes.bin.tlz"
TilesetGymColl:: INCBIN "data/tilesets/gym_collision.bin.lzp"


SECTION "Tileset Graphics - magnet train vram0", ROMX

TilesetMagnetTrainGFX0:: INCBIN "gfx/tilesets/magnet_train.2bpp.vram0.lzp"


SECTION "Tileset Graphics - magnet train vram1", ROMX

TilesetMagnetTrainGFX1:: INCBIN "gfx/tilesets/magnet_train.2bpp.vram1.lzp"


SECTION "Tileset Data - magnet train", ROMX

TilesetMagnetTrainMeta:: INCBIN "data/tilesets/magnet_train_metatiles.bin.tlz"
TilesetMagnetTrainAttr:: INCBIN "data/tilesets/magnet_train_attributes.bin.tlz"
TilesetMagnetTrainColl:: INCBIN "data/tilesets/magnet_train_collision.bin.lzp"


SECTION "Tileset Graphics - champions room vram0", ROMX

TilesetChampionsRoomGFX0:: INCBIN "gfx/tilesets/champions_room.2bpp.vram0.lzp"


SECTION "Tileset Graphics - champions room vram1", ROMX

TilesetChampionsRoomGFX1:: INCBIN "gfx/tilesets/champions_room.2bpp.vram1.lzp"


SECTION "Tileset Data - champions room", ROMX

TilesetChampionsRoomMeta:: INCBIN "data/tilesets/champions_room_metatiles.bin.tlz"
TilesetChampionsRoomAttr:: INCBIN "data/tilesets/champions_room_attributes.bin.tlz"
TilesetChampionsRoomColl:: INCBIN "data/tilesets/champions_room_collision.bin.lzp"


SECTION "Tileset Graphics - port vram0", ROMX

TilesetPortGFX0:: INCBIN "gfx/tilesets/port.2bpp.vram0.lzp"


SECTION "Tileset Graphics - port vram1", ROMX

TilesetPortGFX1:: INCBIN "gfx/tilesets/port.2bpp.vram1.lzp"


SECTION "Tileset Data - port", ROMX

TilesetPortMeta:: INCBIN "data/tilesets/port_metatiles.bin.tlz"
TilesetPortAttr:: INCBIN "data/tilesets/port_attributes.bin.tlz"
TilesetPortColl:: INCBIN "data/tilesets/port_collision.bin.lzp"


SECTION "Tileset Graphics - lab vram0", ROMX

TilesetLabGFX0:: INCBIN "gfx/tilesets/lab.2bpp.vram0.lzp"


SECTION "Tileset Graphics - lab vram1", ROMX

TilesetLabGFX1:: INCBIN "gfx/tilesets/lab.2bpp.vram1.lzp"


SECTION "Tileset Data - lab", ROMX

TilesetLabMeta:: INCBIN "data/tilesets/lab_metatiles.bin.tlz"
TilesetLabAttr:: INCBIN "data/tilesets/lab_attributes.bin.tlz"
TilesetLabColl:: INCBIN "data/tilesets/lab_collision.bin.lzp"


SECTION "Tileset Graphics - facility vram0", ROMX

TilesetFacilityGFX0:: INCBIN "gfx/tilesets/facility.2bpp.vram0.lzp"


SECTION "Tileset Graphics - facility vram1", ROMX

TilesetFacilityGFX1:: INCBIN "gfx/tilesets/facility.2bpp.vram1.lzp"


SECTION "Tileset Data - facility", ROMX

TilesetFacilityMeta:: INCBIN "data/tilesets/facility_metatiles.bin.tlz"
TilesetFacilityAttr:: INCBIN "data/tilesets/facility_attributes.bin.tlz"
TilesetFacilityColl:: INCBIN "data/tilesets/facility_collision.bin.lzp"


SECTION "Tileset Graphics - celadon mansion vram0", ROMX

TilesetMansionGFX0:: INCBIN "gfx/tilesets/celadon_mansion.2bpp.vram0.lzp"


SECTION "Tileset Graphics - celadon mansion vram1", ROMX

TilesetMansionGFX1:: INCBIN "gfx/tilesets/celadon_mansion.2bpp.vram1.lzp"


SECTION "Tileset Data - celadon mansion", ROMX

TilesetMansionMeta:: INCBIN "data/tilesets/celadon_mansion_metatiles.bin.tlz"
TilesetMansionAttr:: INCBIN "data/tilesets/celadon_mansion_attributes.bin.tlz"
TilesetMansionColl:: INCBIN "data/tilesets/celadon_mansion_collision.bin.lzp"


SECTION "Tileset Graphics - game corner vram0", ROMX

TilesetGameCornerGFX0:: INCBIN "gfx/tilesets/game_corner.2bpp.vram0.lzp"


SECTION "Tileset Graphics - game corner vram1", ROMX

TilesetGameCornerGFX1:: INCBIN "gfx/tilesets/game_corner.2bpp.vram1.lzp"


SECTION "Tileset Data - game corner", ROMX

TilesetGameCornerMeta:: INCBIN "data/tilesets/game_corner_metatiles.bin.tlz"
TilesetGameCornerAttr:: INCBIN "data/tilesets/game_corner_attributes.bin.tlz"
TilesetGameCornerColl:: INCBIN "data/tilesets/game_corner_collision.bin.lzp"


SECTION "Tileset Graphics - home decor store vram0", ROMX

TilesetDecorGFX0:: INCBIN "gfx/tilesets/home_decor_store.2bpp.vram0.lzp"


SECTION "Tileset Graphics - home decor store vram1", ROMX

TilesetDecorGFX1:: INCBIN "gfx/tilesets/home_decor_store.2bpp.vram1.lzp"


SECTION "Tileset Data - home decor store", ROMX

TilesetDecorMeta:: INCBIN "data/tilesets/home_decor_store_metatiles.bin.tlz"
TilesetDecorAttr:: INCBIN "data/tilesets/home_decor_store_attributes.bin.tlz"
TilesetDecorColl:: INCBIN "data/tilesets/home_decor_store_collision.bin.lzp"


SECTION "Tileset Graphics - museum vram0", ROMX

TilesetMuseumGFX0:: INCBIN "gfx/tilesets/museum.2bpp.vram0.lzp"


SECTION "Tileset Graphics - museum vram1", ROMX

TilesetMuseumGFX1:: INCBIN "gfx/tilesets/museum.2bpp.vram1.lzp"


SECTION "Tileset Graphics - museum vram2", ROMX

TilesetMuseumGFX2:: INCBIN "gfx/tilesets/museum.2bpp.vram2.lzp"


SECTION "Tileset Data - museum", ROMX

TilesetMuseumMeta:: INCBIN "data/tilesets/museum_metatiles.bin.tlz"
TilesetMuseumAttr:: INCBIN "data/tilesets/museum_attributes.bin.tlz"
TilesetMuseumColl:: INCBIN "data/tilesets/museum_collision.bin.lzp"


SECTION "Tileset Graphics - hotel vram0", ROMX

TilesetHotelGFX0:: INCBIN "gfx/tilesets/hotel.2bpp.vram0.lzp"


SECTION "Tileset Graphics - hotel vram1", ROMX

TilesetHotelGFX1:: INCBIN "gfx/tilesets/hotel.2bpp.vram1.lzp"


SECTION "Tileset Data - hotel", ROMX

TilesetHotelMeta:: INCBIN "data/tilesets/hotel_metatiles.bin.tlz"
TilesetHotelAttr:: INCBIN "data/tilesets/hotel_attributes.bin.tlz"
TilesetHotelColl:: INCBIN "data/tilesets/hotel_collision.bin.lzp"


SECTION "Tileset Graphics - sprout tower vram0", ROMX

TilesetTowerGFX0:: INCBIN "gfx/tilesets/sprout_tower.2bpp.vram0.lzp"


SECTION "Tileset Graphics - sprout tower vram1", ROMX

TilesetTowerGFX1:: INCBIN "gfx/tilesets/sprout_tower.2bpp.vram1.lzp"


SECTION "Tileset Data - sprout tower", ROMX

TilesetTowerMeta:: INCBIN "data/tilesets/sprout_tower_metatiles.bin.tlz"
TilesetTowerAttr:: INCBIN "data/tilesets/sprout_tower_attributes.bin.tlz"
TilesetTowerColl:: INCBIN "data/tilesets/sprout_tower_collision.bin.lzp"


SECTION "Tileset Graphics - battle tower inside vram0", ROMX

TilesetBattleTowerInsideGFX0:: INCBIN "gfx/tilesets/battle_tower_inside.2bpp.vram0.lzp"


SECTION "Tileset Graphics - battle tower inside vram1", ROMX

TilesetBattleTowerInsideGFX1:: INCBIN "gfx/tilesets/battle_tower_inside.2bpp.vram1.lzp"


SECTION "Tileset Data - battle tower inside", ROMX

TilesetBattleTowerInsideMeta:: INCBIN "data/tilesets/battle_tower_inside_metatiles.bin.tlz"
TilesetBattleTowerInsideAttr:: INCBIN "data/tilesets/battle_tower_inside_attributes.bin.tlz"
TilesetBattleTowerInsideColl:: INCBIN "data/tilesets/battle_tower_inside_collision.bin.lzp"


SECTION "Tileset Graphics - radio tower vram0", ROMX

TilesetRadioTowerGFX0:: INCBIN "gfx/tilesets/radio_tower.2bpp.vram0.lzp"


SECTION "Tileset Graphics - radio tower vram1", ROMX

TilesetRadioTowerGFX1:: INCBIN "gfx/tilesets/radio_tower.2bpp.vram1.lzp"


SECTION "Tileset Data - radio tower", ROMX

TilesetRadioTowerMeta:: INCBIN "data/tilesets/radio_tower_metatiles.bin.tlz"
TilesetRadioTowerAttr:: INCBIN "data/tilesets/radio_tower_attributes.bin.tlz"
TilesetRadioTowerColl:: INCBIN "data/tilesets/radio_tower_collision.bin.lzp"


SECTION "Tileset Graphics - lighthouse vram0", ROMX

TilesetLighthouseGFX0:: INCBIN "gfx/tilesets/lighthouse.2bpp.vram0.lzp"


SECTION "Tileset Graphics - lighthouse vram1", ROMX

TilesetLighthouseGFX1:: INCBIN "gfx/tilesets/lighthouse.2bpp.vram1.lzp"


SECTION "Tileset Data - lighthouse", ROMX

TilesetLighthouseMeta:: INCBIN "data/tilesets/lighthouse_metatiles.bin.tlz"
TilesetLighthouseAttr:: INCBIN "data/tilesets/lighthouse_attributes.bin.tlz"
TilesetLighthouseColl:: INCBIN "data/tilesets/lighthouse_collision.bin.lzp"


SECTION "Tileset Graphics - underground vram0", ROMX

TilesetUndergroundGFX0:: INCBIN "gfx/tilesets/underground.2bpp.vram0.lzp"


SECTION "Tileset Graphics - underground vram1", ROMX

TilesetUndergroundGFX1:: INCBIN "gfx/tilesets/underground.2bpp.vram1.lzp"


SECTION "Tileset Data - underground", ROMX

TilesetUndergroundMeta:: INCBIN "data/tilesets/underground_metatiles.bin.tlz"
TilesetUndergroundAttr:: INCBIN "data/tilesets/underground_attributes.bin.tlz"
TilesetUndergroundColl:: INCBIN "data/tilesets/underground_collision.bin.lzp"


SECTION "Tileset Graphics - cave vram0", ROMX

TilesetCaveGFX0::
TilesetVolcanoGFX0:: INCBIN "gfx/tilesets/cave.2bpp.vram0.lzp"


SECTION "Tileset Graphics - cave vram1", ROMX

TilesetCaveGFX1::
TilesetVolcanoGFX1:: INCBIN "gfx/tilesets/cave.2bpp.vram1.lzp"


SECTION "Tileset Data - cave", ROMX

TilesetCaveMeta:: INCBIN "data/tilesets/cave_metatiles.bin.tlz"
TilesetCaveAttr:: INCBIN "data/tilesets/cave_attributes.bin.tlz"
TilesetCaveColl:: INCBIN "data/tilesets/cave_collision.bin.lzp"


SECTION "Tileset Graphics - quiet cave vram0", ROMX

TilesetQuietCaveGFX0:: INCBIN "gfx/tilesets/quiet_cave.2bpp.vram0.lzp"


SECTION "Tileset Graphics - quiet cave vram1", ROMX

TilesetQuietCaveGFX1:: INCBIN "gfx/tilesets/quiet_cave.2bpp.vram1.lzp"


SECTION "Tileset Data - quiet cave", ROMX

TilesetQuietCaveMeta:: INCBIN "data/tilesets/quiet_cave_metatiles.bin.tlz"
TilesetQuietCaveAttr:: INCBIN "data/tilesets/quiet_cave_attributes.bin.tlz"
TilesetQuietCaveColl:: INCBIN "data/tilesets/quiet_cave_collision.bin.lzp"


SECTION "Tileset Data - volcano", ROMX

TilesetVolcanoMeta:: INCBIN "data/tilesets/volcano_metatiles.bin.tlz"
TilesetVolcanoAttr:: INCBIN "data/tilesets/volcano_attributes.bin.tlz"
TilesetVolcanoColl:: INCBIN "data/tilesets/volcano_collision.bin.lzp"


SECTION "Tileset Graphics - ice path vram0", ROMX

TilesetIcePathGFX0:: INCBIN "gfx/tilesets/ice_path.2bpp.vram0.lzp"


SECTION "Tileset Graphics - ice path vram1", ROMX

TilesetIcePathGFX1:: INCBIN "gfx/tilesets/ice_path.2bpp.vram1.lzp"


SECTION "Tileset Data - ice path", ROMX

TilesetIcePathMeta:: INCBIN "data/tilesets/ice_path_metatiles.bin.tlz"
TilesetIcePathAttr:: INCBIN "data/tilesets/ice_path_attributes.bin.tlz"
TilesetIcePathColl:: INCBIN "data/tilesets/ice_path_collision.bin.lzp"


SECTION "Tileset Graphics - tunnel vram0", ROMX

TilesetTunnelGFX0:: INCBIN "gfx/tilesets/tunnel.2bpp.vram0.lzp"


SECTION "Tileset Graphics - tunnel vram1", ROMX

TilesetTunnelGFX1:: INCBIN "gfx/tilesets/tunnel.2bpp.vram1.lzp"


SECTION "Tileset Data - tunnel", ROMX

TilesetTunnelMeta:: INCBIN "data/tilesets/tunnel_metatiles.bin.tlz"
TilesetTunnelAttr:: INCBIN "data/tilesets/tunnel_attributes.bin.tlz"
TilesetTunnelColl:: INCBIN "data/tilesets/tunnel_collision.bin.lzp"


SECTION "Tileset Graphics - forest vram0", ROMX

TilesetForestGFX0:: INCBIN "gfx/tilesets/forest.2bpp.vram0.lzp"


SECTION "Tileset Graphics - forest vram1", ROMX

TilesetForestGFX1:: INCBIN "gfx/tilesets/forest.2bpp.vram1.lzp"


SECTION "Tileset Data - forest", ROMX

TilesetForestMeta:: INCBIN "data/tilesets/forest_metatiles.bin.tlz"
TilesetForestAttr:: INCBIN "data/tilesets/forest_attributes.bin.tlz"
TilesetForestColl:: INCBIN "data/tilesets/forest_collision.bin.lzp"


SECTION "Tileset Graphics - park vram0", ROMX

TilesetParkGFX0:: INCBIN "gfx/tilesets/park.2bpp.vram0.lzp"


SECTION "Tileset Graphics - park vram1", ROMX

TilesetParkGFX1:: INCBIN "gfx/tilesets/park.2bpp.vram1.lzp"


SECTION "Tileset Data - park", ROMX

TilesetParkMeta:: INCBIN "data/tilesets/park_metatiles.bin.tlz"
TilesetParkAttr:: INCBIN "data/tilesets/park_attributes.bin.tlz"
TilesetParkColl:: INCBIN "data/tilesets/park_collision.bin.lzp"


SECTION "Tileset Graphics - safari zone vram0", ROMX

TilesetSafariZoneGFX0:: INCBIN "gfx/tilesets/safari_zone.2bpp.vram0.lzp"


SECTION "Tileset Graphics - safari zone vram1", ROMX

TilesetSafariZoneGFX1:: INCBIN "gfx/tilesets/safari_zone.2bpp.vram1.lzp"


SECTION "Tileset Data - safari zone", ROMX

TilesetSafariZoneMeta:: INCBIN "data/tilesets/safari_zone_metatiles.bin.tlz"
TilesetSafariZoneAttr:: INCBIN "data/tilesets/safari_zone_attributes.bin.tlz"
TilesetSafariZoneColl:: INCBIN "data/tilesets/safari_zone_collision.bin.lzp"


SECTION "Tileset Graphics - ruins of alph vram0", ROMX

TilesetRuinsOfAlphGFX0:: INCBIN "gfx/tilesets/ruins_of_alph.2bpp.vram0.lzp"


SECTION "Tileset Graphics - ruins of alph vram1", ROMX

TilesetRuinsOfAlphGFX1:: INCBIN "gfx/tilesets/ruins_of_alph.2bpp.vram1.lzp"


SECTION "Tileset Data - ruins of alph", ROMX

TilesetRuinsOfAlphMeta:: INCBIN "data/tilesets/ruins_of_alph_metatiles.bin.tlz"
TilesetRuinsOfAlphAttr:: INCBIN "data/tilesets/ruins_of_alph_attributes.bin.tlz"
TilesetRuinsOfAlphColl:: INCBIN "data/tilesets/ruins_of_alph_collision.bin.lzp"


SECTION "Tileset Graphics - pokemon mansion vram0", ROMX

TilesetPokemonMansionGFX0:: INCBIN "gfx/tilesets/pokemon_mansion.2bpp.vram0.lzp"


SECTION "Tileset Graphics - pokemon mansion vram1", ROMX

TilesetPokemonMansionGFX1:: INCBIN "gfx/tilesets/pokemon_mansion.2bpp.vram1.lzp"


SECTION "Tileset Data - pokemon mansion", ROMX

TilesetPokemonMansionMeta:: INCBIN "data/tilesets/pokemon_mansion_metatiles.bin.tlz"
TilesetPokemonMansionAttr:: INCBIN "data/tilesets/pokemon_mansion_attributes.bin.tlz"
TilesetPokemonMansionColl:: INCBIN "data/tilesets/pokemon_mansion_collision.bin.lzp"


SECTION "Tileset Graphics - battle factory vram0", ROMX

TilesetBattleFactoryGFX0:: INCBIN "gfx/tilesets/battle_factory.2bpp.vram0.lzp"


SECTION "Tileset Graphics - battle factory vram1", ROMX

TilesetBattleFactoryGFX1:: INCBIN "gfx/tilesets/battle_factory.2bpp.vram1.lzp"


SECTION "Tileset Data - battle factory", ROMX

TilesetBattleFactoryMeta:: INCBIN "data/tilesets/battle_factory_metatiles.bin.tlz"
TilesetBattleFactoryAttr:: INCBIN "data/tilesets/battle_factory_attributes.bin.tlz"
TilesetBattleFactoryColl:: INCBIN "data/tilesets/battle_factory_collision.bin.lzp"


SECTION "Tileset Graphics - snowtop mountain vram0", ROMX

TilesetSnowtopMountainGFX0:: INCBIN "gfx/tilesets/snowtop_mountain.2bpp.vram0.lzp"


SECTION "Tileset Graphics - snowtop mountain vram1", ROMX

TilesetSnowtopMountainGFX1:: INCBIN "gfx/tilesets/snowtop_mountain.2bpp.vram1.lzp"


SECTION "Tileset Data - snowtop mountain", ROMX

TilesetSnowtopMountainMeta:: INCBIN "data/tilesets/snowtop_mountain_metatiles.bin.tlz"
TilesetSnowtopMountainAttr:: INCBIN "data/tilesets/snowtop_mountain_attributes.bin.tlz"
TilesetSnowtopMountainColl:: INCBIN "data/tilesets/snowtop_mountain_collision.bin.lzp"


SECTION "Tileset Graphics - hidden grotto vram0", ROMX

TilesetHiddenGrottoGFX0:: INCBIN "gfx/tilesets/hidden_grotto.2bpp.vram0.lzp"


SECTION "Tileset Graphics - hidden grotto vram1", ROMX

TilesetHiddenGrottoGFX1:: INCBIN "gfx/tilesets/hidden_grotto.2bpp.vram1.lzp"


SECTION "Tileset Data - hidden grotto", ROMX

TilesetHiddenGrottoMeta:: INCBIN "data/tilesets/hidden_grotto_metatiles.bin.tlz"
TilesetHiddenGrottoAttr:: INCBIN "data/tilesets/hidden_grotto_attributes.bin.tlz"
TilesetHiddenGrottoColl:: INCBIN "data/tilesets/hidden_grotto_collision.bin.lzp"


SECTION "Tileset Graphics - peaks vram0", ROMX

TilesetPeaksGFX0:: INCBIN "gfx/tilesets/peaks.2bpp.vram0.lzp"


SECTION "Tileset Graphics - peaks vram1", ROMX

TilesetPeaksGFX1:: INCBIN "gfx/tilesets/peaks.2bpp.vram1.lzp"


SECTION "Tileset Data - peaks", ROMX

TilesetPeaksMeta:: INCBIN "data/tilesets/peaks_metatiles.bin.tlz"
TilesetPeaksAttr:: INCBIN "data/tilesets/peaks_attributes.bin.tlz"
TilesetPeaksColl:: INCBIN "data/tilesets/peaks_collision.bin.lzp"


SECTION "Tileset Graphics - hideout vram0", ROMX

TilesetHideoutGFX0:: INCBIN "gfx/tilesets/hideout.2bpp.vram0.lzp"


SECTION "Tileset Graphics - hideout vram1", ROMX

TilesetHideoutGFX1:: INCBIN "gfx/tilesets/hideout.2bpp.vram1.lzp"


SECTION "Tileset Data - hideout", ROMX

TilesetHideoutMeta:: INCBIN "data/tilesets/hideout_metatiles.bin.tlz"
TilesetHideoutAttr:: INCBIN "data/tilesets/hideout_attributes.bin.tlz"
TilesetHideoutColl:: INCBIN "data/tilesets/hideout_collision.bin.lzp"


SECTION "Tileset Graphics - kanto gym vram0", ROMX

TilesetKantoGymGFX0:: INCBIN "gfx/tilesets/kanto_gym.2bpp.vram0.lzp"


SECTION "Tileset Graphics - kanto gym vram1", ROMX

TilesetKantoGymGFX1:: INCBIN "gfx/tilesets/kanto_gym.2bpp.vram1.lzp"


SECTION "Tileset Data - kanto gym", ROMX

TilesetKantoGymMeta:: INCBIN "data/tilesets/kanto_gym_metatiles.bin.tlz"
TilesetKantoGymAttr:: INCBIN "data/tilesets/kanto_gym_attributes.bin.tlz"
TilesetKantoGymColl:: INCBIN "data/tilesets/kanto_gym_collision.bin.lzp"


SECTION "Tileset Graphics - Terminator vram2", ROMX

TilesetJohtoAncientGFX2::
TilesetBattleTowerOutsideGFX2::
TilesetKantoGFX2::
TilesetKantoNorthGFX2::
TilesetKantoUrbanGFX2::
TilesetIndigoPlateauGFX2::
TilesetShamoutiIslandGFX2::
TilesetValenciaIslandGFX2::
TilesetFarawayIslandGFX2::
TilesetJohtoHouseGFX2::
TilesetKantoHouseGFX2::
TilesetTraditionalHouseGFX2::
TilesetPokeCenterGFX2::
TilesetPokeComCenterGFX2::
TilesetMartGFX2::
TilesetGateGFX2::
TilesetMagnetTrainGFX2::
TilesetChampionsRoomGFX2::
TilesetPortGFX2::
TilesetLabGFX2::
TilesetFacilityGFX2::
TilesetMansionGFX2::
TilesetGameCornerGFX2::
TilesetDecorGFX2::
TilesetHotelGFX2::
TilesetTowerGFX2::
TilesetBattleTowerInsideGFX2::
TilesetRadioTowerGFX2::
TilesetLighthouseGFX2::
TilesetUndergroundGFX2::
TilesetCaveGFX2::
TilesetQuietCaveGFX2::
TilesetVolcanoGFX2::
TilesetIcePathGFX2::
TilesetTunnelGFX2::
TilesetForestGFX2::
TilesetParkGFX2::
TilesetSafariZoneGFX2::
TilesetRuinsOfAlphGFX2::
TilesetPokemonMansionGFX2::
TilesetBattleFactoryGFX2::
TilesetSnowtopMountainGFX2::
TilesetHiddenGrottoGFX2::
TilesetPeaksGFX2::
TilesetHideoutGFX2::
TilesetKantoGymGFX2::
	db $ff ; Compressed data is terminated with $ff.
