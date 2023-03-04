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
  rstan,
  ggmcmc,
  patchwork
)


# Load data ---------------------------
load(
  file = file.path(dataDir, "result-model4-5.RData")
)

# Check data --------------------------
mcmc_samples <-
  rstan::extract(fit.stan)

head(mcmc_samples$b)

quantile(mcmc_samples$b, probs = c(0.025, 0.975))

d_mcmc <- # joint distribution of (a, b, sigma)
  tibble(
    a = mcmc_samples$a,
    b = mcmc_samples$b,
    sigma = mcmc_samples$sigma
  )

head(d_mcmc)

N_mcmc <- length(mcmc_samples$lp__)
y50_base <- # basement salary at age 50
  mcmc_samples$a + mcmc_samples$b * 50
# new random samples from normal distribution at age 50
y50 <-
  rnorm(
    n = N_mcmc,
    mean = y50_base,
    sd = mcmc_samples$sigma
  )
d_mcmc <- # joint distribution of (a,b,sigma) at age 50
  tibble(
    a = mcmc_samples$a,
    b = mcmc_samples$b,
    sigma = mcmc_samples$sigma,
    y50_base,
    y50
  )

head(d_mcmc)


# Plot data --------------------------
x_range <- c(-420, 210)
y_range <- c(14.5, 29)
x_breaks <- seq(-400, 200, 200)
y_breaks <- seq(15, 25, 5)

p_xy <-
  d_mcmc %>%
  ggplot() +
  aes(x = a, y = b) +
  theme_bw(base_size = 18) +
  coord_cartesian(xlim = x_range, ylim = y_range) +
  geom_point(alpha = 1/4, size = 2, shape = 1) +
  scale_x_continuous(breaks = x_breaks) +
  scale_y_continuous(breaks = y_breaks)

p_x <-
  d_mcmc %>%
  ggplot() +
  aes(x = a) +
  theme_bw(base_size = 18) +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  coord_cartesian(xlim = x_range) +
  geom_histogram(
    # aes(y = ..density..),
    # https://stackoverflow.com/questions/74756655/how-to-replace-the-dot-dot-notation-in-ggplot2geom-histogramy-density
    aes(y = after_stat(!!str2lang("density"))),
    colour = 'black',
    fill = 'white'
  ) +
  geom_density(alpha = 0.3, fill = 'gray20') +
  scale_x_continuous(breaks = x_breaks) +
  labs(x = '', y = '')

p_y <-
  d_mcmc %>%
  ggplot() +
  aes(x = b) +
  theme_bw(base_size = 18) +
  theme(
    axis.title.y = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  coord_flip(xlim = y_range) +
  geom_histogram(
    # aes(y = ..density..),
    # https://stackoverflow.com/questions/74756655/how-to-replace-the-dot-dot-notation-in-ggplot2geom-histogramy-density
    aes(y = after_stat(!!str2lang("density"))),
    colour = 'black',
    fill = 'white'
  ) +
  geom_density(alpha = 0.3, fill = 'gray20') +
  scale_x_continuous(breaks = y_breaks) +
  labs(x = '', y = '')

p <-
  patchwork::wrap_plots(
    p_x,
    plot_spacer(),
    p_xy,
    p_y,
    nrow = 2,
    widths = c(1, 0.3),
    heights = c(0.3, 1)
  )

ggsave(
  file.path(figDir, "fig.4.7.pdf"),
  plot = p,
  dpi = 250,
  width = 6,
  height = 6
)


