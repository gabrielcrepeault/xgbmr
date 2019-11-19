## Import packages and helper functions ####
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(mlr)
library(iml)
library(tidyverse)
library(gridExtra)
library(DT)
library(shinycssloaders)
# source('../functions/pkg_fun_override.R')

#TODO : Général - Ajouter des progressbar ou truc pour faire patienter le user. Best case,
# l'avise du temps qu'il reste avant la fin des calculs.
## Header du dashboard ####
header <- dashboardHeader(title = "Black-box explain", titleWidth = 300)

## Sidebar du dashboard ####
sidebar <- dashboardSidebar(width = 300,
                            sidebarMenu(
                              menuItem(text = "Analyser les données", tabName = "data", icon = icon("table")),
                              menuItem(text = "Interpréter les modèles", tabName = "analyse", icon = icon("box-open")),
                              menuItem(text = "Analyse des prédictions", tabName = 'pred', icon = icon('magic'))
                            ),
                            fileInput('data1', label = "Data import (max 30Mb)"),
                            fileInput("model1", label = "Import mlr model"),
                            textInput("response_name", label = "Nom de la variable réponse", value = "Ultimate"),
                            textInput("id_name", label = "Nom de la variable représentant le ID", value = "ClNr"),
                            #TODO : pas besoin de mettre un submit pour toute l'application ... trouver les éléments
                            #long à loader où il faudrait un observe.
                            submitButton("Mettre à jour", icon = icon('sync')),
                            p("Just a shiny wrapper arround amazing functions from mlr and iml packages.")
)

## Body du dashboard ####
body <- dashboardBody(
  tabItems(
    tabItem(tabName = "data",
            tableOutput('datainfo')
    ),
    tabItem(tabName = 'analyse',
            fluidRow(
              box(title = "Informations sur le modèle",
                  solidHeader = T, width = 6,
                  h2(textOutput('modelname')),
                  tableOutput('modelinfo') %>% withSpinner()
              ),
              #TODO : ajouter ici (à la place de l'info sur les params),
              # le graphique de la learning curve du modèle (dans le cas des modèles de Boosting)
              box(title = "Information sur les paramètres du modèle",
                  solidHeader = T, width = 6, collapsible = T, collapsed = T,
                  uiOutput('param_select'),
                  textOutput('param_help')
                  # verbatimTextOutput('test')
              )
            ),
            fluidRow(
              box(
                title = "Feature importance",
                solidHeader = T, status = 'primary', width = 6,
                plotOutput("feature_imp") %>% withSpinner()
              ),
              box(title = "Partial Dependance plot",
                  solidHeader = T, status = 'primary', width = 6,
                  uiOutput('select_pdp_vars'),
                  plotOutput('pdp_ice') %>% withSpinner()
              )
            )
    ),
    tabItem(tabName = 'pred',
            fluidRow(
              box('Réel versus prédit', solidHeader = T, width = 6,
                  plotOutput('pred_plot', brush = "plot_brush") %>% withSpinner()
              ),
              box("Local Model prediction", solidHeader = T, width = 6,
                  plotOutput('local_model') %>% withSpinner()
              )
            ),
            fluidRow(
              box("Détail des prédictions", solidHeader = T, width = 12,
                  #TODO : changer les settings de la datatable pour mettre seulement ce qu'on a besoin
                  dataTableOutput("pred_table"))
            )

    )
  )

)

## UI final ####
ui <- dashboardPage(header = header, sidebar = sidebar, body = body, skin = "black")

## Back-end (server) ####
server <- function(input, output, session) {
  ## Pour les file input, autoriser des fichiers de plus grandes tailles
  options(shiny.maxRequestSize=50*1024^2)

  ## Importer le data
  dat <- reactive({read.csv(input$data1$datapath)})

  ## importer le modèle
  model <- reactive({readRDS(input$model1$datapath)})

  ## Afficher l'aide des paramètres
  output$param_select <- renderUI({
    selectInput('param', label = "Obtenir de l'aide sur l'un des paramètres",
                choices = model()$learner$help.list, selected = NULL)
  })

  ## afficher le nom du modèle
  output$modelname <- renderText({
    model()$learner$name
  })

  output$select_pdp_vars <- renderUI({
    pickerInput('pdp_vars', label = "Choisir les variables pour le PDP/ICE plot (max. 4)",
                choices = names(dat()), multiple = T)
  })

  output$test <- renderPrint({
    # model()$learner$help.list[input$param]
  })

  ## Affiche l'aide des paramètres du modèle actuellement utilisé
  output$param_help <- renderText({
    input$param
  })

  ## créer l'objet predictor qui est utilisé par le package iml
  pred <- reactive({
    response <- sym(input$response_name)
    id <- sym(input$id_name)
    pred <- dat() %>%
      # select(-!!response, -!!id) %>%
      group_by(devYear) %>%
      sample_n(10) %>%
      as_tibble() %>%
      Predictor$new(model = model(),
                    data = select(., -!!response, -!!id),
                    y= select(., !!response)
      )
  })

  ## feature importance plot
  output$feature_imp <- renderPlot({
    imp <- FeatureImp$new(pred(), loss = "mse")
    imp$plot() + theme_classic()
  })

  ## PDP/ICE Plot
  output$pdp_ice <- renderPlot({
    pdp_ice <- lapply(input$pdp_vars,
                      function(var){
                        FeatureEffect$new(pred(),
                                          feature = var,
                                          method = 'pdp+ice',
                                          center.at = 0) %>%
                          plot() + theme_classic()
                      })
    do.call('grid.arrange', pdp_ice)
  })

  ## afficher le dataset
  output$datainfo <- renderTable({
    response <- sym(input$response_name)
    id <- sym(input$id_name)
    dat() %>% select(-!!response, -!!id) %>% sample_n(10)
  })

  ## Afficher les informations du modèle
  output$modelinfo <- renderTable({
    model()$learner$par.vals %>% data.frame() %>% t() %>% data.frame(Value = .)
  }, rownames = T)

  ## Afficher graphique des prédictions ####
  ## Calculer les prédictions
  predictions <- reactive({
    id <- sym(input$id_name)
    pp <- dat() %>% mutate(response = predict(model(), newdata = select(., -!!id))$data$response)
  })

  ## Un graphique ben simple
  output$pred_plot <- renderPlot({
    response <- sym(input$response_name)
    ggplot(aes(x = !!response, y = response), data = predictions()) +
      geom_point() +
      geom_abline(intercept = 0, slope = 1, col = 'blue') # courbe à 45 degrés
  })

  ## un DataTable pour voir plus précisément certains points
  brush_plot <- reactive({
    brushedPoints(predictions(), input$plot_brush, xvar = input$response_name, yvar = 'response')
  })

  output$pred_table <- renderDataTable({datatable(brush_plot())})

  output$local_model <- renderPlot({
    explain <- LocalModel$new(pred(), x.interest = brush_plot()[input$pred_table_rows_selected,], k = 3)
    explain$plot() + theme_classic()
  })

}

## Launch the app ####
shinyApp(ui, server)
