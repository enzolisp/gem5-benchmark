library(ggplot2)

benchmarks <- c("matmul", "collatz", "MAC")

# ── issuewidth data (variants: 1, 2, 3, 4=fixed) ──────────────────────────────
iw <- data.frame(
  issuewidth = c(1, 2, 3, 4,   1, 2, 3, 4,   1, 2, 3, 4),
  benchmark  = rep(benchmarks, each = 4),
  ipc        = c(0.817522, 1.090134, 1.093983, 1.089217,
                 0.492200, 0.660826, 0.659464, 0.659403,
                 0.571096, 0.799332, 0.799315, 0.799321),
  sim_sec    = c(0.037669, 0.028249, 0.028150, 0.028273,
                 0.009313, 0.006936, 0.006951, 0.006951,
                 0.358731, 0.256301, 0.256306, 0.256305)
)
iw$sim_sec    <- iw$sim_sec * 1000
iw$issuewidth <- factor(iw$issuewidth)

# ── L1D cache size data (8kB, 16kB, 32kB=fixed, 64kB) ────────────────────────
l1d <- data.frame(
  l1d_kB    = c(8, 16, 32, 64,   8, 16, 32, 64,   8, 16, 32, 64),
  benchmark = rep(benchmarks, each = 4),
  ipc       = c(1.077156, 1.089191, 1.089217, 1.113339,
                0.659341, 0.659392, 0.659403, 0.659403,
                0.799312, 0.799316, 0.799321, 0.799321),
  sim_sec   = c(0.028589, 0.028273, 0.028273, 0.027660,
                0.006952, 0.006951, 0.006951, 0.006951,
                0.256308, 0.256306, 0.256305, 0.256305)
)
l1d$sim_sec <- l1d$sim_sec * 1000
l1d$l1d_kB <- factor(l1d$l1d_kB, levels = c(8, 16, 32, 64),
                     labels = c("8 kB", "16 kB", "32 kB", "64 kB"))

# ── numROB data (16, 32, 64, 128=fixed) ───────────────────────────────────────
rob <- data.frame(
  numROB    = c(16, 32, 64, 128,   16, 32, 64, 128,   16, 32, 64, 128),
  benchmark = rep(benchmarks, each = 4),
  ipc       = c(0.686061, 0.887915, 1.089063, 1.089217,
                0.491367, 0.642670, 0.659406, 0.659403,
                0.649877, 0.799313, 0.799317, 0.799321),
  sim_sec   = c(0.044887, 0.034683, 0.028277, 0.028273,
                0.009328, 0.007132, 0.006951, 0.006951,
                0.315244, 0.256307, 0.256306, 0.256305)
)
rob$sim_sec <- rob$sim_sec * 1000
rob$numROB  <- factor(rob$numROB)

# ── helper ─────────────────────────────────────────────────────────────────────
make_plot <- function(df, x_col, y_col, x_lab, y_lab, title) {
  ggplot(df, aes_string(x = x_col, y = y_col,
                        color = "benchmark", group = "benchmark")) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 2.5) +
    geom_text(aes_string(label = sprintf("round(%s, 4)", y_col)),
              vjust = -0.8, size = 3, show.legend = FALSE) +
    labs(title = title, x = x_lab, y = y_lab, color = "Benchmark") +
    expand_limits(y = 0) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
    theme_bw(base_size = 13) +
    theme(legend.position = "bottom",
          plot.title = element_text(hjust = 0.5))
}

# ── 6 plots ────────────────────────────────────────────────────────────────────
p1 <- make_plot(iw,  "issuewidth", "ipc",
                "Issue Width", "IPC",
                "IPC vs Issue Width")

p2 <- make_plot(iw,  "issuewidth", "sim_sec",
                "Issue Width", "Tempo de execução (ms)",
                "Tempo de execução vs Issue Width")

p3 <- make_plot(l1d, "l1d_kB", "ipc",
                "Tamanho da Cache L1D", "IPC",
                "IPC vs Tamanho da Cache L1D")

