#include "PatchVersion7to8.h"
#include "CommonPatchFunctions.h"
#include "SymbolDatabase.h"

constexpr int NUM_OBJECT_STRUCTS = 13;
constexpr int OBJECT_PALETTE_V7 = 0x06;
constexpr int OBJECT_PALETTE_V8 = 0x06;
constexpr int OBJECT_PAL_INDEX_V8 = 0x21;
constexpr int OBJECT_LENGTH_V7 = 0x20;
constexpr int OBJECT_LENGTH_V8 = 0x21;
constexpr int NUM_KEY_ITEMS_V7 = 0x1D;
constexpr int NUM_KEY_ITEMS_V8 = 0x24;

void patchVersion7to8(SaveBinary& save7, SaveBinary& save8) {
	// copy the old save file to the new save file
	save8 = save7;

	// create the iterators
	SaveBinary::Iterator it7(save7, 0);
	SaveBinary::Iterator it8(save8, 0);

	// Load the version 7 and version 8 sym files
	SymbolDatabase sym7(VERSION_7_SYMBOL_FILE);
	SymbolDatabase sym8(VERSION_8_SYMBOL_FILE);

	// get the checksum word from the version 7 save file
	uint16_t save_checksum = save7.getWord(SAVE_CHECKSUM_ABS_ADDRESS);

	// verify the checksum of the version 7 file matches the calculated checksum
	// calculate the checksum from lookup symbol name "sGameData" to "sGameDataEnd"
	uint16_t calculated_checksum = calculate_checksum(save7, sym7.getSRAMAddress("sGameData"), sym7.getSRAMAddress("sGameDataEnd"));
	if (save_checksum != calculated_checksum) {
		std::cerr << "Checksum mismatch! Expected: " << std::hex << calculated_checksum << ", got: " << save_checksum << std::endl;
		return;
	}

	// check the backup checksum word from the version 7 save file
	uint16_t backup_checksum = save7.getWord(SAVE_BACKUP_CHECKSUM_ABS_ADDRESS);
	// verify the backup checksum of the version 7 file matches the calculated checksum
	// calculate the checksum from lookup symbol name "sBackupGameData" to "sBackupGameDataEnd"
	uint16_t calculated_backup_checksum = calculate_checksum(save7, sym7.getSRAMAddress("sBackupGameData"), sym7.getSRAMAddress("sBackupGameDataEnd"));
	if (backup_checksum != calculated_backup_checksum) {
		std::cerr << "Backup checksum mismatch! Expected: " << std::hex << calculated_backup_checksum << ", got: " << backup_checksum << std::endl;
		return;
	}

	std::cout << "Patching Player Data..." << std::endl;
	
	// copy bytes from wPlayerData to wObjectStructs - 1 from version 7 to version 8
	it7.seek(sym7.getPlayerDataAddress("wPlayerData"));
	it8.seek(sym8.getPlayerDataAddress("wPlayerData"));
	it8.copy(it7, sym7.getPlayerDataAddress("wObjectStructs") - sym7.getPlayerDataAddress("wPlayerData"));
	
	// version 8 expanded each object struct by 1 byte to add the palette index byte at the end.
	// we need to copy the lower nybble of OBJECT_PALETTE_V7 to the new OBJECT_PAL_INDEX_V8
	// and then copy the rest of the object struct from version 7 to version 8
	for (int i = 0; i < NUM_OBJECT_STRUCTS; i++) {
		// copy up to the palette byte
		it7.seek(sym7.getPlayerDataAddress("wObjectStructs") + i * OBJECT_LENGTH_V7);
		it8.seek(sym8.getPlayerDataAddress("wObjectStructs") + i * OBJECT_LENGTH_V8);
		it8.copy(it7, OBJECT_PALETTE_V7);
		// save the lower nybble of the palette byte
		uint8_t palette = it7.getByte() & 0x0F;
		// copy until the end of v7 object struct
		it8.copy(it7, OBJECT_LENGTH_V7 - OBJECT_PALETTE_V7);
		// write the palette byte to the new palette index byte
		it8.seek(sym8.getPlayerDataAddress("wObjectStructs") + i * OBJECT_LENGTH_V8 + OBJECT_PAL_INDEX_V8);
		it8.setByte(palette);
	}

	// copy bytes from wObjectStructsEnd to wBattleFactorySwapCount
	it7.seek(sym7.getPlayerDataAddress("wObjectStructsEnd"));
	it8.seek(sym8.getPlayerDataAddress("wObjectStructsEnd"));
	it8.copy(it7, sym7.getPlayerDataAddress("wBattleFactorySwapCount") - sym7.getPlayerDataAddress("wObjectStructsEnd"));

	// seek to wMapObjects
	it7.seek(sym7.getPlayerDataAddress("wMapObjects"));
	it8.seek(sym8.getPlayerDataAddress("wMapObjects"));

	// copy bytes to wEnteredMapFromContinue
	it8.copy(it7, sym7.getPlayerDataAddress("wEnteredMapFromContinue") - sym7.getPlayerDataAddress("wMapObjects"));
	
	// copy it7 wEnteredMapFromContinue to it8 wEnteredMapFromContinue
	it7.seek(sym7.getPlayerDataAddress("wEnteredMapFromContinue"));
	it8.seek(sym8.getPlayerDataAddress("wEnteredMapFromContinue"));
	it8.setByte(it7.getByte());
	// copy it7 wStatusFlags3 to it8 wStatusFlags3
	it7.seek(sym7.getPlayerDataAddress("wStatusFlags3"));
	it8.seek(sym8.getPlayerDataAddress("wStatusFlags3"));
	it8.setByte(it7.getByte());

	// copy from it7 wTimeOfDayPal to it7 wTMsHMsEnd
	it7.seek(sym7.getPlayerDataAddress("wTimeOfDayPal"));
	it8.seek(sym8.getPlayerDataAddress("wTimeOfDayPal"));
	it8.copy(it7, sym7.getPlayerDataAddress("wTMsHMsEnd") - sym7.getPlayerDataAddress("wTimeOfDayPal"));

	// set it8 wKeyItems -> wKeyItemsEnd to 0x00
	it8.seek(sym8.getPlayerDataAddress("wKeyItems"));
	while(it8.getAddress() < sym8.getPlayerDataAddress("wKeyItemsEnd")) {
		it8.setByte(0x00);
		it8.next();
	}

	// each wKeyItems in it7 is a bitfield of key items, look up the bit index in the map and set the corresponding bit in it8
	it7.seek(sym7.getPlayerDataAddress("wKeyItems"));
	it8.seek(sym8.getPlayerDataAddress("wKeyItems"));
	for (int i = 0; i < NUM_KEY_ITEMS_V7; i++) {
		// loop through all the bits in the byte
		for (int j = 0; j < 8; j++) {
			// check if the bit is set
			if (it7.getByte() & (1 << j)) {
				// get the key item index is equal to the bit index
				uint8_t keyItemIndex = i * 8 + j;
				// map the version 7 key item to the version 8 key item
				uint8_t keyItemIndexV8 = mapv7KeyItemtoV8(keyItemIndex);
				// if the key item is found write to the next byte in it8.
				if (keyItemIndexV8 != 0xFF) {
					it8.setByte(keyItemIndexV8);
					it8.next();
				}
			}
		}
	}
	// write -1 at the end of the key items
	it8.setByte(0xFF);

	



	// write new checksums to the version 8 save file
	uint16_t new_checksum = calculate_checksum(save8, sym8.getSRAMAddress("sGameData"), sym8.getSRAMAddress("sGameDataEnd"));
	save8.setWord(SAVE_CHECKSUM_ABS_ADDRESS, new_checksum);

	// write the modified save file to the output file and print success message
	std::cout << "Save file patched successfully!" << std::endl;
}

