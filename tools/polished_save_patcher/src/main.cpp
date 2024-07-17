#include "SaveBinary.h"
#include "SymbolDatabase.h"
#include "PatchVersion7to8.h"
#include "PatcherConstants.h"
#include <iostream>
#include <fstream>
#include <streambuf>
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>
#include <vector>

class JSStreambuf : public std::streambuf {
public:
    JSStreambuf(void (*jsFunc)(const char*)) : jsFunc(jsFunc) {
        buffer.reserve(128); // reserve some initial space
    }

protected:
    virtual int overflow(int c) override {
        if (c != EOF) {
            buffer.push_back(c);
            if (c == '\n') {
                buffer.push_back('\0'); // null-terminate the buffer
                jsFunc(buffer.data());
                buffer.clear(); // clear the buffer after sending
            }
        }
        return c;
    }

    virtual std::streamsize xsputn(const char* s, std::streamsize n) override {
        for (std::streamsize i = 0; i < n; ++i) {
            overflow(s[i]);
        }
        return n;
    }

private:
    void (*jsFunc)(const char*);
    std::vector<char> buffer;
};

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
            std::cerr <<  "Unsupported save version: " << std::hex << saveVersion << std::endl;
            return;
        }

        patchVersion7to8(oldSave, newSave);

        // write that we are saving the file
        std::cout <<  "Saving file..." << std::endl;
        newSave.save(new_save_path);
        // write that the file was saved
        std::cout <<  "File saved successfully!" << std::endl;
    }
}

// Binding the patch_save function to JavaScript
EMSCRIPTEN_BINDINGS(patch_save_module) {
    emscripten::function("patch_save", &patch_save);
}

EM_JS(void, js_stdout, (const char* str), {
    var msg = UTF8ToString(str);
    console.log(msg);
    var outputElement = document.getElementById('output');
    if (outputElement) {
        outputElement.textContent += msg + '\n';
    }
});

EM_JS(void, js_stderr, (const char* str), {
    var msg = UTF8ToString(str);
    console.error(msg);
    var outputElement = document.getElementById('output');
    if (outputElement) {
        outputElement.innerHTML += '<span class="error">' + msg + '</span>\n';
    }
});

int main(int argc, char* argv[]) {
    static JSStreambuf stdoutBuf(js_stdout);
    static JSStreambuf stderrBuf(js_stderr);
    std::cout.rdbuf(&stdoutBuf);
    std::cerr.rdbuf(&stderrBuf);

    std::cerr <<  "This program is intended to be run in a browser using Emscripten." << std::endl;
    return 1;
}
