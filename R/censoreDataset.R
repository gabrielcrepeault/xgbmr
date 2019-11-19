#' censoreDataset
#' 
#' @description Une fonction qui vient réduire l'information qu'on est censé avoir
#' de disponible à une certaine date d'évaluation
#' @author Gabriel Crépeault-Cauchon
#' 
#' @return Un datasets qui rend non-disponible certaines informations (qui sont normalement
#' non dispo à la date d'évaluation).
#' 
#' @param data Base de données utilisées. Doit avoir un certain format
#' @param evalYr Date d'évaluation
#' @param rep.value par quelle valeur on remplace les valeurs qu'on ne connaît pas?
#' @param keep.real.ultimate Indicateur pour dire si on veut ajouter une colonne real_ultimate, qui contiendra
#' la somme de tous les paiements faits (sur toutes les périodes de développement) pour chaque réclamation.
#' 
#' @export
censoreDataset <- function(data, evalYr, rep.value = NA) {
    require(tidyverse, quietly = T)
    # Helper inside function
    cacherVal <- function(value, colname, ay, eval_yr){
        num <- colname %>% str_extract('(\\d)+') %>% as.numeric()
        ifelse(eval_yr - ay >= num, value, rep.value)
    }
    
    ## Vérifier si la réclamation est encore ouverte. Ajouter une colonne pour le nombre d'année de dev
    ouvert <- data %>% 
        select(ClNr, AY, starts_with('Open')) %>% 
        gather(key, value, -ClNr, -AY) %>% 
        mutate(still = ifelse(key == paste0('Open', sprintf("%02d", pmax(evalYr - AY, 0))), 1, 0) * value) %>% 
        select(ClNr, still) %>% 
        group_by(ClNr) %>% 
        summarise_all(sum)
    
    ## Conserver le montant réel payé à l'ultime
    
    real_ultimate <- data %>% 
        select(ClNr, starts_with('Pay')) %>% 
        mutate(real_ultimate = reduce(select(., starts_with("Pay")), `+`)) %>% 
        select(ClNr, real_ultimate)
    
    
    # Seulement les features
    features <- data %>% 
        select(-starts_with('Pay'), -starts_with('Open'))
    
    # Pay<>
    pmt <- data %>% 
        select(ClNr, AY, starts_with('Pay')) %>% 
        gather(Payment, amount, -AY, -ClNr) %>%
        mutate(adj = cacherVal(amount, Payment, AY, evalYr)) %>% 
        select(-amount) %>% 
        spread(key = Payment, value = adj)
    
    # Open<>
    status <- data %>% 
        select(ClNr, AY, starts_with('Open')) %>% 
        gather(Status, type, -AY, -ClNr) %>%
        mutate(adj = cacherVal(type, Status, AY, evalYr)) %>% 
        select(-type) %>% 
        spread(key = Status, value = adj)
    
    # retourner le dataset final
    features %>% 
        left_join(pmt, by = "ClNr") %>% 
        left_join(status, by = "ClNr") %>% 
        left_join(ouvert, by = "ClNr") %>% 
        left_join(real_ultimate, by = 'ClNr') %>% 
        select(-AY.x, -AY.y) %>% 
        mutate(max_dev_yr = pmax(evalYr - AY, 0)) 
}