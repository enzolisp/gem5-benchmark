#include <stdio.h>
#include <stdlib.h>

static long collatz_steps(unsigned long long n, long *even_count,
                          long *odd_count) {
  long steps = 0;
  while (n != 1) {
    if (n % 2 == 0) {
      n = n / 2;
      (*even_count)++;
    } else {
      n = 3 * n + 1;
      (*odd_count)++;
    }
    steps++;
  }
  return steps;
}

int main(int argc, char *argv[]) {
  long n_values = (argc > 1) ? atol(argv[1]) : 4000;
  unsigned long long max_start =
      (argc > 2) ? strtoull(argv[2], NULL, 10) : 1000000ULL;
  unsigned int seed = (argc > 3) ? (unsigned int)atoi(argv[3]) : 42;

  srand(seed);

  long long total_steps = 0;
  long max_steps = 0;
  unsigned long long max_steps_value = 0;
  long total_even = 0, total_odd = 0;

  for (long i = 0; i < n_values; i++) {
    unsigned long long start = 2 + (unsigned long long)rand() % max_start;
    long even = 0, odd = 0;
    long steps = collatz_steps(start, &even, &odd);

    total_steps += steps;
    total_even += even;
    total_odd += odd;

    if (steps > max_steps) {
      max_steps = steps;
      max_steps_value = start;
    }
  }

  printf("Numeros testados: %ld\n", n_values);
  printf("Total de passos: %lld\n", total_steps);
  printf("Media de passos: %.4f\n", (double)total_steps / n_values);
  printf("Maior sequencia: %llu (passos: %ld)\n", max_steps_value, max_steps);
  printf("Branches pares: %ld | impares: %ld\n", total_even, total_odd);

  return 0;
}
