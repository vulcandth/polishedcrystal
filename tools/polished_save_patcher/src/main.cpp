#include "SaveBinary.h"
#include "SymbolDatabase.h"
#include "PatchVersion7to8.h"
#include "PatcherConstants.h"
#include <iostream>
#include <fstream>

// main function
// Usage: polished_save_patcher <old_save_file> <output_save_file>
int main(int argc, char* argv[]) {
	if (argc != 3) {
		std::cerr << "Usage: polished_save_patcher <old_save_file> <output_save_file>" << std::endl;
		return 1;
	}

	// Load the old save file
	SaveBinary oldSave(argv[1]);
	// copy the old save file to the new save file
	SaveBinary newSave = oldSave;
	// load the save version big endian word
	uint16_t saveVersion = oldSave.getWordBE(SAVE_VERSION_ABS_ADDRESS);
	// if save versions < 7 is unsupported. if save version is > 8, it is unsupported. if save version is 8, it is already patched. 
	if (saveVersion < 0x07 || saveVersion > 0x08) {
		std::cerr << "Unsupported save version: " << std::hex << saveVersion << std::endl;
		return 1;
	}

	// ask the user if they want to patch the save file return if no
	std::cout << "Patching save file: " << argv[1] << " to " << argv[2] << ". Continue? (y/n): ";
	char response;
	std::cin >> response;
	if (response != 'y') {
		std::cout << "Save file not patched." << std::endl;
		return 0;
	}
	// check if output save file already exists and ask the user if they want to overwrite it
	std::ifstream file(argv[2]);
	if (file.is_open()) {
		std::cout << "Output save file already exists. Overwrite? (y/n): ";
		std::cin >> response;
		if (response != 'y') {
			std::cout << "Save file not patched." << std::endl;
			return 0;
		}
	}

	patchVersion7to8(oldSave, newSave);

	// write that we are saving the file
	std::cout << "Saving file..." << std::endl;
	newSave.save(argv[2]);
	// write that the file was saved
	std::cout << "File saved successfully!" << std::endl;
	return 0;
};
