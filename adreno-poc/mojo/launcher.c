#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern int32_t mojo_adreno_demo(float *, float *, float *, intptr_t);

int main(int argc, char **argv) {
    float inputs[8] = {0}, outputs[24], expected[24];
    for (int i = 0; i < 24; ++i) outputs[i] = expected[i] = NAN;
    int32_t status = mojo_adreno_demo(inputs, outputs, expected, 8);
    if (status != 0) {
        fprintf(stderr, "Mojo/Adreno demo failed: status=%d\n", status);
        return 1;
    }
    if (argc == 2 && strcmp(argv[1], "--corrupt-output") == 0) outputs[23] += 1;
    for (int row = 0; row < 3; ++row) {
        for (int i = 0; i < 8; ++i) {
            int j = row * 8 + i;
            if (!isfinite(outputs[j]) || outputs[j] != expected[j]) {
                fprintf(stderr, "Mismatch at %d: got %g expected %g\n", j, outputs[j], expected[j]);
                return 1;
            }
            printf("%s%.9g", i ? " " : "", outputs[j]);
        }
        putchar('\n');
    }
    return 0;
}
