#' widetolong
#' 
#' @description Fonction qui permet d'éclater un 
#' dataset pour avoir l'évolution de la réclamation à chaque année 
#' de développement. La fonction nous retourne les lignes sans doublons
#' @author Gabriel Crépeault-Cauchon
#' 
#' @param dt Jeu de données
#' @param pmtVar Préfixe des variables de paiement
#' @param statusVar Préfixe des variables qui indique le statut de la réclamation
#' @param dup.rm boolean : TRUE si on veut retirer les lignes duplicate
#' 
#' 
#' @export
widetolong <- function(dt, ldf, pmtVar = 'Pay', statusVar = 'Open'){
    require(tidyverse, quietly = T)
    ## Garder les features associés à la claim
    features <- dt %>% select(ClNr:RepDel, still, AY, max_dev_yr, real_ultimate)

    ## Garder le montant cumulatif
    cumulatif <- dt %>% 
        select(ClNr, AY, starts_with(pmtVar)) %>% 
        replace(is.na(.), 0) %>% 
        mutate(TotalPaid = reduce(select(., starts_with(pmtVar)), `+`)) %>% 
        select(ClNr, TotalPaid)
    
    # Split les colonnes Pay00, ..., Pay11 pour avoir une ligne par claim/année de dév.
    pmt <- dt %>% 
        select(ClNr, starts_with(pmtVar)) %>%
        gather(key, Pay, -ClNr) %>% 
        mutate(devYear = as.numeric(str_extract(key, '(\\d)+'))) %>% 
        arrange(ClNr) %>% 
        mutate(Paid = ave(Pay, ClNr, FUN = cumsum, na.rm = T)) %>% 
        select(ClNr, devYear,  Pay, Paid)
    
    # Split les colonnes Open00, ..., Open11 pour avoir une ligne par claim/année de dév.
    status <- dt %>% 
        select(ClNr, starts_with(statusVar)) %>%
        gather(key, Open, -ClNr) %>% 
        mutate(devYear = as.numeric(str_extract(key, '(\\d)+'))) %>% 
        arrange(ClNr) %>% 
        select(ClNr, devYear, Open)
    
    # On remet tout ensemble
    final <- features %>%
        left_join(pmt, by = "ClNr") %>%
        left_join(status, by = c("ClNr", "devYear")) %>% 
        left_join(cumulatif, by = "ClNr")
    
    # Vérifier si les variables dynamiques ont été modifiées (enlever doublon)
    # if (dup.rm) final %>% distinct(ClNr, Paid, Open, .keep_all = T) else final
}
