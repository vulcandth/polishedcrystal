# Makefile for polished_save_patcher

# Detect the operating system
OS := $(shell uname -s)

# Compiler and flags
CXX := g++
CXXFLAGS := -Iinclude

# Directories
SRC_DIR := src
INCLUDE_DIR := include
RESOURCES_DIR := resources
VERSION7_DIR := $(RESOURCES_DIR)/version7
VERSION8_DIR := $(RESOURCES_DIR)/version8

# Source files
SOURCES := $(SRC_DIR)/CommonPatchFunctions.cpp \
           $(SRC_DIR)/PatchVersion7to8.cpp \
           $(SRC_DIR)/SaveBinary.cpp \
           $(SRC_DIR)/SymbolDatabase.cpp \
           $(SRC_DIR)/main.cpp

# Object files
OBJECTS := $(SOURCES:.cpp=.o)

# Executable name
TARGET := polished_save_patcher

# Windows-specific settings
ifeq ($(OS), Windows_NT)
    CXX := g++
    RM := del
    TARGET := polished_save_patcher.exe
else
    RM := rm -f
endif

# Build target
all: $(TARGET)

# Linking
$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $@

# Compilation
$(SRC_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean
clean:
	$(RM) $(OBJECTS) $(TARGET)

# Phony targets
.PHONY: all clean
