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

# Run MCMC ----------------------------
fit.stan <-
  rstan::stan(
    file = file.path(modelDir, "4.4.5-model4-5.stan"),
    data = data,
    seed = 1234
  )


# Save result -------------------------
save.image(
  file = file.path(dataDir, "result-model4-5.RData")
)
