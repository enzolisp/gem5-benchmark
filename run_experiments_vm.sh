#!/usr/bin/env bash
#
# Versão pra rodar dentro da VM do gem5: usa "./gem5" direto
# (igual ao Tutorial_gem5.pdf), sem caminho explícito pro binário.
#
# Roda config fixa + variações dos 3 parâmetros (L1D size, issueWidth,
# MyMemUnit count) para os 3 benchmarks (aes128, rc4, xor_cipher).
#
# Resultados (m5out de cada run) ficam em results/<config>/<benchmark>/
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEM5_DIR="$ROOT_DIR/gem5"
SIM_SCRIPT="orgb_configs/simulate.py"
RESULTS_DIR="$ROOT_DIR/results"

CACHES_FILE="orgb_configs/systems/caches/basic_caches.py"
CPU_FILE="orgb_configs/systems/cpus/MyO3CPU.py"

# Linhas dos parâmetros na config fixa
L1D_LINE=28          # size = '64kB'         (BasicL1DCache)
ISSUEWIDTH_LINE=182  # issueWidth =  4
NUMROBENT=164     # count = 1             (MyMemUnit)

declare -A BENCHMARKS=(
  [aes128]="$ROOT_DIR/orgb_progs/aes128_O0"
  [rc4]="$ROOT_DIR/orgb_progs/rc4_O0"
  [xor]="$ROOT_DIR/orgb_progs/xor_cipher_O0"
)

run_gem5() {
  local bin="$1" outdir="$2"
  mkdir -p "$outdir"
  echo ">> $(basename "$bin") -> ${outdir#$RESULTS_DIR/}"
  (./gem5 --outdir="$outdir" "$SIM_SCRIPT" run-benchmark -c "$bin") \
    > "$outdir/run.log" 2>&1
}

run_all_benchmarks() {
  local label="$1"
  for name in "${!BENCHMARKS[@]}"; do
    run_gem5 "${BENCHMARKS[$name]}" "$RESULTS_DIR/$label/$name"
  done
}

patch_line() {
  local file="$1" line="$2" content="$3"
  sed -i "${line}s/.*/${content}/" "$file"
}

echo "=== Config fixa (base) ==="
run_all_benchmarks "fixed"

echo "=== Variando L1D size ==="
for size in 16kB 64kB 128kB; do
  patch_line "$CACHES_FILE" "$L1D_LINE" "    size = '${size}'"
  run_all_benchmarks "l1d_${size}"
done
patch_line "$CACHES_FILE" "$L1D_LINE" "    size = '32kB'"

echo "=== Variando issueWidth ==="
for w in 2 6 8; do
  patch_line "$CPU_FILE" "$ISSUEWIDTH_LINE" "    issueWidth    =  ${w} # Issue width"
  run_all_benchmarks "issuewidth_${w}"
done
patch_line "$CPU_FILE" "$ISSUEWIDTH_LINE" "    issueWidth    =  4 # Issue width"

echo "=== Variando NumRob count ==="
for c in 32 64 256; do
  patch_line "$CPU_FILE" "$NUMROBENT" "     numROBEntries = ${c}"
  run_all_benchmarks "numRob_${c}"
done
patch_line "$CPU_FILE" "$NUMROBENT" "     numROBEntries =   128"

echo ""
echo "Done. Resultados em $RESULTS_DIR/"
echo "IPC/sim_seconds estao em results/<config>/<benchmark>/stats.txt"
