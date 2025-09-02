#include "stm32.h"

#define STM32_CRC_INIT_VALUE    0xFFFFFFFFUL
#define STM32_POLYNOMIAL        0x04C11DB7UL

static uint32_t result = STM32_CRC_INIT_VALUE;
static uint32_t crc_table[256];

static void init_crc32_table(void) {
    for (uint32_t i = 0; i < 256; i++) {
        uint32_t crc = i << 24;  // Align byte to most significant byte for STM32 compatibility
        for (int j = 0; j < 8; j++) {
            if (crc & 0x80000000) {
                crc = (crc << 1) ^ STM32_POLYNOMIAL;
            } else {
                crc <<= 1;
            }
        }
        crc_table[i] = crc;
    }
}

static void stm32_crc_init(void) {
    result = STM32_CRC_INIT_VALUE;
    init_crc32_table();
}

static void stm32_crc_acc(const uint8_t *data, uint32_t length) {
    for (uint32_t i = 0; i < length; i++) {
        uint8_t byte = data[i];
        // Reverse byte for little-endian processing
        byte = (byte << 4) | (byte >> 4);  // Swap nibbles
        byte = ((byte & 0x33) << 2) | ((byte & 0xCC) >> 2);
        byte = ((byte & 0x55) << 1) | ((byte & 0xAA) >> 1);
        
        result = (result >> 8) ^ crc_table[(result ^ byte) & 0xFF];
    }
}

static uint32_t stm32_crc_get(void) {
    return result;
}

IfaceChecksum stm32 = {
    .init = stm32_crc_init,
    .accumulate = stm32_crc_acc,
    .get_crc = stm32_crc_get,
};