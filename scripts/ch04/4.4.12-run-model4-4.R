rm(list = ls())
gc()

source("./environments.R")
figDir <- file.path(outDir, "figures", "ch04")
if (!dir.exists(figDir)) {
    dir.create(figDir)
}
dataDir <- file.path(dataDir, "ch04")
if (!dir.exists(dataDir)) {
    dir.create(dataDir)
}
.libPaths(libDir)

# load packages
pacman::p_load(
    rio,
    tidyverse,
    rstan
)

# accerate culculation
rstan::rstan_options(auto_write = TRUE) # .rds ファイルへの保存
options(mc.cores = parallel::detectCores()) # 並列計算用のコアの自動指定

# Load data ---------------------------
d <-
  rio::import(file.path(dataDir, "data-salary.txt"))
X_new = 23:60
data <-
  list(
    N = nrow(d), # 20
    X = d$X,
    Y = d$Y,
    N_new = length(X_new), # 38
    X_new = X_new
  )

# Run MCMC ----------------------------
fit.stan <-
  rstan::stan(
    file = file.path(modelDir, "4.4.12-model4-4.stan"),
    data = data,
    seed = 1234
  )

mcmc_samples <-
  rstan::extract(fit.stan)

str(mcmc_samples)

# Define functions -------------------------------------
make.tibble.quantiles.mcmc <-
  function(x, y_mcmc) {
    quantiles <-
      apply(
        X = y_mcmc,
        MARGIN = 2, # indicates columns
        FUN = quantile,
        probs = c(0.025, 0.25, 0.50, 0.75, 0.975)
      ) %>%
      t()
    d <-
      cbind(
        X = x,
        quantiles
      ) %>%
      tibble::as_tibble()
    return(d)
  }

plot.5quantiles <-
  function (data) {
    p <-
      data %>%
      ggplot(aes(x = X, y =`50%`)) +
      theme_bw(base_size = 18) +
      geom_ribbon(
        aes(ymin = `2.5%`, ymax = `97.5%`),
        fill = "black",
        alpha = 1/6
      ) +
      geom_ribbon(
        aes(ymin = `25%`, ymax = `75%`),
        fill = "black",
        alpha = 2/6
      ) +
      geom_line(linewidth = 1)
    return(p)
  }

customize.ggplot.axis <-
  function(p) {
    p <-
      p + labs(x = "X", y = "Y")
    p <-
      p + scale_y_continuous(
        breaks = seq(from = 200, to = 1400, by = 400),
      )
    p <-
      p + coord_cartesian(xlim = c(22, 61), ylim = c(200, 1400))
    return(p)
  }

# Make plotting -------------------------------------------
d_estimates <-
  make.tibble.quantiles.mcmc(
    x = X_new,
    y_mcmc = mcmc_samples$y_base_new
  )
p <-
  d_estimates %>%
  plot.5quantiles() +
  geom_point(
    data = d,
    aes(x = X, y =Y),
    shape = 1,
    size = 3
  )
p <-
  customize.ggplot.axis(p)
ggsave(
  file = file.path(figDir, "fig.4.8-left-2.pdf"),
  plot = p
  # dpi = 300,
  # width = 4,
  # height = 3
)

d_estimates <-
  make.tibble.quantiles.mcmc(
    x = X_new,
    y_mcmc = mcmc_samples$y_new
  )
p <-
  d_estimates %>%
  plot.5quantiles() +
  geom_point(
    data = d,
    aes(x = X, y =Y),
    shape = 1,
    size = 3
  )
p <-
  customize.ggplot.axis(p)
ggsave(
  file = file.path(figDir, "fig.4.8-right-2.pdf"),
  plot = p
  # dpi = 300,
  # width = 4,
  # height = 3
)
