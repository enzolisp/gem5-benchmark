#include <stdio.h>

#define N 90

static int A[N][N];
static int B[N][N];
static int C[N][N];

int main(void) {
    int i, j, k;

    for (i = 0; i < N; i++)
        for (j = 0; j < N; j++) {
            A[i][j] = i + j;
            B[i][j] = i - j;
            C[i][j] = 0;
        }

    /* acesso B[k][j]: stride de N*sizeof(int) bytes por iteracao de k
       → prefetcher nao consegue prever → misses em L1D */
    for (i = 0; i < N; i++)
        for (j = 0; j < N; j++)
            for (k = 0; k < N; k++)
                C[i][j] += A[i][k] * B[k][j];

    /* imprime checksum para evitar eliminacao pelo compilador */
    int sum = 0;
    for (i = 0; i < N; i++)
        sum += C[i][i];
    printf("checksum: %d\n", sum);

    return 0;
}
