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
sourceCpp("/home/mickael/Projets_GIT/Projet_R_M1/Script/OtherTakuzu.cpp")
#sourceCpp("~/Documents/git/Projet_R_M1/Script/OtherTakuzu.cpp")

ui <- fluidPage(
  titlePanel("Welcome To Takuzu² LM"),
  
  # Sélection de la taille de la grille
  selectInput("grid_size", "Choisir la taille de la grille:", 
              choices = c("Facile 6x6" = 6, "Moyen 8x8" = 8, "Expert 10x10" = 10, "Impossible 14x14" = 14),
              selected = 8),
  
  # Espace pour afficher la grille du jeu
  uiOutput("gameGrid"),
  
  # Bouton "?" pour afficher les règles
  actionButton("help_btn", "?", style = "
    font-size: 20px; 
    height: 50px; 
    width: 50px; 
    background-color: lightgray; 
    color: black; 
    border: none; 
    border-radius: 50%; 
    position: fixed; 
    top: 10px; 
    right: 10px; 
    box-shadow: 4px 4px 12px rgba(0, 0, 0, 0.3);
    transition: all 0.3s ease;
  ")
)

server <- function(input, output, session) {
  
  # Taille de la grille réactive
  reactive_size <- reactive({ as.numeric(input$grid_size) })
  
  # Mise à jour de la grille lors du changement de taille
  observe({
    fixed_size <- reactive_size()
    SetSize(fixed_size)  # Mise à jour de la taille dans le C++ (via SetSize)
    mainGenerate()       # Génération de la grille après changement de taille
    
    # Ajout d'un observeEvent pour chaque cellule (dynamiquement)
    for (i in 1:fixed_size) {
      for (j in 1:fixed_size) {
        local({
          row <- i
          col <- j
          button_id <- paste0("cell_", row, "_", col)
          
          # Observer chaque cellule pour un changement de valeur lorsqu'on clique
          observeEvent(input[[button_id]], {
            PlayerChangeValue(row - 1, col - 1)  # Modification de la valeur dans C++
            new_value <- GetCaseValue(row - 1, col - 1)  # Récupération de la nouvelle valeur
            
            # Mise à jour du bouton (affichage de la nouvelle valeur)
            updateActionButton(session, button_id, label = as.character(new_value))
            
            # Changer la couleur avec JavaScript via un message personnalisé
            session$sendCustomMessage("changeColor", list(id = button_id, value = new_value))
          })
        })
      }
    }
  })
  
  # Mise à jour de la grille affichée
  output$gameGrid <- renderUI({
    fixed_size <- reactive_size()  # Récupération de la taille actuelle de la grille
    tagList(
      tags$script(HTML("
        Shiny.addCustomMessageHandler('changeColor', function(message) {
          var button = document.getElementById(message.id);
          if (button) {
            if (message.value == 1) {
              button.style.backgroundColor = 'lightblue';
              button.style.color = 'black';
            } else if (message.value == 0) {
              button.style.backgroundColor = 'lightgreen';
              button.style.color = 'black';
            } else if (message.value == 7) {
              button.style.backgroundColor = 'white';
              button.style.color = 'white';
            } else {
              button.style.backgroundColor = 'white';
              button.style.color = 'black';
            }
          }
        });
      ")),
      # Création dynamique de la grille en fonction de la taille
      lapply(1:fixed_size, function(i) {
        fluidRow(
          lapply(1:fixed_size, function(j) {
            value <- GetCaseValue(i - 1, j - 1)  # Valeur actuelle de la cellule
            text_color <- ifelse(value == 7, "white", "black")  # Choix de la couleur du texte
            
            actionButton(
              inputId = paste0("cell_", i, "_", j),  # ID unique pour chaque cellule
              label = as.character(value),  # Affichage de la valeur
              style = paste0("color: ", text_color, "; width: 50px; height: 50px; font-size: 20px; box-shadow: 4px 4px 12px rgba(0, 0, 0, 0.3);")
            )
          })
        )
      })
    )
  })
  
  # Affichage des règles du jeu
  observeEvent(input$help_btn, {
    showModal(modalDialog(
      title = "Bienvenue sur le Jeu Takuzu de Loik et Mickael",
      "Quelques éléments de compréhension pour vous aider :\n\n",
      "- Remplissez la grille avec des zéros et des uns en respectant ces règles :\n\n",
      "- Chaque ligne et colonne doit contenir un nombre égal de 0 et de 1.\n\n",
      "- Aucune ligne ou colonne ne peut être identique à une autre.\n\n",
      "- Chaque case peut être modifiée en cliquant dessus.\n\n",
      "- Vous gagnez lorsque toutes les règles sont respectées ! Bonne chance !",
      easyClose = TRUE,
      footer = modalButton("Fermer")
    ))
  })
}

shinyApp(ui, server)