p4 <- make_plot(l1d, "l1d_kB", "sim_sec",
                "Tamanho da Cache L1D", "Tempo de execução (ms)",
                "Tempo de execução vs Tamanho da Cache L1D")

p5 <- make_plot(rob, "numROB", "ipc",
                "Número de Entradas no ROB", "IPC",
                "IPC vs Número de Entradas no ROB")

p6 <- make_plot(rob, "numROB", "sim_sec",
                "Número de Entradas no ROB", "Tempo de execução (ms)",
                "Tempo de execução vs Número de Entradas no ROB")

# ── save ───────────────────────────────────────────────────────────────────────
ggsave("plot1_issuewidth_ipc.png",  p1, width = 7, height = 4.5, dpi = 150)
ggsave("plot2_issuewidth_time.png", p2, width = 7, height = 4.5, dpi = 150)
ggsave("plot3_l1d_ipc.png",         p3, width = 7, height = 4.5, dpi = 150)
ggsave("plot4_l1d_time.png",        p4, width = 7, height = 4.5, dpi = 150)
ggsave("plot5_rob_ipc.png",         p5, width = 7, height = 4.5, dpi = 150)
ggsave("plot6_rob_time.png",        p6, width = 7, height = 4.5, dpi = 150)

cat("Gráficos salvos:\n")
cat("  plot1_issuewidth_ipc.png\n")
cat("  plot2_issuewidth_time.png\n")
cat("  plot3_l1d_ipc.png\n")
cat("  plot4_l1d_time.png\n")
cat("  plot5_rob_ipc.png\n")
cat("  plot6_rob_time.png\n")

# ── O0 vs O2 comparison (matmul e MAC apenas — collatz_O2 sem dados) ───────────
benchmarks_o2 <- c("matmul", "MAC")

iw_cmp <- data.frame(
  issuewidth = rep(c(1, 2, 3, 4), 4),
  benchmark  = rep(rep(benchmarks_o2, each = 4), 2),
  opt        = rep(c("O0", "O2"), each = 8),
  ipc = c(
    # O0
    0.817522, 1.090134, 1.093983, 1.089217,
    0.571096, 0.799332, 0.799315, 0.799321,
    # O2
    0.488004, 0.670545, 0.670621, 0.670664,
    0.532907, 0.745769, 0.745769, 0.745769
  ),
  sim_sec = c(
    # O0
    0.037669, 0.028249, 0.028150, 0.028273,
    0.358731, 0.256301, 0.256306, 0.256305,
    # O2
    0.007367, 0.005361, 0.005361, 0.005360,
    0.153815, 0.109913, 0.109913, 0.109913
  )
)
iw_cmp$sim_sec    <- iw_cmp$sim_sec * 1000
iw_cmp$issuewidth <- factor(iw_cmp$issuewidth)
iw_cmp$group      <- paste(iw_cmp$benchmark, iw_cmp$opt)

l1d_cmp <- data.frame(
  l1d_kB   = rep(c(8, 16, 32, 64), 4),
  benchmark = rep(rep(benchmarks_o2, each = 4), 2),
  opt       = rep(c("O0", "O2"), each = 8),
  ipc = c(
    # O0
    1.077156, 1.089191, 1.089217, 1.113339,
    0.799312, 0.799316, 0.799321, 0.799321,
    # O2
    0.670389, 0.670636, 0.670664, 0.670703,
    0.730550, 0.745758, 0.745769, 0.745769
  ),
  sim_sec = c(
    # O0
    0.028589, 0.028273, 0.028273, 0.027660,
    0.256308, 0.256306, 0.256305, 0.256305,
    # O2
    0.005362, 0.005361, 0.005360, 0.005360,
    0.112202, 0.109914, 0.109913, 0.109913
  )
)
l1d_cmp$sim_sec <- l1d_cmp$sim_sec * 1000
l1d_cmp$l1d_kB <- factor(l1d_cmp$l1d_kB, levels = c(8, 16, 32, 64),
                          labels = c("8 kB", "16 kB", "32 kB", "64 kB"))
l1d_cmp$group  <- paste(l1d_cmp$benchmark, l1d_cmp$opt)

