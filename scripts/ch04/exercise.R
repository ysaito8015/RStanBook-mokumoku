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
modelDir <- file.path(modelDir, "ch04")
if (!dir.exists(modelDir)) {
  dir.create(modelDir)
}
.libPaths(libDir)

# load packages
pacman::p_load(
  rio,
  tidyverse,
  rstan
)

# accerate culculation
rstan::rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


# Create data ---------------------------
set.seed(123)
N1 <- 30
N2 <- 20
Y1 <- rnorm(n = N1, mean = 0, sd = 5)
Y2 <- rnorm(n = N2, mean = 1, sd = 4)

y1 <- data.frame(group = 1, Y = Y1)
y2 <- data.frame(group = 2, Y = Y2)
data <- rbind(y1, y2)
data$group <- as.factor(data$group)


d <-
  list(
    N1 = N1,
    N2 = N2,
    Y1 = Y1,
    Y2 = Y2
  )

# Check data --------------------------
p <-
  tibble(Y1) %>%
  ggplot() +
  aes(x = Y1) %>%
  geom_density()
ggsave(
  file.path(figDir, "fig.exercise-Y1-density.pdf"),
  plot = p
)
p <-
  tibble(Y2) %>%
  ggplot() +
  aes(x = Y2) %>%
  geom_density()
ggsave(
  file.path(figDir, "fig.exercise-Y2-density.pdf"),
  plot = p
)

p <-
  data %>%
  ggplot() +
  aes(
    x = group,
    y = Y,
    group = group,
    col = group
  ) +
  geom_boxplot(outlier.shape = NA, alpha = 0.3) +
  geom_point(
    position = position_jitter(width = 0.1, height = 0),
    size = 2
  )
ggsave(
  file.path(figDir, "fig.exercise-boxplot.pdf"),
  plot = p
)

# Execute MCMC -----------------------------------
fit.stan <-
  stan(
    file = file.path(modelDir, "4-exercise01.stan"),
    data = d,
    seed = 1234
  )

mcmc_samples <-
  rstan::extract(fit.stan)
mu_Y1 <- mcmc_samples$mu_Y1
mu_Y2 <- mcmc_samples$mu_Y2
# diff <- mu_Y2 - mu_Y1
N_mcmc <- length(mcmc_samples$lp__)

# count = 0
# for (i in 1:N_mcmc) {
#   if (diff[i] > 0) {
#     count = count + 1
#   }
# }
# 
# count/N_mcmc

prob <- mean(mu_Y1 < mu_Y2)
# prob <- sum(mu_Y1 < mu_Y2) / N_mcmc

fit.stan <-
  stan(
    file = file.path(modelDir, "4-exercise02.stan"),
    data = d,
    seed = 1234
  )

mcmc_samples <-
  rstan::extract(fit.stan)
mu_Y1 <- mcmc_samples$mu_Y1
mu_Y2 <- mcmc_samples$mu_Y2
# diff <- mu_Y2 - mu_Y1
N_mcmc <- length(mcmc_samples$lp__)

prob <- mean(mu_Y1 < mu_Y2)
# prob <- sum(mu_Y1 < mu_Y2) / N_mcmc

