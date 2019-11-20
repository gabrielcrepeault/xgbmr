## Source file to update pkg_down
## Cmd+Shift+B : Build le package
## CMd+Shift+D : Build la documentation avec Roxygen
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
library(devtools)
library(xgbmr)
library(roxygen2)
library(pkgdown)
setwd('../')
## Mettre à jour le site web pkgdown ####
pkgdown::build_site()

## Rendre disponible sous un fichier .tar le package ####
build()
getwd()

## transformer un rmd en vignette pour le package
use_data(fit_a)
use_data(fit_b)
use_data(fit_c)

# use_data(bs_pred_a)
# use_data(bs_pred_b)
# use_data(bs_pred_c)

## Si le package devient public, on pourra partager le repo
# install_github(repo = 'gabrielcrepeault/ACT2101_A2019', subdir = 'xgbmr')


## Mettre à jour les vignettes ####
devtools::build_vignettes()









