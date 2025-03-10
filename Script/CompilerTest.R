#' @title Interface Shiny pour le jeu de Takuzu
#' @description Cette application Shiny permet de jouer au Takuzu en utilisant une implémentation optimisée en C++ via Rcpp.
#'
#' @section Bibliothèques requises :
#' - `shiny` : Pour l'interface utilisateur interactive.
#' - `Rcpp` : Pour exécuter du code C++ dans R.
#'
#' @import shiny
#' @import Rcpp
#' @export

# Chargement des bibliothèques nécessaires
library(shiny)  # Interface utilisateur
library(Rcpp)   # Exécution de code C++ dans R

#' @section Chargement du fichier C++ :
#' `sourceCpp()` charge la logique du jeu depuis un fichier externe C++.
sourceCpp("/home/mickael/Projets_GIT/Projet_R_M1/Script/TakuzuRules.cpp")

#' @section Définition de l'interface utilisateur (UI) :
#' - `titlePanel()` définit le titre de l'application.
#' - `uiOutput("gameGrid")` crée un espace réservé pour afficher la grille de jeu générée dynamiquement.
ui <- fluidPage(
  titlePanel("Takuzu avec Rcpp"),  # Titre de l'application
  uiOutput("gameGrid")  # Espace réservé pour la grille du jeu
)

#' @section Définition du serveur :
#' La fonction `server()` gère la logique du jeu.
#'
#' @param input Liste des entrées utilisateur (non utilisée ici, sauf `update`).
#' @param output Liste des sorties à afficher dans l'UI.
#' @param session Objet de session Shiny (nécessaire pour les interactions dynamiques).
#' @return Aucun retour direct, mais met à jour dynamiquement l'affichage de la grille.
server <- function(input, output, session) {
  
  #' @details Initialisation de la grille Takuzu :
  #' `reactiveVal()` permet de stocker une version réactive de la grille du jeu.
  grid <- reactiveVal(generateValidBoard())  # Grille initiale générée par la fonction C++
  
  #' @details Gestion des clics sur les boutons de la grille
  observe({
    mat <- grid()  # Récupération de la grille actuelle
    for (i in 1:nrow(mat)) {
      for (j in 1:ncol(mat)) {
        local({
          row <- i  
          col <- j
          button_id <- paste0("cell_", row, "_", col)
          
          observeEvent(input[[button_id]], {
            # Appeler la fonction C++ pour modifier la valeur de la cellule
            updated_grid <- change_val(row - 1, col - 1)  # Ajustement des indices pour C++
            
            # Mettre à jour la grille réactive avec la grille mise à jour
            grid(updated_grid)  # Mise à jour de la grille réactive
          }, ignoreNULL = FALSE, ignoreInit = TRUE)
        })
      }
    }
  })
  
  
  #' @section Génération de l'interface du jeu :
  #' La fonction `renderUI()` génère dynamiquement une grille avec des boutons interactifs.
  #' Chaque cellule est représentée par un `actionButton()` avec une couleur associée.
  output$gameGrid <- renderUI({
    mat <- grid()  # Récupération de la grille actuelle
    
    #' @details Génération des lignes et colonnes de la grille :
    #' - `lapply(1:nrow(mat), ...)` crée les lignes du jeu.
    #' - `lapply(1:ncol(mat), ...)` crée les colonnes et les boutons interactifs.
    tagList(
      lapply(1:nrow(mat), function(i) {
        fluidRow(
          lapply(1:ncol(mat), function(j) {
            value <- mat[i, j]  # Valeur de la case (0 ou 1)
            color <- ifelse(value == 1, "lightgreen", "lightcoral")  # Couleur associée
            
            #' @note Chaque bouton possède un `inputId` unique de type `cell_i_j`,
            #' ce qui permettrait de capturer les clics individuels (non encore implémenté).
            actionButton(
              inputId = paste0("cell_", i, "_", j),  # Identifiant unique
              label = value,  # Affichage du chiffre (0 ou 1)
              style = paste0("background-color:", color, 
                             "; color: black; width: 50px; height: 50px; font-size: 20px;")
            )
          })
        )
      })
    )
  })
}

#' @section Lancement de l'application :
#' `shinyApp()` démarre l'application avec l'interface UI et la logique serveur.
shinyApp(ui, server)
