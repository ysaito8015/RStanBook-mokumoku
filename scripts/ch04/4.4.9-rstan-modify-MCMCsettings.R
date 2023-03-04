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

data <-
  list(
    N = nrow(d),
    X = d$X,
    Y = d$Y
  )

init <-
  function() {
    list(
      a = runif(1, -10, 10),
      b = runif(1, 0, 10),
      sigma = 10
    )
  }

# Compile model -----------------------
stan_model <-
  rstan::stan_model(
    file = file.path(modelDir, "4.4.5-model4-5.stan")
  )

# Run MCMC ----------------------------
fit.stan <-
  rstan::sampling(
    object = stan_model,
    data = data,
    pars = c("b", "sigma"),
    init = init,
    seed = 1234,
    chains = 3,
    iter = 1000,
    warmup = 200,
    thin = 2
  )

