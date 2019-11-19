#' getLDF
#' 
#' Fonction qui permet d'obtenir les age-to-age developpement factor (ldf) à partir
#' d'un triangle aggrégé
#' 
#' @param tri Un object triangle du package ChainLadder
#' @param tailLDF hypothèse prise pour le dernier LDF calculé (tail), soit le
#' développement final
#' @param output Chaine de caractères pour préciser le type d'output désiré (seulement
#' les age-to-age ratios 'ata', seulement les LDF 'ldf' ou une liste contenant les deux 'both')
#' 
#' @export
getLDF <- function(tri, tailLDF = 1, output = 'ldf', dec = 4){
    require(ChainLadder, quietly = T)
    # Validation des paramètres entrés
    if (!is(tri, 'triangle'))
        stop("L'objet tri doit être un triangle ChainLadder.")
    if (!output %in% c('ata', 'ldf', 'both'))
        stop(paste0('La valeur output = ', output, ' nest pas reconnue.'))
    # On calcule les age-to-age link ratios
    ata_lr <- c(attr(ata(tri), "vwtd"), tail = 1.05)
    # On calcule les LDF cumulatifs. La première position de ce vecteur correspond au déve
    ldf <- rev(cumprod(rev(ata_lr))) %>% round(dec)
    names(ldf) <- colnames(tri)
    if (output == 'ata')
        ata_lr
    else if (output == 'ldf')
        ldf
    else
        list(ata = ata_lr, ldf = ldf)
}