// converts a version 7 key item to a version 8 key item
uint8_t mapv7KeyItemtoV8(uint8_t v7) {
	std::unordered_map<uint8_t, uint8_t> indexMap = {
		{0x00, 0x01},  // BICYCLE
		{0x01, 0x02},  // OLD_ROD
		{0x02, 0x03},  // GOOD_ROD
		{0x03, 0x04},  // SUPER_ROD
		{0x04, 0x06},  // COIN_CASE
		{0x05, 0x05},  // ITEMFINDER
		{0x06, 0x0E},  // MYSTERY_EGG
		{0x07, 0x0C},  // SQUIRTBOTTLE
		{0x08, 0x0F},  // SECRETPOTION
		{0x09, 0x11},  // RED_SCALE
		{0x0A, 0x12},  // CARD_KEY
		{0x0B, 0x13},  // BASEMENT_KEY
		{0x0C, 0x1A},  // S_S_TICKET
		{0x0D, 0x1B},  // PASS
		{0x0E, 0x15},  // MACHINE_PART
		{0x0F, 0x14},  // LOST_ITEM
		{0x10, 0x16},  // RAINBOW_WING
		{0x11, 0x17},  // SILVER_WING
		{0x12, 0x18},  // CLEAR_BELL
		{0x13, 0x19},  // GS_BALL
		{0x14, 0x0B},  // BLUE_CARD
		{0x15, 0x1C},  // ORANGETICKET
		{0x16, 0x1D},  // MYSTICTICKET
		{0x17, 0x1E},  // OLD_SEA_MAP
		{0x18, 0x22},  // SHINY_CHARM
		{0x19, 0x23},  // OVAL_CHARM
		{0x1A, 0x24},  // CATCH_CHARM
		{0x1B, 0x0D},  // SILPHSCOPE2
		{0x1C, 0x07},  // APRICORN_BOX
		{0x1D, 0x09},  // TYPE_CHART
	};

	// return the corresponding version 8 key item or 0xFF if not found
	return indexMap.find(v7) != indexMap.end() ? indexMap[v7] : 0xFF;
}