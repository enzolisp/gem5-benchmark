library(ggplot2)

df <- data.frame(
  benchmark = c("matmul", "MAC"),
  ipc_O0    = c(1.089217, 0.799321),
  ipc_O2    = c(0.670664, 0.745769),
  insts_O0  = c(61590269,  409739372),
  insts_O2  = c(7189898,   163938676),
  sec_O0    = c(0.028273,  0.256305),
  sec_O2    = c(0.005360,  0.109913)
)

df$speedup       <- df$sec_O0 / df$sec_O2
df$insts_reducao <- (1 - df$insts_O2 / df$insts_O0) * 100  # % redução de instruções
df$ipc_delta     <- df$ipc_O2 - df$ipc_O0

# ── Plot 1: Speedup vs Redução de instruções ──────────────────────────────────
p1 <- ggplot(df, aes(x = insts_reducao, y = speedup, color = benchmark)) +
  geom_point(size = 5) +
  geom_text(aes(label = sprintf("%s\n%.2fx", benchmark, speedup)),
            vjust = -0.9, size = 3.5, show.legend = FALSE) +
  labs(
    title = "Speedup vs Redução de Instruções (O0 → O2)",
    x     = "Redução de instruções (%)",
    y     = "Speedup (tempo_O0 / tempo_O2)",
    color = "Benchmark"
  ) +
  expand_limits(y = 0, x = 0) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  scale_x_continuous(expand = expansion(mult = c(0.05, 0.2))) +
  theme_bw(base_size = 13) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5))

# ── Plot 2: IPC e Speedup lado a lado por benchmark ──────────────────────────
df_long_ipc <- data.frame(
  benchmark = rep(df$benchmark, 2),
  opt       = rep(c("O0", "O2"), each = nrow(df)),
  ipc       = c(df$ipc_O0, df$ipc_O2)
)

p2 <- ggplot(df_long_ipc, aes(x = benchmark, y = ipc, fill = opt)) +
  geom_col(position = "dodge", width = 0.6) +
  geom_text(aes(label = round(ipc, 3)),
            position = position_dodge(width = 0.6),
            vjust = -0.5, size = 3.2) +
  labs(
    title = "IPC: O0 vs O2",
    x     = "Benchmark",
    y     = "IPC",
    fill  = "Otimização"
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  theme_bw(base_size = 13) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5))

# ── Plot 3: Número de instruções O0 vs O2 ────────────────────────────────────
df_long_insts <- data.frame(
  benchmark = rep(df$benchmark, 2),
  opt       = rep(c("O0", "O2"), each = nrow(df)),
  insts     = c(df$insts_O0, df$insts_O2) / 1e6
)

p3 <- ggplot(df_long_insts, aes(x = benchmark, y = insts, fill = opt)) +
  geom_col(position = "dodge", width = 0.6) +
  geom_text(aes(label = sprintf("%.1fM", insts)),
            position = position_dodge(width = 0.6),
            vjust = -0.5, size = 3.2) +
  labs(
    title = "Total de Instruções: O0 vs O2",
    x     = "Benchmark",
    y     = "Instruções (milhões)",
    fill  = "Otimização"
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  theme_bw(base_size = 13) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5))

ggsave("speedup1_scatter.png",  p1, width = 6,   height = 4.5, dpi = 150)
ggsave("speedup2_ipc_bar.png",  p2, width = 6,   height = 4.5, dpi = 150)
ggsave("speedup3_insts_bar.png", p3, width = 6,  height = 4.5, dpi = 150)

cat("Salvos:\n")
cat("  speedup1_scatter.png  — speedup vs reducao de instrucoes\n")
cat("  speedup2_ipc_bar.png  — IPC O0 vs O2\n")
cat("  speedup3_insts_bar.png — total instrucoes O0 vs O2\n")
