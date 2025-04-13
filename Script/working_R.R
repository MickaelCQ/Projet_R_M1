#' Application Shiny pour le jeu Takuzu avec Rcpp
#'
#' Cette application Shiny permet de jouer au jeu Takuzu. Elle utilise des fonctions C++ via Rcpp pour gérer la logique du jeu.
#' L'interface permet à l'utilisateur de cliquer sur des cellules de la grille et de modifier leur valeur.
#'
#' @import shiny
#' @import Rcpp
#' @export
#'
library(shiny)
library(Rcpp)

#' Charger le fichier C++ avec les fonctions nécessaires
#'
#' Charge le fichier C++ contenant les règles du jeu Takuzu.
#' 
#' @param file Le chemin vers le fichier C++ à charger.
#' @export
#sourceCpp("/home/mickael/Projets_GIT/Projet_R_M1/Script/TakuzuRules.cpp")
sourceCpp("~/Documents/git/Projet_R_M1/Script/working_cpp.cpp")

#' Définition de l'interface utilisateur de l'application Shiny
#'
#' Crée l'interface utilisateur de l'application, qui consiste en un panneau de titre
#' et un espace réservé pour afficher la grille du jeu.
#'
#' @export
ui <- fluidPage(
  titlePanel("Takuzu avec Rcpp"),
  uiOutput("gameGrid")  # Espace réservé pour la grille du jeu
)

#' Fonction serveur de l'application Shiny
#'
#' Gère la logique serveur de l'application Shiny. Cette fonction définit le comportement
#' des événements sur les boutons représentant les cellules de la grille et met à jour la grille
#' en appelant les fonctions C++ pour la gestion du jeu Takuzu.
#'
#' @param input,output,session Les objets passés par Shiny pour gérer l'interactivité.
#' @export
server <- function(input, output, session) {
  
  #' Créer une variable réactive pour la grille du jeu
  #'
  # Initialiser la grille avec une configuration valide via une fonction C++.
  grid <- reactiveVal(generateValidBoard())  # Initialiser avec une grille valide
  
  #' Mise à jour des cellules de la grille en fonction des événements
  #'
  # Cette section écoute les événements de modification des cellules de la grille
  # et met à jour la grille en conséquence en utilisant une fonction C++.
  observe({
    mat <- grid()  # Récupérer la grille actuelle
    
    # Créer des événements pour chaque cellule de la grille
    for (i in 1:nrow(mat)) {
      for (j in 1:ncol(mat)) {
        local({
          row <- i
          col <- j
          button_id <- paste0("cell_", row, "_", col)
          
          observeEvent(input[[button_id]], {
            # Modifier la valeur de la cellule avec la fonction C++
            updated_grid <- change_val(row - 1, col - 1)  # Ajuster les indices pour C++
            
            # Mettre à jour la grille réactive avec la grille mise à jour
            grid(updated_grid)
          }, ignoreNULL = FALSE, ignoreInit = TRUE)
        })
      }
    }
  })
  
  #' Rendu de l'interface de la grille de jeu
  #'
  # Cette fonction génère dynamiquement l'interface utilisateur pour la grille du jeu,
  # en affichant des boutons pour chaque cellule de la grille.
  # La couleur des cellules est déterminée en fonction de leur valeur.
  # 
  # @return UI dynamique pour la grille du jeu.
  output$gameGrid <- renderUI({
    mat <- grid()  # Récupérer la grille actuelle
    
    tagList(
      lapply(1:nrow(mat), function(i) {
        fluidRow(
          lapply(1:ncol(mat), function(j) {
            value <- mat[i, j]  # Valeur de la cellule
            color <- ifelse(value == 1, "lightgreen", "lightcoral")  # Couleur selon la valeur
            
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

#' Démarrer l'application Shiny
#'
#' Lancement de l'application Shiny avec l'interface utilisateur et la logique serveur.
#' 
#' @return Application Shiny démarrée.
shinyApp(ui, server)
