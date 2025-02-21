#' @title Application Shiny Takuzu
#' @description An application Shiny for play at Takuzu with differently option of the difficulties 
#' @author Mickael Coquerelle & Loik Galtier
#' @import shiny # Add library
#' @export

library(shiny)

#Fonction checkboxGroupINPUT( pour les checkbox)
######################################################################################################
#                                   Interface Layout
######################################################################################################

#' @title Interface uuser (UI)
#' @description Défine the interface user of the shiny application
#' @return An UI object for apply Shiny
ui <- fluidPage(
  titlePanel("Welcome to LM~Takuzu"),
  
  # Style CSS personalised
  tags$style(HTML("
    body {
      background-image: url('home/mickael/Belette.jpg'); /* Ou une image */
      background-size: cover;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;}
      
    .btn-custom {
      width: 150px;
      height: 50px;
      font-size: 16px;
      border-radius: 5px;
      cursor: pointer;
      margin: 10px;
      box-shadow: 2px 2px 15px rgba(0, 0, 0, 0.3);
      transition: all 0.2s ease-in-out;}
    
    .btn-custom:hover {
      transform: translateY(-5px);
      box-shadow: 3px 3px 20px rgba(0, 0, 0, 0.5);}
    
  ")),  
  
  # Main page
  sidebarLayout(
    sidebarPanel(
      # Sélecteur pour la taille de la matrice
      selectInput("Matrice_size", "Taille de la matrice", 
                  choices = c("6 X 6", "8 X 8", "Custom"),
                  selected = "6 X 6"),
      
      # select level difficulty
      selectInput("Difficulty", "Niveau de difficulté", 
                  choices = c("Facile", "Moyen", "Difficile", "Impossible"),
                  selected = "Facile"),
      
      # Sélecteur pour le temps de jeu
      selectInput("Time", "Temps de jeu",
                  choices = c("Infini", "10 minutes", "30 minutes", "1 heure"),
                  selected = "10 minutes")
    ),
    
    mainPanel(
      # Display agrid according to selection
      uiOutput("grille_matrice")
    )
  )
)

######################################################################################################
#                                   Server Logic
######################################################################################################

#' @title Application server.
#' @description Défine server logic  and display game matrix.
#' @param input List of user inputs.
#' @param output List of dynamically displayed items.
#' @return An object server for shiny.
server <- function(input, output) {
  
  #' @title Generate the takuzu grid
  #' @description Generates an interactive grid of buttons based on the size selected by the user.
  #' @return  UI dynamic  display of grid matrix 6x6, 8x8 or custom
  output$grille_matrice <- renderUI({
    # Déterminer la taille de la grille selon la sélection
    # Define grid size according to selection
    size <- switch(input$Matrice_size,
                   "6 X 6" = 6,
                   "8 X 8" = 8,
                   "Custom" = 10)  # Example of size personalised
    
    # Create a button grid matrix
    grid <- lapply(1:size^2, function(i) {
      actionButton(paste("cell", i, sep = "_"), label = "", class = "btn-custom")
    })
    
    # Organizing buttons in a matrix
    div(class = "matrice", grid)
  })
}

######################################################################################################
#                                    Run the application
######################################################################################################

#' @title Application launch
#' @description Starts the shiny application with the previously defined user interface and server.
shinyApp(ui = ui, server = server)
