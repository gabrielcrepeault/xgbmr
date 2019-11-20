## Source file to update pkg_down
## Cmd+Shift+B : Build le package
## CMd+Shift+D : Build la documentation avec Roxygen
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
setwd('../')
library(devtools)
library(xgbmr)
library(roxygen2)
library(pkgdown)

## Rendre disponible sous un fichier .tar le package ####
build()

## transformer un rmd en vignette pour le package




## Update les objets R et dataset dans le package ####
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
SimulatedIndClaims <- read.csv('../../ACT2101_A2019/data/simulated-individual-claims.csv')
fit_a <- read_rds('../../ACT2101_A2019/R/models/modele_a_long/modele_a_long.rda')
fit_b <- read_rds('../../ACT2101_A2019/R/models/modele_b_long/modele_b_long.rda')
fit_c <- read_rds('../../ACT2101_A2019/R/models/modele_c_long/modele_c_long.rda')
bs_pred_a <- read.csv('../../ACT2101_A2019/R/models/modele_a_long/pred/boostrap20.csv')
bs_pred_b <- read.csv('../../ACT2101_A2019/R/models/modele_b_long/pred/boostrap20.csv')
bs_pred_c <- read.csv('../../ACT2101_A2019/R/models/modele_c_long/pred/boostrap20.csv')

## Ajouter au package
use_data(SimulatedIndClaims)
use_data(fit_a)
use_data(fit_b)
use_data(fit_c)
use_data(bs_pred_a)
use_data(bs_pred_b)
use_data(bs_pred_c)

## Mettre à jour les vignettes ####
devtools::build_vignettes()

## Mettre à jour le site web pkgdown ####
setwd("../")
pkgdown::build_site()
