# Implémentation en R d'un modèle de micro-réserve utilisant l'algorithme XGBoost.
Ce package a pour objectif de contenir tout le matériel nécessaire afin de pouvoir reproduire le projet de recherche de Gabriel Crépeault-Cauchon effectué pour le cours ACT-2101 au cours de la session d'automne 2019 à l'Université Laval.

## Résumé du projet de recherche
Le projet de recherche avait pour but de reproduire le modèle de Duval&Pigeon, 2019 , qui propose d'utiliser l'algorithme XGBoost afin de prédire le montant payé à l'ultime d'une réclamation en assurance, afin de pouvoir faire une estimation de la réserve individuelle à appliquer. Dans le cadre du projet de recherche, le modèle a été implémenté avec R sur les données simulées de Gabrielli/Wuthrich:2018

## Installation du package
Pour l'instant, le package n'est pas accessible depuis le CRAN. Il est toutefois possible de le télécharger sur votre session R avec la commande suivante : 

```r
devtools::install_github(repo = "gabrielcrepeault/xgbmr")
```

## Notes sur la documentation
Dans l'éventualité où ce package pourrait être publié sur le CRAN, la partie de la documentation des différents éléments du package a été faite en anglais. Ce site web sert uniquement à supporter le rapport du projet de recherche.


## Éléments contenus dans le package `xgbmr`
* Fonctions personnalisées, principalement utilisée dans les chapitres implémentation et résultats
* Fonction *helper* qui permettent de faciliter le *tuning* d'un modèle XGBoost. Ces fonctions peuvent être réutilisés pour ajuster un modèle XGBoost dans un tout autre contexte.
* Application shiny **Black Box Explain**, qui utilise les principales fonctions du package `iml` afin de visualiser (de façon interactive) l'interprétabilité du modèle (Feature importance, PDP/ICE curves, LIME models, pred-on-truth graphs, etc).
