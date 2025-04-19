#' @file app.R
#' @brief Application Shiny du jeu Takuzu avec logique en C++ via Rcpp et fond animé JavaScript sur le thème des mathématiques.
#'
#' Cette application permet de jouer à Takuzu avec une interface moderne. Le fond animé utilise un canvas HTML5 avec des chiffres mathématiques animés.

library(shiny)
library(Rcpp)

#' @brief Charge le script C++ contenant la logique du jeu Takuzu
#' @param file Chemin du fichier C++ (ici relatif au répertoire du projet)
#' @return Aucune valeur de retour
sourceCpp("./OtherTakuzu.cpp")

# UI
ui <- fluidPage(
  tags$head(
    # Styles CSS
    tags$style(HTML("
      html, body {
        margin: 0;
        padding: 0;
        overflow: hidden;
      }

      canvas#background {
        position: fixed;
        z-index: -1;
        top: 0;
        left: 0;
      }

      body {
        background-color: transparent;
        font-family: 'Courier New', monospace;
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
        background-color: rgba(255, 255, 255, 0.9);
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
    ")),
    # JavaScript d'animation fond mathématique
    tags$script(HTML("
      document.addEventListener('DOMContentLoaded', function() {
        var canvas = document.createElement('canvas');
        canvas.id = 'background';
        document.body.appendChild(canvas);

        var ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        canvas.style.display = 'none';

        var chars = '01=+-×÷π∞Σ√∫∂≠≤≥∑'.split('');
        var fontSize = 22;
        var columns = canvas.width / fontSize;
        var drops = [];
        for (var x = 0; x < columns; x++)
          drops[x] = Math.random() * canvas.height;

        function draw() {
          ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
          ctx.fillRect(0, 0, canvas.width, canvas.height);

          ctx.fillStyle = '#00ff99';
          ctx.font = fontSize + 'px monospace';

          for (var i = 0; i < drops.length; i++) {
            var text = chars[Math.floor(Math.random() * chars.length)];
            ctx.fillText(text, i * fontSize, drops[i] * fontSize);

            if (drops[i] * fontSize > canvas.height && Math.random() > 0.975)
              drops[i] = 0;

            drops[i]++;
          }
        }

        setInterval(draw, 100);

        window.addEventListener('resize', function() {
          canvas.width = window.innerWidth;
          canvas.height = window.innerHeight;
        });
      });
    ")),
    tags$script(HTML("
      // Fonction pour afficher/masquer le canvas
      Shiny.addCustomMessageHandler('toggleBackground', function(enabled) {
        var canvas = document.getElementById('background');
        if (canvas) {
          canvas.style.display = enabled ? 'block' : 'none';
        }
      });
    ")),
    tags$style(HTML("
      #toggleBtn {
        font-size: 14px;
        height: 40px;
        width: 100px;
        background-color: lightgray;
        color: black;
        border: none;
        border-radius: 5px;
        position: fixed;
        top: 10px;
        left: 10px;
        box-shadow: 2px 2px 8px rgba(0, 0, 0, 0.2);
        transition: all 0.3s ease;
      }
      #toggleBtn:hover {
        transform: scale(1.1);
        box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.3);
      }
    "))
  ),

  div(class = "main-container",
      div(class = "takuzu-card",
          titlePanel("Welcome To Takuzu² LM"),
          uiOutput("sizeSelector"),
          uiOutput("gameGrid"),
          uiOutput("helpButton"),

            actionButton("toggleBtn", "matrix ?", class = "fancy-button")
      )
  ),
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

#' @brief Partie serveur de l'application Shiny
#' @param input Entrées utilisateur
#' @param output Objets UI dynamiques à rendre
#' @param session Session utilisateur en cours
#' @return Aucun
server <- function(input, output, session) {
  game_started <- reactiveVal(FALSE)
  grid_size <- reactiveVal(8)
  hand_count <- reactiveVal(0)
  observerCreated <- reactiveValues()
  Help_trigger <- reactiveVal(0)
  NightMode <- reactiveVal(FALSE)


  observe({
    fixed_size <- grid_size()
    SetSize(fixed_size)
    mainGenerate()
    start_time <- Sys.time()

    for (i in 1:fixed_size) {
      for (j in 1:fixed_size) {
        local({
          row <- i
          col <- j
          button_id <- paste0("cell_", row, "_", col)

          if (!is.null(observerCreated[[button_id]])) return()
          observerCreated[[button_id]] <- TRUE

          observeEvent(input[[button_id]], {
            PlayerChangeValue(row - 1, col - 1)
            new_value <- GetCaseValue(row - 1, col - 1)
            updateActionButton(session, button_id, label = as.character(new_value))

            size <- grid_size()
            for (i2 in 1:size) {
              for (j2 in 1:size) {
                val <- GetCaseValue(i2 - 1, j2 - 1)
                is_fixed <- GetHiddenCaseValue(i2 - 1, j2 - 1) != 7
                session$sendCustomMessage("changeColor", list(id = paste0("cell_", i2, "_", j2), value = val, error = FALSE, fixed = is_fixed, nightMode = NightMode()))
              }
            }

            error_cells <- GetErrorCells()
            for (cell in error_cells) {
              i <- cell[1] + 1
              j <- cell[2] + 1
              val <- GetCaseValue(i - 1, j - 1)
              session$sendCustomMessage("changeColor", list(id = paste0("cell_", i, "_", j), value = val, error = TRUE, nightMode = NightMode()))
            }

            if (CheckVictory()) {
              elapsed_time <- difftime(Sys.time(), start_time, units = "secs")
              showModal(modalDialog(
                title = "Victoire !",
                paste0("Bravo !\n- Coups de main utilisés : ", hand_count(), "\n- Temps écoulé : ", round(elapsed_time, 2), " secondes.")
              ))
            }
          })
        })
      }
    }
  })

  output$sizeSelector <- renderUI({
    if (!game_started()) {
      tagList(
        selectInput("grid_size", "Choisir la taille de la grille :",
                    choices = c("Facile 6x6" = 6, "Moyen 8x8" = 8, "Expert 10x10" = 10, "Impossible 14x14" = 14)),
        actionButton("start_game_btn", "Valider", class = "fancy-button")
      )
    }
  })

  observeEvent(input$start_game_btn, {
    req(input$grid_size)
    grid_size(as.numeric(input$grid_size))
    SetSize(grid_size())
    mainGenerate()
    size <- grid_size()
      for (i in 1:size) {
        for (j in 1:size) {
          val <- GetCaseValue(i - 1, j - 1) # Récupère la valeur visible
          is_fixed <- GetHiddenCaseValue(i - 1, j - 1) != 7 # Vérifie si la case est fixe
          session$sendCustomMessage("changeColor", list(
            id = paste0("cell_", i, "_", j),
            value = val,
            error = FALSE,
            fixed = is_fixed,
            nightMode = NightMode()
          ))
        }
      }

      game_started(TRUE)
    })

    observeEvent(input$toggleBtn, {
      NightMode(!NightMode()) # Inverse l'état
      session$sendCustomMessage("toggleBackground", NightMode()) # Envoie l'état au JS
      size <- grid_size()
      for (i2 in 1:size) {
        for (j2 in 1:size) {
          val <- GetCaseValue(i2 - 1, j2 - 1)
          is_fixed <- GetHiddenCaseValue(i2 - 1, j2 - 1) != 7
          session$sendCustomMessage("changeColor", list(id = paste0("cell_", i2, "_", j2), value = val, error = FALSE, fixed = is_fixed, nightMode = NightMode()))
        }
      }
    })

  output$gameGrid <- renderUI({
    if (game_started()) {
      fixed_size <- grid_size()
      Help_trigger()
      tagList(
        tags$script(HTML("
             Shiny.addCustomMessageHandler('changeColor', function(message) {
                 var button = document.getElementById(message.id);

                 if (button) {
                   if (message.fixed) {
                     button.style.backgroundColor = message.nightMode ? 'black' : 'lightgray';
                     button.style.color = message.nightMode ? 'white' : 'black';
                   } else {
                     if (message.value == 1) {
                       button.style.backgroundColor = message.nightMode ? 'darkblue' : 'lightblue';
                       button.style.color = message.nightMode ? 'white' : 'black';
                     }
                     else if (message.value == 0) {
                       button.style.backgroundColor = message.nightMode ? 'darkgreen' : 'lightgreen';
                       button.style.color = message.nightMode ? 'white' : 'black';
                     }
                     else if (message.value == 7) {
                       button.style.backgroundColor = message.nightMode ? 'lightgray' : 'white';
                       button.style.color = message.nightMode ? 'lightgray' : 'white';
                     }
                     else {
                       button.style.backgroundColor = message.nightMode ? 'black' : 'white';
                       button.style.color = message.nightMode ? 'white' : 'black';
                     }
                   }

                   if (message.error) {
                     button.style.backgroundColor = message.nightMode ? 'darkred' : 'red';
                     button.style.color = 'white';
                   }
                 }
               });
        ")),
        lapply(1:fixed_size, function(i) {
          fluidRow(
            lapply(1:fixed_size, function(j) {
              value <- GetCaseValue(i - 1, j - 1)
              is_fixed <- GetHiddenCaseValue(i - 1, j - 1) != 7
              text_color <- ifelse(value == 7, "white", "black")
              background_col <- if (is_fixed) "lightgray" else "white"
              disabled <- if (is_fixed) TRUE else FALSE

              actionButton(
                inputId = paste0("cell_", i, "_", j),
                label = as.character(value),
                style = paste0("color: ", text_color, "; background-color: ", background_col, "; width: 50px; height: 50px; font-size: 20px; box-shadow: 4px 4px 12px rgba(0, 0, 0, 0.3);"),
                disabled = disabled
              )
            })
          )
        })
      )
    }
  })

  output$helpButton <- renderUI({
    if (game_started()) {
      actionButton("help2_btn", "Un coup de main ?", class = "fancy-button")
    }
  })

  observeEvent(input$help_btn, {
    showModal(modalDialog(
      title = "Bienvenue sur le Jeu Takuzu de Loik Galtier et Mickael Coquerelle",
      "Quelques règles à respecter :\n\n- Nombre égal de 0 et de 1 par ligne et colonne\n- Pas plus de deux chiffres identiques à la suite\n- Aucune ligne/colonne ne peut être identique à une autre\n- Cliquez pour modifier les cases\n\nBonne chance !",
      easyClose = TRUE,
      footer = modalButton("Fermer")
    ))
  })

  observeEvent(input$help2_btn, {
    HelpPlayer(0)
    Help_trigger(Help_trigger() + 1)
  })
}

#' @brief Lance l'application Shiny Takuzu
shinyApp(ui, server)

