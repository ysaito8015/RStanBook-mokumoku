pkgs <-
    c(
        "tidyverse",
        "bayesplot",
        "ggmcmc",
        "rstan",
        "pacman",
        "rio"
)

source("./environments.R")
.libPaths(libDir)


install.packages(
    c("devtools", "BH", "remotes"),
    lib = libDir,
    contriburl = c(
        contrib.url("http://r-forge.r-project.org","source"),
        contrib.url("https://cran.rstudio.com/","source")
    ),
    destdir = pkgDir,
    type = "source",
    dependencies = c("Depends", "Imports", "LinkingTo"),
    INSTALL_opts = "--no-multiarch"
)

install.packages(
    pkgs,
    lib = libDir,
    contriburl = c(
        contrib.url("http://r-forge.r-project.org","source"),
        contrib.url("https://cran.rstudio.com/","source")
    ),
    destdir = pkgDir,
    type = "source",
    dependencies = c("Depends", "Imports", "LinkingTo"),
    INSTALL_opts = "--no-multiarch"
)
