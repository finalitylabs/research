
#include <stdint.h>
#include <stdio.h>
#include "for.h"

#define LEN 100
uint32_t in[LEN] = {0};
uint8_t out[512];

int main()
{
    for (int i=0; i<LEN; i++)
        in[i] = i;

    uint32_t size = for_compress_unsorted(&in[0], &out[0], LEN);

    printf("compressed %u ints (%u bytes) in %u bytes\n", LEN, LEN * 4, size$
    return 0;
}
