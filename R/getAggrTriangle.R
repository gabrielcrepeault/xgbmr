#' getAggrTriangle
#' 
#' @description Fonction qui permet de prendre un datasets provenant de la machine à simulation de
#' <mettre le nom de l'auteur> et d'en obtenir un triangle de paiements cumulatifs (utilisé
#' par la suite dans des techniques ChainLadder).
#' 
#' @param data jeu de données provenant des données simulées. Au minimum, le jeu de données doit avoir
#' une colonne AY (Accident Year) et des colonnes de paiement incrémentaux (avec un préfixe commun, e.g. Pay<XX>)
#' @param pmtVar préfixe dans le nom des variables du dataset qui contiennent les paiements.
#' 
#' @export
getAggrTriangle <- function(data, pmtVar = 'Pay'){
    require(dplyr, quietly = T)
    require(ChainLadder, quietly = T)
    data %>% 
        select(AY, starts_with(pmtVar)) %>% 
        gather('pmtCol', 'Payment', -AY) %>% 
        as.triangle(origin = 'AY', dev = 'pmtCol', value = 'Payment') %>% 
        na_if(0) %>% 
        apply(1, cumsum) %>%
        t() %>% 
        as.triangle()
}