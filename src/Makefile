# Makefile — Crypto Benchmark
# Gera binários com -O0, -O2 e -O3 para cada algoritmo

CC      = gcc
CFLAGS_BASE = -Wall -Wextra -std=c11 -D_POSIX_C_SOURCE=199309L
SRCS    = xor_cipher.c rc4.c aes128.c
TARGETS_O0 = $(SRCS:.c=_O0)
TARGETS_O2 = $(SRCS:.c=_O2)
TARGETS_O3 = $(SRCS:.c=_O3)

all: $(TARGETS_O0) $(TARGETS_O2) $(TARGETS_O3)

# Regras para cada nível de otimização
%_O0: %.c
	$(CC) $(CFLAGS_BASE) -O0 -o $@ $<

%_O2: %.c
	$(CC) $(CFLAGS_BASE) -O2 -o $@ $<

%_O3: %.c
	$(CC) $(CFLAGS_BASE) -O3 -march=native -o $@ $<

# Executa todos e coleta resultados
bench: all
	@echo "============================================"
	@echo " BENCHMARK COMPLETO"
	@echo "============================================"
	@for alg in xor_cipher rc4 aes128; do \
	    echo ""; \
	    echo "--------------------------------------------"; \
	    echo " $$alg"; \
	    echo "--------------------------------------------"; \
	    echo "[[ -O0 ]]"; ./$$alg\_O0; \
	    echo ""; \
	    echo "[[ -O2 ]]"; ./$$alg\_O2; \
	    echo ""; \
	    echo "[[ -O3 -march=native ]]"; ./$$alg\_O3; \
	done

clean:
	rm -f $(TARGETS_O0) $(TARGETS_O2) $(TARGETS_O3)

.PHONY: all bench clean
