#include <stdio.h>
extern float mojo_add(float, float);
int main(void) {
    float got = mojo_add(1.25f, 2.5f);
    printf("Mojo ARM64 exported function: %.2f\n", got);
    return got != 3.75f;
}
