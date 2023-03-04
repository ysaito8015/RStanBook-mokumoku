rm(list = ls())
gc()

source("./environments.R")
figDir <- file.path(outDir, "figures", "ch04")
if (!dir.exists(figDir)) {
  dir.create(figDir)
}
tableDir <- file.path(outDir, "tables", "ch04")
if (!dir.exists(tableDir)) {
  dir.create(tableDir)
}
dataDir <- file.path(dataDir, "ch04")
if (!dir.exists(dataDir)) {
  dir.create(dataDir)
}
.libPaths(libDir)

# load packages
library(rstan)
pacman::p_load(
  rio,
  tidyverse,
  ggmcmc
)

# Load data ---------------------------
load(
  file = file.path(dataDir, "result-model4-5.RData")
)

# Write table -------------------------
summary(fit.stan)$summary %>%
  data.frame() %>%
  write.table(
    file = file.path(tableDir, "fit-summary.txt"),
    sep = '\t',
    quote = FALSE,
    col.names = NA
  )

# Plot data ---------------------------
fit.stan %>%
  ggs(
    inc_warmup = TRUE,
    stan_include_auxiliar = TRUE
  ) %>%
  ggmcmc(
    file = file.path(figDir, "fig.4.4-fit.stan-traceplot.pdf"),
    plot = "traceplot"
  )

fit.stan %>%
  ggs() %>%
  ggmcmc(
    file = file.path(figDir, "fit.stan-ggmcmc.pdf")
  )

