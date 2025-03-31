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
sourceCpp("~/Documents/git/Projet_R_M1/Script/OtherTakuzu.cpp")

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
  SetSize(10)
  reactive_size <- reactive({A = as.numeric(input$grid_size)})
  
  observe({
    Size <- GetSize()
    mainGenerate()
    
    # Ajout d'un observeEvent pour chaque cellule
    for (i in 1:Size) {
      for (j in 1:Size) {
        local({
          row <- i
          col <- j
          button_id <- paste0("cell_", row, "_", col)
          
          observeEvent(input[[button_id]], {
              PlayerChangeValue(row - 1, col - 1)
              new_value <- GetCaseValue(row - 1, col - 1)
              
              updateActionButton(session, button_id, label = as.character(new_value))
              
              # Changer la couleur avec JavaScript
              session$sendCustomMessage("changeColor", list(id = button_id, value = new_value))
          })
        })
      }
    }
  })
  
  # Mise à jour de la grille
  output$gameGrid <- renderUI({
    Size <- GetSize()
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
      lapply(1:Size, function(i) {
        fluidRow(
          lapply(1:Size, function(j) {
            value <- GetCaseValue(i-1, j-1)
            text_color <- ifelse(value == 7, "white", "black")
            
            actionButton(
              inputId = paste0("cell_", i, "_",j ),
              label = as.character(value),
              style = paste0("color: ", text_color, "; width: 50px; height: 50px; font-size: 20px; box-shadow: 4px 4px 12px rgba(0, 0, 0, 0.3);")
            )
          })
        )
      })
    )
  })
  
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
