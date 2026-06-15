#include <stdio.h>

#define LEN   1024   /* 4 kB por array: cabe em L1D de 16 kB */
#define REPS 10000   /* repeticoes para gerar instrucoes suficientes */

static float x[LEN];
static float y[LEN];

int main(void) {
    int i, r;
    float a = 2.5f;

    for (i = 0; i < LEN; i++) {
        x[i] = (float)i;
        y[i] = (float)(LEN - i);
    }

    /* cada iteracao e independente das outras: alto ILP
       processador pode emitir multiplas iteracoes em paralelo */
    for (r = 0; r < REPS; r++)
        for (i = 0; i < LEN; i++)
            y[i] = a * x[i] + y[i];

    /* checksum para evitar eliminacao pelo compilador */
    float sum = 0.0f;
    for (i = 0; i < LEN; i++)
        sum += y[i];
    printf("checksum: %f\n", sum);

    return 0;
}
