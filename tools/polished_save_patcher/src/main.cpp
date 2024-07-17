#include "SaveBinary.h"
#include "SymbolDatabase.h"
#include "PatchVersion7to8.h"
#include "PatcherConstants.h"
#include <iostream>
#include <fstream>
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>

extern "C" {
	void patch_save(const std::string &old_save_path, const std::string &new_save_path) {
		// Load the old save file
		SaveBinary oldSave(old_save_path);
		// copy the old save file to the new save file
		SaveBinary newSave = oldSave;
		// load the save version big endian word
		uint16_t saveVersion = oldSave.getWordBE(SAVE_VERSION_ABS_ADDRESS);
		// if save versions < 7 is unsupported. if save version is > 8, it is unsupported. if save version is 8, it is already patched. 
		if (saveVersion < 0x07 || saveVersion > 0x08) {
			std::cerr << RED_TEXT << "Unsupported save version: " << std::hex << saveVersion << std::endl;
			return;
		}

		patchVersion7to8(oldSave, newSave);

		// write that we are saving the file
		std::cout << RESET_TEXT << "Saving file..." << std::endl;
		newSave.save(new_save_path);
		// write that the file was saved
		std::cout << RESET_TEXT << "File saved successfully!" << std::endl;
	}
}

// Binding the patch_save function to JavaScript
EMSCRIPTEN_BINDINGS(patch_save_module) {
	emscripten::function("patch_save", &patch_save);
}

int main(int argc, char* argv[]) {
	std::cerr << RED_TEXT << "This program is intended to be run in a browser using Emscripten." << std::endl;
	return 1;
}
