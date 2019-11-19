#' tune_nrounds
#' 
#' TODO : description de la fonction et ses paramètres
#' @description Fonction wrapper pour utilier la fonction xgb.cv du package xgboost
#' 
#' 
#' @export
tune_nrounds <- function(learner, task, root, iters = 1000, plot = T, export = T,
                         early_stopping_rounds = 10){
    result <- list()
    require(xgboost, quietly = T)
    require(tidyverse, quietly = T)
    
    ## Créer la matrice DMatrix
    trainDM <- xgboost::xgb.DMatrix(data = as.matrix(task$env$data), 
                                    label = pull(task$env$data, var = task$task.desc$target))
    
    ## Effectuer la CV5 à chaque nrounds
    result$tuning <- xgb.cv(params = learner$par.vals,
                            nrounds = iters,
                            early_stopping_rounds = early_stopping_rounds,
                            data = trainDM, nfold = 5, maximize = F,
                            verbose = T, print_every_n = 50)
    
    ## Graphique de la procédure. À sauvegarder
    if (plot){
        result$plot <- result$tuning$evaluation_log %>% 
            select(iter, contains('mean')) %>% 
            dplyr::rename(train_set = starts_with('train'),
                          test_set = starts_with('test')) %>% 
            gather('Data', 'CV5_RMSE', train_set, test_set) %>% 
            ggplot(aes(x = iter, col = Data, y = CV5_RMSE)) + 
            geom_line() + 
            scale_y_continuous(breaks = seq(0, 100000, 2500)) + 
            theme(legend.position = 'bottom') + 
            labs(title = "Déterminer le nombre d'abres à utiliser pour le tuning",
                 subtitle = paste(
                     paste0("eta : ", learner$par.vals$eta),
                     paste0("max_depth : ", learner$par.vals$max_depth),
                     paste0("gamma : ", learner$par.vals$gamma),
                     paste0("min_child_weight : ", learner$par.vals$min_child_weight),
                     sep = " , "), 
                 x = "Nombre d'arbres"
            )
        nplots <- file.path(root, "plots") %>% list.files() %>% length()
        ggsave(filename = file.path(root, "plots", paste0(nplots + 1, "-nrounds.pdf")),
               plot = result$plot)
    }
    
    ## Updater le learner donné initialement en arg.
    result$updated_learner <- learner %>% 
        setHyperPars(par.vals = list(
            nrounds = result$tuning$best_ntreelimit
        ))
    
    ## Sauvegarder l'objet de résultat
    if (export){
        nfile <- file.path(root, "lrns") %>% list.files() %>% length()
        saveRDS(result, file = file.path(root, 'lrns', 
                                         paste0(nfile + 1, "-nrounds_lrn.rda")))
    }
    
    ## Retourner la liste de résultats
    result
}