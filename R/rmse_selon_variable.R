#' rmse_selon_variable
#' 
#' @description Fonction wrapper pour obtenir facilement le graphique du RMSE moyen en
#' groupant sur l'une des variables explicatives. Le graphique contient aussi un histogramme
#' mentionnant le nombre d'observations par catégorie de la variable explicative.
#' 
#' @param pred Un data.frame contenant, au minimum : 
#' - "truth" : la vraie valeur à prédire
#' - "response" : valeur prédite
#' - "var" : la variable explicative qu'on veut illustrer sur le graphique.
#' 
#' @param var Nom de la variable (avec syntaxe tidyverse) qu'on veut grouper
#' @param show.table Possbilité de print le data.frame aggrégé (qui présente le nombre
#' d'observation et le RMSE moyen) qui a servi à produire le graphique.
#' 
#' 
#' @export
rmse_selon_variable <- function(pred, var, show.table = F){
    var <- enquo(var)
    data <- pred %>% 
        group_by(!!var) %>% 
        summarise(
            rmse = sqrt(mean((truth - response)^2)),
            nobs = n()
        )
    if (show.table) print(data)
    
    ## Output le ggplot des RMSE avec la fréquence de chaque variable
    rmse_global <- sqrt(mean((pred$truth - pred$response)^2))
    data %>% 
        ggplot(aes(x = !!var)) + 
        geom_point(aes(y = rmse)) + 
        geom_bar(aes(y = nobs,
                     fill = paste0("Nombre d'observations totale par ",
                                   rlang::as_name(var))
        ), 
        stat = 'identity', alpha = .2) + 
        geom_hline(aes(col = 'RMSE global', yintercept = rmse_global)) + 
        theme(legend.position = 'bottom', legend.direction = 'vertical') + 
        labs(fill = NULL, col = NULL, y = "RMSE")
}
