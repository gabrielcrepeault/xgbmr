#' bsPredDistribution
#'
#' @author Gabriel Crépeault-Cauchon
#'
#'
#' @description Fonction wrapper qui effectue un rééchantillonage Bootstrap sur le
#' training set et prédit le validation set B fois. De cette façon, on obtient B estimations
#' pour chaque observation dans le validation set.
#'
#' @param learner Leaner mlr utilisé pour fiter les modèles
#' @param train_tsk Tâche mlr d'entrainement
#' @param train_tsk Tâche mlr de validation
#' @param B Nombre d'échantillonage Bootstrap à effectuer. Défaut = 100
#'
#' @return Un data.frame contenant une ligne par observations, une colonne par prédiction
#' Bootstrap (i.e. n lignes x B colonnes).
#'
#'
#' @export
bsPredDistribution <- function(learner, train_tsk, test_tsk, B = 100){
    ## Un gros wrapper pour obtenir la distribution prédictive d'un modèle
    require(mlr)
    require(tidyverse)

    ## Resampling via mlr
    bs_res <- makeResampleDesc('Bootstrap', stratify.cols = "devYear", iters = B)
    bs_models <- resample(learner = learner, task = train_tsk, resampling = bs_res,
                          models = T, keep.pred = F)$models
    names(bs_models) <- paste0('fit_', 1:B)

    ## Obtenir les prédictions des B modèles sur le validation set
    predictions <- map_df(bs_models, function(fit){
        predict(fit, task = test_tsk)$data$response
    })

    # Retourner une liste avec les prédictions et le bootstrap
    list(predictions = predictions, bs_models = bs_models)
}
