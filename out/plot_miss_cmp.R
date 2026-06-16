library(ggplot2)

cache_levels  <- c("8 kB", "16 kB", "32 kB", "64 kB")
cache_labels  <- cache_levels

df <- data.frame(
  cache     = rep(factor(cache_levels, levels = cache_levels), 4),
  benchmark = rep(c("matmul", "MAC"), each = 4, times = 2),
  opt       = rep(c("O0", "O2"), each = 8),
  miss_pct  = c(
    # O0 matmul
    0.008336, 0.005850, 0.005843, 0.000350,
    # O0 MAC
    0.017694, 0.000270, 0.000004, 0.000004,
    # O2 matmul
    0.043933, 0.032668, 0.032632, 0.002497,
    # O2 MAC
    0.081941, 0.001766, 0.000011, 0.000010
  ) * 100
)

df$group <- paste(df$benchmark, df$opt)

p <- ggplot(df, aes(x = cache, y = miss_pct,
                    color = benchmark, linetype = opt,
                    group = group)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 3) +
  geom_text(aes(label = round(miss_pct, 3)),
            vjust = -0.8, size = 2.8, show.legend = FALSE) +
  labs(
    title    = "Miss Rate L1D por Tamanho de Cache — O0 vs O2",
    x        = "Tamanho da Cache L1D",
    y        = "Miss Rate L1D (%)",
    color    = "Benchmark",
    linetype = "Otimização"
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18))) +
  expand_limits(y = 0) +
  theme_bw(base_size = 13) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5))

ggsave("plot_miss_cmp.png", p, width = 7, height = 4.5, dpi = 150)
cat("Salvo: plot_miss_cmp.png\n")
