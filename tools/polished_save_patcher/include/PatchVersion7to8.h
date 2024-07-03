#ifndef PATCHVERSION7TO8_H
#define PATCHVERSION7TO8_H

#include "SaveBinary.h"
#include "SymbolDatabase.h"
#include "PatcherConstants.h"
#include <iostream>

// converts a version 7 key item to a version 8 key item
uint8_t mapv7KeyItemtoV8(uint8_t v7);

// void patchVersion7to8 takes in arguments SaveBinary save7 and SaveBinary save8
void patchVersion7to8(SaveBinary& save7, SaveBinary& save8);

#endif