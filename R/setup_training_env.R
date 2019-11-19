#' setup_training_env
#'
#' @description Monter un dossier avec des sous-dossier pour organiser
#' l'entrainement d'un modèle
#'
#' @param model_name
#'
#'
#'
#'
#' @export
setup_training_env <- function(model_name){
    root <- file.path('models', model_name)
    if (!dir.exists(root)){
        cat(paste0("Initialisation du dossier pour le modèle '", model_name, "' ... \n"))
        cat("Voir le fichier LOGFILE créé pour comprendre la structure.")
        dir.create(root)
        write(x = c(
            paste0("Modèle : ", model_name),
            "-> Le dossier lrns/ contient les learners MLR intermédiaires (à chaque étape du tuning).",
            "-> Le dossier plots/ contient une représentation visuelle du processus de tuning pour chaque paramètre.",
            "-> le fichier final .rda produit dans ce répertoire est le modèle xgboost avec paramètres optimaux."
        ),
        file = file.path(root, "LOGFILE.txt"))
        dir.create(file.path(root, "plots")) # Sous-dossier des graphiques
        dir.create(file.path(root, "lrns")) # sous-dossier des objets R contenant le tuning
        dir.create(file.path(root, "pred")) # sous-dossier pour ce qui a trait aux prédictions
        dir.create(file.path(root, "interpretability")) # graphique de feature imp., PDP/ICE, etc.
    }
}
