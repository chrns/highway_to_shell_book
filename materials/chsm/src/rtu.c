#include "rtu.h"

static uint16_t crc = 0xFFFF;

static void rtu_crc_init(void) {
    crc = 0xFFFF;
}

static void rtu_crc_acc(const uint8_t *data, uint32_t length) {
    for (uint32_t pos = 0; pos < length; pos++) {
        crc ^= (uint16_t)data[pos];
        
        for (uint32_t i = 8; i != 0; i--) {
            if ((crc & 0x0001) != 0) {
                crc >>= 1;
                crc ^= 0xA001;
            } else {
                crc >>= 1;
            }
        }
    }
}

static uint32_t rtu_crc_get(void) {
    return (uint32_t)crc;
}

IfaceChecksum rtu = {
    .init = rtu_crc_init,
    .accumulate = rtu_crc_acc,
    .get_crc = rtu_crc_get,
};
