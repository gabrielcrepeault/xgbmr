#' tune_and_update
#' 
#' @author Gabriel Crépeault-Cauchon
#' 
#' @description Fonction pour wrapper la fonction tuneParams de mlr avec les différents
#' paramètres à fixer. Ça réduit le code dans le fichier principal de tuning.
#' 
#' @param learner Un objet R de classe "Learner"
#' @param task Un objet R de class "Task"
#' @param param_set Un objet R de classe "ParamSet"
#' @param plot indicateur pour indiquer si on veut produire un graphique résumé 
#' de la procédure CV5
#' @param export indicateur pour indiquer si on veut sauvegarder dans un fichier .rda
#' l'objet TuneResult (lorsque c'est long à rouler, c'est intéressant de sauvegarder des
#' résultats intermédiaires.
#' 
#' @return  Une liste contenant un graphique, l'objet TuneResult, le data.frame ayant
#' permi de créer le graphique et le nouvel objet Learner mis à jour avec la valeur optimale
#' du paramètre.
#' 
#' @export
tune_and_update <- function(learner, task, param_set, plot = T, show.info = T, root){
    require(tidyverse, quietly = T)
    require(mlr, quietly = T)
    require(gridExtra, quietly = T)
    # Le résultat de la fonction sera une liste avec plusieurs items
    result <- list()
    param_name <- names(param_set$pars)
    
    # Définir paramètres généraux de la procédure de tuning
    ctrl <- makeTuneControlGrid()
    cv5_strat <- makeResampleDesc("CV", iters = 5, stratify.cols = "devYear")
    
    ## Tuning process
    tuning <- tuneParams(learner = learner, task = task, resampling = cv5_strat,
                         par.set = param_set, control = ctrl,
                         measures = list(setAggregation(rmse, test.mean),
                                         setAggregation(rmse, test.sd)),
                         show.info = show.info
    )
    
    ## Graphique et données sur la procédure de tuning
    r <- generateHyperParsEffectData(tuning, partial.dep = T)
    if (plot){
        rmse_graph <- r$data %>% 
            ggplot(aes_string(x = param_name, y = "rmse.test.mean")) + 
            geom_errorbar(aes(ymin = rmse.test.mean-rmse.test.sd,
                              ymax = rmse.test.mean+rmse.test.sd),
                          linetype = 'dashed', col = 'gray') + 
            geom_point() + geom_line(col = 'blue') + 
            labs(title = paste0("Déterminer ", param_name, " par CV5"),
                 subtitle = paste(
                     # paste0("gamma : ", xgb_pars$gamma),
                     paste0("eta : ", tuning$learner$par.vals$eta),
                     paste0("nrounds : ", tuning$learner$par.vals$nrounds),
                     # paste0("min_child_weight : ", xgb_pars$min_child_weight),
                     sep = " , "),
                 y = "Test RMSE moyen"
            ) + theme_classic()
        
        exec_time_graph <- r$data %>% 
            ggplot(aes_string(x = param_name)) + 
            geom_line(aes(y = exec.time)) +
            labs(y = "Temps d'exécution (sec.)")
        
        result$plot <- grid.arrange(rmse_graph, exec_time_graph)
        nplots <- file.path(root, "plots") %>% list.files() %>% length()
        ggsave(filename = file.path(root, "plots", paste0(nplots + 1, "-", param_name, ".pdf")),
               plot = result$plot)
    }
    
    ## Autres éléments à mettre dans la liste
    result$tuning_process <- tuning
    result$tuning_eval <- r$data
    result$updated_learner <- learner %>% 
        setHyperPars(par.vals = tuning$x) %>% 
        setLearnerId(id = paste0(param_name, "_lrn"))
    
    # ## Si il est indiqué d'exporter, export dans le répertoire actuel un fichier .rda
    nfile <- file.path(root, "lrns") %>% list.files() %>% length()
    saveRDS(result, file = file.path(root, 'lrns', paste0(nfile + 1, "-", param_name, "_lrn.rda")))
    
    ## Retourner la liste de résultats
    result
}