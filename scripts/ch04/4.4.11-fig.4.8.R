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


# Load data ---------------------------
load(
  file = file.path(dataDir, "result-model4-5.RData")
)

# Check data --------------------------
mcmc_samples <-
  rstan::extract(fit.stan)

X_new <- 23:60
N_X <- length(X_new)
N_mcmc <- length(mcmc_samples$lp__)

set.seed(1234)
mat <- matrix(nrow = N_mcmc, ncol = N_X)

# table of basement salaries from model equation
# columns : age from 23 to 60
# rows : basement salaties based on mcmc samples from 1 to 4000
y_base_mcmc <-
  mat %>%
  #as.data.frame()
  tibble::as_tibble()
# table of new random values from the normal distribution
# with mu = mean of y_base = model equation at specific age
# e.g. sum(y_base_mcmc$age23) / 4000
# and sigma = sigma from mcmc samples
# at specific age X_new[i]
# columns : age from 23 to 60
# rows : new random values from 1 to 4000
y_pred_new <-
  mat %>%
  #as.data.frame()
  tibble::as_tibble()
for (i in 1:N_X) {
  y_base_mcmc[ , i] <-
    mcmc_samples$a + mcmc_samples$b * X_new[i]
  mu_base_mcmc_at_age <-
    y_base_mcmc %>%
    .[ , i] %>%
    summarize(
      across(.cols = where(is.numeric), .fns = mean)
    ) %>%
    as.numeric()
  y_pred_new[ , i] <-
    rnorm(
      n = N_mcmc,
      mean = mu_base_mcmc_at_age,
      sd = mcmc_samples$sigma
    )
}

quantiles <-
  apply(
    X = y_base_mcmc,
    MARGIN = 2, # indicates columns
    FUN = quantile,
    probs = c(0.025, 0.25, 0.50, 0.75, 0.975)
  ) %>%
  t()
d_estimates <-
  cbind(
    X = X_new,
    quantiles
  ) %>%
  tibble::as_tibble()


# Plot data --------------------------
# plot of basement salaries from model equation
# Bayes confidence interval
p <-
  d_estimates %>%
  ggplot() +
  theme_bw(base_size = 18) +
  geom_ribbon(
    aes(
      x = X,
      ymin = `2.5%`,
      ymax = `97.5%` 
    ),
    fill = "black",
    alpha = 1/6
  ) +
  geom_ribbon(
    aes(
      x = X,
      ymin = `25%`,
      ymax = `75%`
    ),
    fill = "black",
    alpha = 2/6
  ) +
  geom_line(
    aes(x = X, y = `50%`),
    linewidth = 1
  ) +
  geom_point(
    data = d,
    aes(x = X, y = Y),
    shape = 1,
    size = 3
  ) +
  coord_cartesian(xlim = c(22, 61), ylim = c(200, 1400)) +
  scale_y_continuous(
    breaks = seq(from = 200, to = 1400, by =400)
  ) +
  labs(y = "Y")


ggsave(
  file.path(figDir, "fig.4.8-left.pdf"),
  plot = p
  #dpi = 300,
  #width = 4,
  #height = 3
)


# Plot y_pred_new ---------------------------
# Bayes prediction interval

quantiles <-
  apply(
    X = y_pred_new,
    MARGIN = 2, # indicates columns
    FUN = quantile,
    probs = c(0.025, 0.25, 0.50, 0.75, 0.975)
  ) %>%
  t()
d_estimates <-
  cbind(
    X = X_new,
    quantiles
  ) %>%
  tibble::as_tibble()

# plot of basement salaries from new random values
p <-
  d_estimates %>%
  ggplot() +
  theme_bw(base_size = 18) +
  geom_ribbon(
    aes(
      x = X,
      ymin = `2.5%`,
      ymax = `97.5%` 
    ),
    fill = "black",
    alpha = 1/6
  ) +
  geom_ribbon(
    aes(
      x = X,
      ymin = `25%`,
      ymax = `75%`
    ),
    fill = "black",
    alpha = 2/6
  ) +
  geom_line(
    aes(x = X, y = `50%`),
    size = 1
  ) +
  geom_point(
    data = d,
    aes(x = X, y = Y),
    shape = 1,
    size = 3
  ) +
  coord_cartesian(xlim = c(22, 61), ylim = c(200, 1400)) +
  scale_y_continuous(
    breaks = seq(from = 200, to = 1400, by =400)
  ) +
  labs(y = "Y")


ggsave(
  file.path(figDir, "fig.4.8-right.pdf"),
  plot = p
  #dpi = 300,
  #width = 4,
  #height = 3
)
