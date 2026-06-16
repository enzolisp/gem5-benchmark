library(ggplot2)

df <- data.frame(
  cache     = rep(c("8 kB", "16 kB", "32 kB", "64 kB"), each = 3),
  benchmark = rep(c("matmul", "collatz", "MAC"), 4),
  miss_pct  = c(
    0.008336, 0.000101, 0.017694,   # 8 kB
    0.005850, 0.000089, 0.000270,   # 16 kB
    0.005843, 0.000088, 0.000004,   # 32 kB (fixed)
    0.000350, 0.000088, 0.000004    # 64 kB
  ) * 100,
  sim_sec   = c(
    0.028589, 0.006952, 0.256308,   # 8 kB
    0.028273, 0.006951, 0.256306,   # 16 kB
    0.028273, 0.006951, 0.256305,   # 32 kB
    0.027660, 0.006951, 0.256305    # 64 kB
  )
)

df$cache <- factor(df$cache, levels = c("8 kB", "16 kB", "32 kB", "64 kB"))

p <- ggplot(df, aes(x = cache, y = miss_pct,
                    color = benchmark, group = benchmark)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 3) +
  geom_text(aes(label = round(miss_pct, 4)), vjust = -0.8, size = 3,
            show.legend = FALSE) +
  labs(
    title = "Miss Rate da L1D por Tamanho de Cache",
    x     = "Tamanho da Cache L1D",
    y     = "Miss Rate L1D (%)",
    color = "Benchmark"
  ) +
  theme_bw(base_size = 13) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5))

ggsave("plot_miss_rate.png", p, width = 7, height = 4.5, dpi = 150)
cat("Salvo: plot_miss_rate.png\n")
