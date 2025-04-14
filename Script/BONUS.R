#' Application Shiny pour le jeu Takuzu avec Rcpp
#'
#' Cette application Shiny permet de jouer au jeu Takuzu. Elle utilise des fonctions C++ via Rcpp pour gérer la logique du jeu.
#' L'interface permet à l'utilisateur de cliquer sur des cellules de la grille et de modifier leur valeur.
#'
#' @import shiny
#' @import Rcpp
#' @export

library(shiny)
library(Rcpp)

# Charger le fichier C++ avec les fonctions nécessaires
sourceCpp("/home/mickael/Projets_GIT/Projet_R_M1/Script/OtherTakuzu.cpp")

ui <- fluidPage(
  tags$head(
    tags$style(HTML("      
      .main-container {
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
        min-height: 100vh;
        position: relative;
        z-index: 1;
      }
      .centered-grid {
        margin-top: 30px;
      }
      .elegant-btn {
        background: linear-gradient(145deg, #e6e6e6, #ffffff);
        box-shadow: 4px 4px 8px #b8b8b8, -4px -4px 8px #ffffff;
        border: none;
        border-radius: 12px;
        padding: 10px 20px;
        font-size: 16px;
        transition: all 0.3s ease;
      }
      .elegant-btn:hover {
        background: linear-gradient(145deg, #d1d1d1, #f0f0f0);
        box-shadow: inset 2px 2px 6px #c1c1c1, inset -2px -2px 6px #ffffff;
        transform: scale(1.05);
      }
      #particles-js {
        position: fixed;
        width: 100%;
        height: 100%;
        z-index: -1;
        top: 0;
        left: 0;
      }
    ")),
    tags$script(src = "https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"),
    tags$script(HTML("      
      document.addEventListener('DOMContentLoaded', function () {
        particlesJS('particles-js', {
          particles: {
            number: { value: 80, density: { enable: true, value_area: 800 } },
            color: { value: '#999999' },
            shape: { type: 'circle' },
            opacity: { value: 0.5, random: false },
            size: { value: 3, random: true },
            line_linked: { enable: true, distance: 150, color: '#cccccc', opacity: 0.4, width: 1 },
            move: { enable: true, speed: 3, direction: 'none', random: false, straight: false, bounce: false }
          },
          interactivity: {
            detect_on: 'canvas',
            events: { onhover: { enable: true, mode: 'repulse' }, onclick: { enable: true, mode: 'push' }, resize: true },
            modes: {
              repulse: { distance: 100, duration: 0.4 },
              push: { particles_nb: 4 }
            }
          },
          retina_detect: true
        });
      });
    "))
  ),
  div(id = "particles-js"),
  div(class = "main-container",
      titlePanel("Welcome To Takuzu² LM"),
      
      selectInput("grid_size", "Choisir la taille de la grille:", 
                  choices = c("Facile 6x6" = 6, "Moyen 8x8" = 8, "Expert 10x10" = 10, "Impossible 14x14" = 14),
                  selected = 8),
      
      uiOutput("gameGrid", class = "centered-grid"),
      
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
    "),
      
      actionButton("help2_btn", "Un coup de main ?", class = "elegant-btn")
  )
)

server <- function(input, output, session) {
  
  reactive_size <- reactive({ as.numeric(input$grid_size) })
  
  observe({
    cat("Resize")
    fixed_size <- reactive_size()
    SetSize(fixed_size)
    mainGenerate()
    
    for (i in 1:fixed_size) {
      for (j in 1:fixed_size) {
        local({
          row <- i
          col <- j
          button_id <- paste0("cell_", row, "_", col)
          
          observeEvent(input[[button_id]], {
            cat("n")
            PlayerChangeValue(row - 1, col - 1)
            new_value <- GetCaseValue(row - 1, col - 1)
            
            updateActionButton(session, button_id, label = as.character(new_value))
            
            session$sendCustomMessage("changeColor", list(id = button_id, value = new_value))
          })
        })
      }
    }
  })
  
  output$gameGrid <- renderUI({
    fixed_size <- reactive_size()
    Help_trigger()
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
      lapply(1:fixed_size, function(i) {
        fluidRow(
          lapply(1:fixed_size, function(j) {
            value <- GetCaseValue(i - 1, j - 1)
            text_color <- ifelse(value == 7, "white", "black")
            background_col <- if (value %in% c(0,1))"lightgray" else "white"
            disabled <- if (value %in% c(0, 1)) TRUE else FALSE
            
            actionButton(
              inputId = paste0("cell_", i, "_", j),
              label = as.character(value),
              style = paste0("color: ", text_color, ";",
                             "background-color: ", background_col, ";",
                             "width: 50px; height: 50px; font-size: 20px; box-shadow: 4px 4px 12px rgba(0, 0, 0, 0.3);"),
              disabled = disabled
            )
          })
        )
      })
    )
  })
  
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
  
  Help_trigger <- reactiveVal(0)
  
  observeEvent(input$help2_btn,{
    HelpPlayer()
    size <- reactive_size()
    cat("Taille utilisée dans help2 :", size, "\n")
    grid_matrix <- matrix(0, nrow=size, ncol=size) 
    for(i in 0:(size - 1)){
      for(j in 0:(size - 1)){
        grid_matrix[i + 1, j + 1] <- GetCaseValue(i, j)
      }
    }
    Help_trigger(Help_trigger()+1)
  })
  
}

shinyApp(ui, server)