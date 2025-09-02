#include "main.h"
#include "algos.h"

#include "stm32.h"
#include "rtu.h"

Algo algorithms[] = {
    { eALGO_STM32,  "stm32",    .iface = &stm32 },
    { eALGO_RUT,    "rtu",      .iface = &rtu },
};

static struct option long_options[] = {
    {   "dec",  no_argument,        NULL,   'i' },  // use to get a result in DEC
    {   "algo", required_argument,  NULL,   'a' },  // set algorithm
    {   NULL,   no_argument,        NULL,   0 }
};

void print_usage(void) {
    fprintf(stderr, "Usage: %s [-i] [-a] [-h]\n", PROGRAM_NAME);
    fprintf(stderr, " -i, --dec         Use DEC output (HEX by default)\n");
    fprintf(stderr, " -a, --algo [name] Use specific checksum algorithm (stm32 by default)\n"\
                    "            stm32 - CRC32 used in STM32 microcontrollers\n"\
                    "            rtu   - CRC16 used in MODBUS RTU\n");
    fprintf(stderr, " -h, --help        Print help\n");
    fprintf(stderr, "\nchsm v.%s (build time %s %s)\n", PROGRAM_VERSION, __DATE__, __TIME__);
    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
    int opt;
    bool print_hex = true;
    Algo *algorithm = &algorithms[0];

    while ((opt = getopt_long(argc, argv, "ia:h", long_options, NULL)) != -1) {
        bool found = false;
        switch (opt) {
            case 'i':
                print_hex = false;
                break;
            case 'a':
                for (uint32_t id = 0; id < sizeof(algorithms) / sizeof(Algo); id++) {
                    if (strcmp(optarg, algorithms[id].name) == 0) {
                        found = true;
                        algorithm = &algorithms[id];
                        break;
                    }
                }
                found ?: print_usage();
                break;
            case 'h':
            default:
                print_usage();
        }
    }
    
    FILE *file = NULL;
    if (optind < argc) {
        file = fopen(argv[optind], "rb");
        if (file == NULL) {
            fprintf(stderr, "%s: %s\n", PROGRAM_NAME, strerror(errno));
            return EXIT_FAILURE;
        }
    } else if (!isatty(STDIN_FILENO)) {
        file = stdin;
    } else {
        fprintf(stderr, "%s: No input provided.\n", PROGRAM_NAME);
        return EXIT_FAILURE;
    }

    uint8_t buffer[4];
    uint32_t bytes_read = 0;
    algorithm->iface->init();    
    while (bytes_read = fread(buffer, 1, sizeof(buffer), file), bytes_read != 0) {
        algorithm->iface->accumulate(buffer, bytes_read);
    }

    printf(print_hex ? "%X\n" : "%d\n", algorithm->iface->get_crc());

    return EXIT_SUCCESS;
}