# Makefile for polished_save_patcher with WebAssembly

# Detect the operating system
OS := $(shell uname -s)

# Compiler and flags
CXX := emcc
CXXFLAGS := -Iinclude -std=c++17

# Directories
SRC_DIR := src
INCLUDE_DIR := include
RESOURCES_DIR := resources
VERSION7_DIR := $(RESOURCES_DIR)/version7
VERSION8_DIR := $(RESOURCES_DIR)/version8

# Source files
SOURCES := $(SRC_DIR)/CommonPatchFunctions.cpp \
           $(SRC_DIR)/PatchVersion7to8.cpp \
           $(SRC_DIR)/PatchVersion7to8_unorderedmaps.cpp \
           $(SRC_DIR)/SaveBinary.cpp \
           $(SRC_DIR)/SymbolDatabase.cpp \
           $(SRC_DIR)/main.cpp

# Object files
OBJECTS := $(SOURCES:.cpp=.o)

# Executable name
TARGET := polished_save_patcher.html

# Windows-specific settings
ifeq ($(OS), Windows_NT)
    CXX := emcc
    RM := del
else
    RM := rm -f
endif

# Build target
all: $(TARGET)

# Linking
$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $@ $(LDFLAGS) -s WASM=1 -s EXPORTED_RUNTIME_METHODS='["ccall", "cwrap"]' --preload-file resources --bind

# Compilation
$(SRC_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean
clean:
	$(RM) $(OBJECTS) $(TARGET)

# Phony targets
.PHONY: all clean
