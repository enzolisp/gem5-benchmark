/*
 * XOR Cipher — Baseline
 * Complexidade: O(n) no tamanho da mensagem
 * Memória: mínima (sem tabelas, sem estado além da chave)
 * Controle: loop simples, sem branches internos
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MSG_SIZE   (1 << 24)   /* 16 MB */
#define KEY_SIZE   16
#define BENCH_RUNS 10

static void xor_encrypt(const unsigned char *in, unsigned char *out,
                        size_t len, const unsigned char *key, size_t klen)
{
    for (size_t i = 0; i < len; i++)
        out[i] = in[i] ^ key[i % klen];
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

    /* preenche com dados pseudo-aleatórios */
    srand(42);
    for (size_t i = 0; i < MSG_SIZE; i++)
        plaintext[i] = (unsigned char)(rand() & 0xff);

    printf("=== XOR Cipher Benchmark ===\n");
    printf("Mensagem: %d MB | Chave: %d bytes | Runs: %d\n\n",
           MSG_SIZE >> 20, KEY_SIZE, BENCH_RUNS);

    struct timespec t0, t1;
    double total_ns = 0.0;

    for (int r = 0; r < BENCH_RUNS; r++) {
        clock_gettime(CLOCK_MONOTONIC, &t0);
        xor_encrypt(plaintext, ciphertext, MSG_SIZE, key, KEY_SIZE);
        clock_gettime(CLOCK_MONOTONIC, &t1);

        double ns = (t1.tv_sec - t0.tv_sec) * 1e9 +
                    (t1.tv_nsec - t0.tv_nsec);
        total_ns += ns;
        printf("  Run %2d: %.2f ms\n", r + 1, ns / 1e6);
    }

    double avg_ms  = total_ns / BENCH_RUNS / 1e6;
    double throughput = (MSG_SIZE / (1024.0 * 1024.0)) / (avg_ms / 1000.0);

    printf("\n  Média:      %.2f ms\n", avg_ms);
    printf("  Throughput: %.1f MB/s\n", throughput);

    /* sanity check: encriptar duas vezes recupera o original */
    xor_encrypt(ciphertext, ciphertext, MSG_SIZE, key, KEY_SIZE);
    if (memcmp(plaintext, ciphertext, MSG_SIZE) == 0)
        printf("  Verificação: OK (decrypt == plaintext)\n");
    else
        printf("  Verificação: FALHOU\n");

    free(plaintext);
    free(ciphertext);
    return 0;
}
