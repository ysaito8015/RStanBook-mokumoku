source("environments.R")
.libPaths(libDir)
figDir <- file.path(outDir, "figures", "ch04")
if (!dir.exists(figDir)) {
  dir.create(figDir)
}
dataDir <- file.path(dataDir, "ch04")

pacman::p_load(
  tidyverse,
  rio
)

data <-
  rio::import(file.path(dataDir, "data-salary.txt"))

p <-
  data %>%
  ggplot() +
  aes(x = X, y = Y) +
  geom_point()

ggsave(
  file.path(figDir, "fig.4.2.pdf"),
  plot = p
)
