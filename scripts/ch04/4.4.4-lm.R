rm(list = ls())
gc()
source("./environments.R")
.libPaths(libDir)
figDir <- file.path(outDir, "ch04")
if (!dir.exists(figDir)) {
  dir.create(figDir)
}
dataDir <- file.path(dataDir, "ch04")

pacman::p_load(
  rio,
  tidyverse
)

data <-
  rio::import(file.path(dataDir, "data-salary.txt"))
res_lm <-
  lm(Y ~ X, data = data)

X_new <-
  data.frame(X = 23:60)

conf_95 <-
  predict(
    res_lm,
    X_new,
    interval = "confidence",
    level = 0.95
  )
conf_95 <-
  data.frame(X_new, conf_95)

conf_50 <-
  predict(
    res_lm,
    X_new,
    interval = "confidence",
    level = 0.50
  )
conf_50 <-
  data.frame(X_new, conf_50)

pred_95 <-
  predict(
    res_lm,
    X_new,
    interval = "prediction",
    level = 0.95
  )
pred_95 <-
  data.frame(X_new, pred_95)

pred_50 <-
  predict(
    res_lm,
    X_new,
    interval = "prediction",
    level = 0.50
  )
pred_50 <-
  data.frame(X_new, pred_50)

p <-
  ggplot() +
  geom_ribbon(
    data = conf_95,
    aes(x = X, ymin = lwr, ymax = upr),
    alpha = 0.125
  ) +
  geom_ribbon(
    data = conf_50,
    aes(x = X, ymin = lwr, ymax = upr),
    alpha = 0.25
  ) +
  geom_line(data = conf_50, aes(x = X, y = fit), linewidth = 1) +
  geom_point(
    data = data,
    aes(x = X, y = Y),
    shape = 1
  ) +
  labs(x = 'X', y = 'Y') +
  coord_cartesian(xlim = c(22, 61), ylim = c(200, 1400)) +
  scale_y_continuous(
    breaks = seq(from = 200, to = 1400, by = 400)
  )
ggsave(
  file = file.path(figDir, "fig.4.3-left.pdf"),
  plot = p
)

p <-
  ggplot() +
  geom_ribbon(
    data = pred_95,
    aes(x = X, ymin = lwr, ymax = upr),
    alpha = 0.125
  ) +
  geom_ribbon(
    data = pred_50,
    aes(x = X, ymin = lwr, ymax = upr),
    alpha = 0.25
  ) +
  geom_line(data = pred_50, aes(x = X, y = fit), linewidth = 1) +
  geom_point(
    data = data,
    aes(x = X, y = Y),
    shape = 1
  ) +
  labs(x = 'X', y = 'Y') +
  coord_cartesian(xlim = c(22, 61), ylim = c(200, 1400)) +
  scale_y_continuous(
    breaks = seq(from = 200, to = 1400, by = 400)
  )
ggsave(
  file = file.path(figDir, "fig.4.3-right.pdf"),
  plot = p
)
