library(shiny)
library(Rcpp)

# Charger le fichier C++ avec les fonctions nécessaires
sourceCpp("/home/mickael/Projets_GIT/Projet_R_M1/Script/OtherTakuzu.cpp")

ui <- fluidPage(
  titlePanel("T"),
  
  # Liste déroulante pour choisir la taille de la grille
  selectInput("grid_size", "Choisir la taille de la grille:", 
              choices = c("Facile 6x6" = 6, "Moyen 8x8" = 8, "Expert 10x10 " = 10, "Impossible 14x14" = 14),
              selected = 8),
  
  # Espace réservé pour afficher la grille du jeu
  uiOutput("gameGrid")
)

server <- function(input, output, session) {
  # Créer une variable réactive pour la taille de la grille
  reactive_size <- reactive({
    input$grid_size  # Cette valeur changera lorsque l'utilisateur sélectionne une taille
  })
  
  observe({
    # Initialiser la grille avec la bonne taille en fonction du choix de l'utilisateur
    Size <- reactive_size()
    mainGenerate()  # Initialiser la grille avec la nouvelle taille
    
    observe({
      # Créer des événements pour chaque cellule de la grille
      for (i in 1:Size) {
        for (j in 1:Size) {
          local({
            row <- i
            col <- j
            button_id <- paste0("cell_", row, "_", col)
            
            observeEvent(input[[button_id]], {
              isolate({
                # Modifier la valeur de la cellule avec la fonction C++
                PlayerChangeValue(row - 1, col - 1)
                new_value <- GetCaseValue(row - 1, col - 1)  # Récupérer la nouvelle valeur après changement
                
                # Définir la nouvelle couleur en fonction de la valeur
                color <- ifelse(new_value == 1, "lightblue", 
                                ifelse(new_value == 0, "lightgreen", 
                                       ifelse(new_value == 7, "white", "white")))
                
                # Mettre à jour la cellule avec le nouveau label via updateActionButton
                updateActionButton(session, paste0("cell_", row, "_", col), 
                                   label = as.character(new_value))
              })
            }, ignoreNULL = TRUE, ignoreInit = TRUE)
          })
        }
      }
    })
  })
  
  # Rendu de l'interface de la grille de jeu
  output$gameGrid <- renderUI({
    Size <- reactive_size()  # Récupérer la taille actuelle de la grille
    tagList(
      lapply(1:Size, function(i) {
        fluidRow(
          lapply(1:Size, function(j) {
            value <- GetCaseValue(i-1, j-1)  # Valeur de la cellule
            color <- ifelse(value == 1, "lightblue", 
                            ifelse(value == 0, "lightgreen", 
                                   ifelse(value == 7, "white", "white")))  # Couleur par défaut
            actionButton(
              inputId = paste0("cell_", i, "_", j),  # Identifiant unique
              label = as.character(value),  # Afficher la valeur de la cellule
              style = paste0("background-color:", color, "; color: black; width: 50px; height: 50px; font-size: 20px;")
            )
          })
        )
      })
    )
  })
}

shinyApp(ui, server)
