#' Black Box explain
#'
#'
#' @author Gabriel Crépeault-Cauchon
#'
#' @description Shiny app permettant d'analyser l'interprétabilité et les prédictions obtenues
#' d'un modèle (en important le modèle mlr et le jeu de données dans l'application)
#'
#'
#' @export
#' @export
black_box_explain <- function() {
    appDir <- system.file("shiny-app", "black_box_explain", package = "xgbmr")
    if (appDir == "") {
        stop("Could not find example directory. Try re-installing `mypackage`.", call. = FALSE)
    }

    shiny::runApp(appDir, display.mode = "normal")
}
