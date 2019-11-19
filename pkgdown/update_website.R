## Source file to update pkg_down
## Cmd+Shift+B : Build le package
## CMd+Shift+D : Build la documentation avec Roxygen
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
library(devtools)
library(xgbmr)
library(roxygen2)
library(pkgdown)

## Mettre à jour le site web pkgdown ####
pkgdown::build_site()

black_box_explain()
## Rendre disponible sous un fichier .tar le package ####
build()

SimulatedIndClaims %>% dim
SimulatedIndClaims <- dt
save(SimulatedIndClaims, file = '../data/simulated-individual-claims.rda')
xgbmr::dt
yo <- data('simulated-individual-claims')


## Si le package devient public, on pourra partager le repo
# install_github(repo = 'gabrielcrepeault/ACT2101_A2019', subdir = 'xgbmr')


## Mettre à jour les vignettes ####
devtools::build_vignettes()









