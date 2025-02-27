#' @description An application Shiny for play at Takuzu with differently option of the difficulties 
#' @author Mickael Coquerelle & Loik Galtier
#' @import shiny # Add library
  
#' @import shiny DT
#' @export

library(shiny)
library(DT)
library(Rcpp)  # Interface avec C++ via Rcpp

# Chargez le code C++ 
sourceCpp("TakuzuRules.cpp")

######################################################################################################
#                                   Interface Layout
######################################################################################################

ui <- fluidPage(
  titlePanel("Welcome to LM~Takuzu"),
  
  # Style CSS personnalisé
  tags$style(HTML("
    body {
      background-image: url('home/mickael/Belette.jpg');
      background-size: cover;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .btn-custom {
      width: 150px;
      height: 50px;
      font-size: 16px;
      border-radius: 5px;
      cursor: pointer;
      margin: 10px;
      box-shadow: 2px 2px 15px rgba(0, 0, 0, 0.3);
      transition: all 0.2s ease-in-out;
    }
    .btn-custom:hover {
      transform: translateY(-5px);
      box-shadow: 3px 3px 20px rgba(0, 0, 0, 0.5);
    }
  ")),
  
  # Layout principal
  sidebarLayout(
    sidebarPanel(
      # Sélecteur pour la taille de la matrice
      selectInput("Matrice_size", "Taille de la matrice", 
                  choices = c("6 X 6", "8 X 8", "Custom"),
                  selected = "6 X 6"),
      
      # Sélecteur pour le niveau de difficulté
      selectInput("Difficulty", "Niveau de difficulté", 
                  choices = c("Facile", "Moyen", "Difficile", "Impossible"),
                  selected = "Facile"),
      
      # Sélecteur pour le temps de jeu
      selectInput("Time", "Temps de jeu",
                  choices = c("Infini", "10 minutes", "30 minutes", "1 heure"),
                  selected = "10 minutes")
    ),
    
    mainPanel(
      # Affiche la grille générée
      uiOutput("grille_matrice")
    )
  )
)

######################################################################################################
#                                   Server Logic
######################################################################################################

server <- function(input, output, session) {
  
  #' @title Génération de la grille Takuzu
  #' @description Génère dynamiquement une grille de jeu en appelant la fonction Rcpp exportée
  output$grille_matrice <- renderUI({
    # Déterminez la taille de la grille selon la sélection de l'utilisateur
    size <- switch(input$Matrice_size,
                   "6 X 6" = 6,
                   "8 X 8" = 8,
                   "Custom" = 10)
    
    # Appel à la fonction C++ pour générer la grille valide
    grid_matrix <- generateValidBoard()  # Retourne une NumericMatrix
    
    # Création d'un layout de boutons (un pour chaque cellule de la grille)
    rows <- lapply(1:size, function(i) {
      row_buttons <- lapply(1:size, function(j) {
        # On peut afficher la valeur générée dans la grille
        actionButton(
          inputId = paste0("cell_", i, "_", j),
          label = as.character(grid_matrix[i, j]),
          class = "btn-custom"
        )
      })
      fluidRow(row_buttons)
    })
    do.call(tagList, rows)
  })
}

######################################################################################################
#                                    Run the application
######################################################################################################

shinyApp(ui = ui, server = server)
