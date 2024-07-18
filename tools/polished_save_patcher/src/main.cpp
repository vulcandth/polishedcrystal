#include "SaveBinary.h"
#include "SymbolDatabase.h"
#include "PatchVersion7to8.h"
#include "PatcherConstants.h"
#include "Logging.h"
#include <iostream>
#include <fstream>
#include <streambuf>
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>
#include <vector>

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
            js_error << "Unsupported save version: " << std::hex << saveVersion << std::endl;
            return;
        }

        patchVersion7to8(oldSave, newSave);

        // write that we are saving the file
        js_info << "Saving file..." << std::endl;
        newSave.save(new_save_path);
        // write that the file was saved
        js_info << "File saved successfully!" << std::endl;
    }
}

// Binding the patch_save function to JavaScript
EMSCRIPTEN_BINDINGS(patch_save_module) {
    emscripten::function("patch_save", &patch_save);
}

int main(int argc, char* argv[]) {
    js_error << "This program is intended to be run in a browser using Emscripten." << std::endl;
    return 1;
}