rob_cmp <- data.frame(
  numROB    = rep(c(16, 32, 64, 128), 4),
  benchmark = rep(rep(benchmarks_o2, each = 4), 2),
  opt       = rep(c("O0", "O2"), each = 8),
  ipc = c(
    # O0
    0.686061, 0.887915, 1.089063, 1.089217,
    0.649877, 0.799313, 0.799317, 0.799321,
    # O2
    0.461358, 0.606062, 0.670616, 0.670664,
    0.549327, 0.745758, 0.745763, 0.745769
  ),
  sim_sec = c(
    # O0
    0.044887, 0.034683, 0.028277, 0.028273,
    0.315244, 0.256307, 0.256306, 0.256305,
    # O2
    0.007792, 0.005932, 0.005361, 0.005360,
    0.149218, 0.109914, 0.109913, 0.109913
  )
)
rob_cmp$sim_sec <- rob_cmp$sim_sec * 1000
rob_cmp$numROB  <- factor(rob_cmp$numROB)
rob_cmp$group   <- paste(rob_cmp$benchmark, rob_cmp$opt)

make_cmp_plot <- function(df, x_col, y_col, x_lab, y_lab, title) {
  ggplot(df, aes_string(x = x_col, y = y_col,
                        color = "benchmark", linetype = "opt",
                        group = "group")) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 2.5) +
    geom_text(aes_string(label = sprintf("round(%s, 4)", y_col)),
              vjust = -0.8, size = 2.8, show.legend = FALSE) +
    labs(title = title, x = x_lab, y = y_lab,
         color = "Benchmark", linetype = "Otimização") +
    expand_limits(y = 0) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
    theme_bw(base_size = 13) +
    theme(legend.position = "bottom",
          plot.title = element_text(hjust = 0.5))
}

pc1 <- make_cmp_plot(iw_cmp,  "issuewidth", "ipc",
                     "Issue Width", "IPC",
                     "IPC vs Issue Width — O0 vs O2")
pc2 <- make_cmp_plot(iw_cmp,  "issuewidth", "sim_sec",
                     "Issue Width", "Tempo de execução (ms)",
                     "Tempo de execução vs Issue Width — O0 vs O2")
pc3 <- make_cmp_plot(l1d_cmp, "l1d_kB", "ipc",
                     "Tamanho da Cache L1D", "IPC",
                     "IPC vs Cache L1D — O0 vs O2")
pc4 <- make_cmp_plot(l1d_cmp, "l1d_kB", "sim_sec",
                     "Tamanho da Cache L1D", "Tempo de execução (ms)",
                     "Tempo de execução vs Cache L1D — O0 vs O2")
pc5 <- make_cmp_plot(rob_cmp, "numROB", "ipc",
                     "Número de Entradas no ROB", "IPC",
                     "IPC vs ROB — O0 vs O2")
pc6 <- make_cmp_plot(rob_cmp, "numROB", "sim_sec",
                     "Número de Entradas no ROB", "Tempo de execução (ms)",
                     "Tempo de execução vs ROB — O0 vs O2")

ggsave("cmp1_issuewidth_ipc.png",  pc1, width = 7, height = 4.5, dpi = 150)
ggsave("cmp2_issuewidth_time.png", pc2, width = 7, height = 4.5, dpi = 150)
ggsave("cmp3_l1d_ipc.png",         pc3, width = 7, height = 4.5, dpi = 150)
ggsave("cmp4_l1d_time.png",        pc4, width = 7, height = 4.5, dpi = 150)
ggsave("cmp5_rob_ipc.png",         pc5, width = 7, height = 4.5, dpi = 150)
ggsave("cmp6_rob_time.png",        pc6, width = 7, height = 4.5, dpi = 150)

cat("  cmp1_issuewidth_ipc.png\n")
cat("  cmp2_issuewidth_time.png\n")
cat("  cmp3_l1d_ipc.png\n")
cat("  cmp4_l1d_time.png\n")
cat("  cmp5_rob_ipc.png\n")
cat("  cmp6_rob_time.png\n")
