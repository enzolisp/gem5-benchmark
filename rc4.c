/*
 * RC4 Stream Cipher
 * Complexidade: O(n) no tamanho da mensagem + O(256) no key scheduling
 * Memória: S-box de 256 bytes; acessos pseudo-aleatórios → cache pressure
 * Controle: dois loops no KSA, um loop no PRGA com dois índices e swap
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MSG_SIZE   (1 << 24)   /* 16 MB */
#define KEY_SIZE   16
#define BENCH_RUNS 10

typedef struct {
    unsigned char S[256];
    int i, j;
} RC4_CTX;

/* Key Scheduling Algorithm */
static void rc4_init(RC4_CTX *ctx,
                     const unsigned char *key, size_t klen)
{
    for (int i = 0; i < 256; i++)
        ctx->S[i] = (unsigned char)i;

    int j = 0;
    for (int i = 0; i < 256; i++) {
        j = (j + ctx->S[i] + key[i % klen]) & 0xff;
        unsigned char tmp = ctx->S[i];
        ctx->S[i] = ctx->S[j];
        ctx->S[j] = tmp;
    }
    ctx->i = 0;
    ctx->j = 0;
}

/* Pseudo-Random Generation Algorithm */
static void rc4_encrypt(RC4_CTX *ctx,
                        const unsigned char *in, unsigned char *out,
                        size_t len)
{
    int i = ctx->i, j = ctx->j;
    unsigned char *S = ctx->S;

    for (size_t k = 0; k < len; k++) {
        i = (i + 1) & 0xff;
        j = (j + S[i]) & 0xff;

        unsigned char tmp = S[i];
        S[i] = S[j];
        S[j] = tmp;

        out[k] = in[k] ^ S[(S[i] + S[j]) & 0xff];
    }
    ctx->i = i;
    ctx->j = j;
}

int main(void)
{
    unsigned char *plaintext  = malloc(MSG_SIZE);
    unsigned char *ciphertext = malloc(MSG_SIZE);
    unsigned char key[KEY_SIZE] = {
        0x2b,0x7e,0x15,0x16,0x28,0xae,0xd2,0xa6,
        0xab,0xf7,0x15,0x88,0x09,0xcf,0x4f,0x3c
    };

    if (!plaintext || !ciphertext) {
        fprintf(stderr, "malloc failed\n");
        return 1;
    }

    srand(42);
    for (size_t i = 0; i < MSG_SIZE; i++)
        plaintext[i] = (unsigned char)(rand() & 0xff);

    printf("=== RC4 Benchmark ===\n");
    printf("Mensagem: %d MB | Chave: %d bytes | Runs: %d\n\n",
           MSG_SIZE >> 20, KEY_SIZE, BENCH_RUNS);

    struct timespec t0, t1;
    double total_ns = 0.0;
    RC4_CTX ctx;

    for (int r = 0; r < BENCH_RUNS; r++) {
        rc4_init(&ctx, key, KEY_SIZE);   /* reinicia S-box a cada run */

        clock_gettime(CLOCK_MONOTONIC, &t0);
        rc4_encrypt(&ctx, plaintext, ciphertext, MSG_SIZE);
        clock_gettime(CLOCK_MONOTONIC, &t1);

        double ns = (t1.tv_sec - t0.tv_sec) * 1e9 +
                    (t1.tv_nsec - t0.tv_nsec);
        total_ns += ns;
        printf("  Run %2d: %.2f ms\n", r + 1, ns / 1e6);
    }

    double avg_ms     = total_ns / BENCH_RUNS / 1e6;
    double throughput = (MSG_SIZE / (1024.0 * 1024.0)) / (avg_ms / 1000.0);

    printf("\n  Média:      %.2f ms\n", avg_ms);
    printf("  Throughput: %.1f MB/s\n", throughput);

    /* verificação: encriptar novamente com mesma chave deve recuperar plaintext */
    rc4_init(&ctx, key, KEY_SIZE);
    rc4_encrypt(&ctx, ciphertext, ciphertext, MSG_SIZE);
    if (memcmp(plaintext, ciphertext, MSG_SIZE) == 0)
        printf("  Verificação: OK (decrypt == plaintext)\n");
    else
        printf("  Verificação: FALHOU\n");

    free(plaintext);
    free(ciphertext);
    return 0;
}
