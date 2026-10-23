#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int32_t mojo_adreno_spirv_demo(const unsigned char *, intptr_t,
                                    float *, float *, float *, intptr_t);

int main(int argc, char **argv) {
    if (argc < 2 || argc > 4) {
        fprintf(stderr, "usage: mojo-spirv MODULE.spv [--corrupt-output | --count N]\n");
        return 1;
    }
    int n = 8;
    int corrupt = argc == 3 && strcmp(argv[2], "--corrupt-output") == 0;
    if (argc == 4 && strcmp(argv[2], "--count") == 0) {
        char *end;
        long value = strtol(argv[3], &end, 10);
        if (*end || value < 1 || value > 1048576) return 1;
        n = (int)value;
    } else if (argc != 2 && !corrupt) return 1;
    FILE *f = fopen(argv[1], "rb");
    if (!f || fseek(f, 0, SEEK_END)) return 1;
    long size = ftell(f);
    if (size < 20 || size > 16777216 || fseek(f, 0, SEEK_SET)) return 1;
    unsigned char *il = malloc((size_t)size);
    float *input = calloc((size_t)n, sizeof(float));
    float *output = malloc(3 * (size_t)n * sizeof(float));
    float *expected = malloc(3 * (size_t)n * sizeof(float));
    if (!il || !input || !output || !expected) return 1;
    if (fread(il, 1, (size_t)size, f) != (size_t)size) return 1;
    fclose(f);
    for (int i = 0; i < 3 * n; ++i) output[i] = expected[i] = NAN;
    int32_t status = mojo_adreno_spirv_demo(il, size, input, output, expected, n);
    free(il);
    if (status != 0) {
        fprintf(stderr, "Mojo/SPIR-V failed: status=%d\n", status);
        return 1;
    }
    if (corrupt) output[3 * n - 1] += 1;
    int result = 0;
    for (int row = 0; row < 3 && result == 0; ++row) {
        for (int i = 0; i < n; ++i) {
            int j = row * n + i;
            if (!isfinite(output[j]) || output[j] != expected[j]) {
                fprintf(stderr, "Mismatch at %d: got %g expected %g\n", j, output[j], expected[j]);
                result = 1;
                break;
            }
            printf("%s%.9g", i ? " " : "", output[j]);
        }
        putchar('\n');
    }
    free(input);
    free(output);
    free(expected);
    return result;
}
