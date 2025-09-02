#ifndef __ALGOS_H
#define __ALGOS_H

#include <stdint.h>

typedef struct {
    void (*init)();
    void (*accumulate)(const uint8_t *data, uint32_t length);
    uint32_t (*get_crc)();
} IfaceChecksum;

typedef enum {
    eALGO_STM32,
    eALGO_RUT,
} AlgoId;

typedef struct {
    AlgoId id;
    char *name;
    IfaceChecksum *iface;
} Algo;

#endif /* __ALGOS_H */
