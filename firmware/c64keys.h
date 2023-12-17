#ifndef C64KEYS_H
#define C64KEYS_H

#define KEYBOARDBASE 0xffffff90
#define HW_KEYBOARD(x) *(volatile unsigned int *)(KEYBOARDBASE+x)

#define REG_KEYBOARD_WORD0 0
#define REG_KEYBOARD_WORD1 4

struct c64keyboard
{
	int active;
	int frame;
	int layer;
	int qualifiers;
	unsigned int keys[6];
};

extern struct c64keyboard c64keys;

void handle64keys();
void initc64keys();
void sendc64keys();

#endif
