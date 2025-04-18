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
#sourceCpp("/home/m/Projets_GIT/Projet_R_M1/Script/OtherTakuzu.cpp")
sourceCpp("~/Documents/git/Projet_R_M1/Script/OtherTakuzu.cpp")
                                                                      
ui <- fluidPage(
tags$head(
    tags$style(HTML("
      body {
        background-color: #f4f4f4;
      }

      .main-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: flex-start;
        min-height: 100vh;
        padding-top: 40px;
      }

      .takuzu-card {
        background-color: white;
        border-radius: 15px;
        box-shadow: 0px 4px 15px rgba(0, 0, 0, 0.2);
        padding: 30px;
        width: fit-content;
      }

      .fancy-button {
        font-size: 18px;
        padding: 10px 20px;
        background: linear-gradient(135deg, #6EC1E4, #217CA3);
        color: white;
        border: none;
        border-radius: 10px;
        box-shadow: 0px 6px 12px rgba(0, 0, 0, 0.3);
        transition: all 0.3s ease;
      }

      .fancy-button:hover {
        transform: scale(1.05);
        box-shadow: 0px 8px 16px rgba(0, 0, 0, 0.4);
      }

      .dropdown-select {
        margin-bottom: 20px;
      }

      .takuzu-grid {
        margin-top: 20px;
        margin-bottom: 20px;
      }
    "))
),
                                                                        
div(class = "main-container",
    div(class = "takuzu-card",
        titlePanel("Welcome To Takuzu² LM"),
                                                                                
        # Sélection de la taille de la grille
        div(class = "dropdown-select",
            selectInput("grid_size", "Choisir la taille de la grille:", 
                        choices = c("Facile 6x6" = 6, "Moyen 8x8" = 8, "Expert 10x10" = 10, "Impossible 14x14" = 14),
                        selected = 8)
        ),
                                                                                
        # Espace pour afficher la grille du jeu
        div(class = "takuzu-grid", uiOutput("gameGrid")),
                                                                                
        # Bouton "Un coup de main ?"
        actionButton("help2_btn", "Un coup de main ?", class = "fancy-button")
    )
),
                                                                        
# Bouton "?" pour afficher les règles, toujours en haut à droite
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
    cat("Resize")
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
            PlayerChangeValue(row - 1, col - 1)
            new_value <- GetCaseValue(row - 1, col - 1)
  
            updateActionButton(session, button_id, label = as.character(new_value))
            size <- reactive_size()

              for (i2 in 1:size) {
                for (j2 in 1:size) {
                  val <- GetCaseValue(i2 - 1, j2 - 1)
                  is_fixed <- GetHiddenCaseValue(i2 - 1, j2 - 1) != 7  # Vérifie si la case est fixe

                if (is_fixed) {
                    session$sendCustomMessage("changeColor", list(id = paste0("cell_", i2, "_", j2), value = val, error = FALSE, fixed = TRUE))
                } else {
                    session$sendCustomMessage("changeColor", list(id = paste0("cell_", i2, "_", j2), value = val, error = FALSE, fixed = FALSE))
                }
                }
              }

              # Affichage des cellules fautives
              error_cells <- GetErrorCells()
              for (cell in error_cells) {
                i <- cell[1] + 1
                j <- cell[2] + 1
                val <- GetCaseValue(i - 1, j - 1)
                session$sendCustomMessage("changeColor", list(id = paste0("cell_", i, "_", j), value = val, error = TRUE))
              }

              # Victoire 
              if (CheckVictory()) {
                showModal(modalDialog(
                  title = " Victoire !",
                  "Félicitations ! Vous avez complété la grille correctement !",
                ))
              }
            })
        })
    }
    }
})

output$gameGrid <- renderUI({
    fixed_size <- reactive_size()  # Récupération de la taille actuelle de la grille
    Help_trigger()  # Permet le RenderUI à se recalculer (en forcant voir si il y'a pas mieux)
    tagList(
    tags$script(HTML("
        Shiny.addCustomMessageHandler('changeColor', function(message) {
        var button = document.getElementById(message.id);
        if (button) {
        if (message.fixed) {
            button.style.backgroundColor = 'lightgray';
            button.style.color = 'black';
        } else {
            if (message.value == 1) {
              button.style.backgroundColor = 'lightblue';
              button.style.color = 'black';
            }
            else if (message.value == 0) {
              button.style.backgroundColor = 'lightgreen';
              button.style.color = 'black';
            }
            else if (message.value == 7) {
              button.style.backgroundColor = 'white';
              button.style.color = 'white';
            }
            else {
              button.style.backgroundColor = 'white';
              button.style.color = 'black';
            }
        }

        if (message.error) {
          button.style.backgroundColor = 'red';
          button.style.color = 'white';
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

            # Vérification si la case est fixe dans HiddenGrid
            is_fixed <- GetHiddenCaseValue(i - 1, j - 1) != 7  # Fonction C++ à implémenter
            background_col <- if (is_fixed) "lightgray" else "white"

            # On fige la couleur et pas de modification possible après la génération
            disabled <- if (is_fixed) TRUE else FALSE

            actionButton(
            inputId = paste0("cell_", i, "_", j),  # ID unique pour chaque cellule
            label = as.character(value),  # Affichage de la valeur
            style = paste0("color: ", text_color, ";", "background-color: ", background_col, ";", "width: 50px; height: 50px; font-size: 20px; box-shadow: 4px 4px 12px rgba(0, 0, 0, 0.3);"), disabled = disabled
            )
        })
        )
    })
    )
})
                                                                        
# Affichage des règles du jeu
observeEvent(input$help_btn, {
    showModal(modalDialog(
    title = "Bienvenue sur le Jeu Takuzu de x et y",
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
                                                                        
Help_trigger <- reactiveVal(0) # Pour actualiser avec un accumulateur si l'utilisateur demande de l'aide


observeEvent(input$help2_btn,{
    HelpPlayer(0) #Récupération de la fonction qui exploite le comportement de ChangeValue
    Help_trigger(Help_trigger() + 1) # Incrémentation de l'accumulateur
})

}#fin de la partie serveur.

shinyApp(ui, server)
