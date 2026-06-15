library(ggplot2)

benchmarks <- c("collatzbranch", "rc4", "xor")

# ── issuewidth data ────────────────────────────────────────────────────────────
iw <- data.frame(
  issuewidth = c(2, 4, 6, 8,   2, 4, 6, 8,   2, 4, 6, 8),
  benchmark  = rep(benchmarks, each = 4),
  ipc        = c(0.700096, 0.701915, 0.701913, 0.701913,
                 0.835306, 0.844715, 0.842397, 0.842397,
                 0.696399, 0.692191, 0.702220, 0.702220),
  sim_sec    = c(0.326092, 0.325246, 0.325247, 0.325247,
                 0.167840, 0.165970, 0.166427, 0.166427,
                 0.092880, 0.093445, 0.092110, 0.092110)
)
iw$issuewidth <- factor(iw$issuewidth)

# ── L1D cache size data ────────────────────────────────────────────────────────
l1d <- data.frame(
  l1d_kB    = c(16, 64, 128,   16, 64, 128,   16, 64, 128),
  benchmark = rep(benchmarks, each = 3),
  ipc       = c(0.701915, 0.701915, 0.701915,
                0.843732, 0.844715, 0.844705,
                0.692192, 0.692191, 0.692191),
  sim_sec   = c(0.325246, 0.325246, 0.325246,
                0.166163, 0.165970, 0.165972,
                0.093445, 0.093445, 0.093445)
)
l1d$l1d_kB <- factor(l1d$l1d_kB, levels = c(16, 64, 128),
                     labels = c("16 kB", "64 kB", "128 kB"))

# ── numROB data ────────────────────────────────────────────────────────────────
rob <- data.frame(
  numROB    = c(32, 64, 256,   32, 64, 256,   32, 64, 256),
  benchmark = rep(benchmarks, each = 3),
  ipc       = c(0.673512, 0.693029, 0.701915,
                0.723159, 0.845048, 0.844051,
                0.611466, 0.690907, 0.692191),
  sim_sec   = c(0.338962, 0.329417, 0.325246,
                0.193868, 0.165905, 0.166101,
                0.105781, 0.093618, 0.093445)
)
rob$numROB <- factor(rob$numROB)

# ── helper ─────────────────────────────────────────────────────────────────────
make_plot <- function(df, x_col, y_col, x_lab, y_lab, title) {
  ggplot(df, aes_string(x = x_col, y = y_col,
                        color = "benchmark", group = "benchmark")) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 2.5) +
    labs(title = title, x = x_lab, y = y_lab, color = "Benchmark") +
    expand_limits(y = 0) +
    theme_bw(base_size = 13) +
    theme(legend.position = "right",
          plot.title = element_text(hjust = 0.5))
}

# ── 6 plots ────────────────────────────────────────────────────────────────────
p1 <- make_plot(iw,  "issuewidth", "ipc",
                "Issue Width", "IPC",
                "IPC vs Issue Width")

p2 <- make_plot(iw,  "issuewidth", "sim_sec",
                "Issue Width", "Tempo de execução (s)",
                "Tempo de execução vs Issue Width")

p3 <- make_plot(l1d, "l1d_kB", "ipc",
                "Tamanho da Cache L1D", "IPC",
                "IPC vs Tamanho da Cache L1D")

p4 <- make_plot(l1d, "l1d_kB", "sim_sec",
                "Tamanho da Cache L1D", "Tempo de execução (s)",
                "Tempo de execução vs Tamanho da Cache L1D")

p5 <- make_plot(rob, "numROB", "ipc",
                "Número de Entradas no ROB", "IPC",
                "IPC vs Número de Entradas no ROB")

p6 <- make_plot(rob, "numROB", "sim_sec",
                "Número de Entradas no ROB", "Tempo de execução (s)",
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
