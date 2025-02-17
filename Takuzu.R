library(shiny)

######################################################################################################
#                                   Interface Layout
######################################################################################################

ui <- fluidPage(
  titlePanel("Bienvenue sur l'application Takuzu "),
  
  # Style CSS personnalisé
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
  # Mise en page avec une barre latérale et un panneau principal
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
      # Affichage de la grille en fonction de la sélection
      uiOutput("grille_matrice")
    )
  )
)

######################################################################################################
#                                   Server Logic
######################################################################################################
server <- function(input, output) {
  
  output$grille_matrice <- renderUI({
    # Déterminer la taille de la grille selon la sélection
    size <- switch(input$Matrice_size,
                   "6 X 6" = 6,
                   "8 X 8" = 8,
                   "Custom" = 10)  # Exemple de taille personnalisée
    
    # Créer la matrice sous forme de grille de boutons
    grid <- lapply(1:size^2, function(i) {
      actionButton(paste("cell", i, sep = "_"), label = "", class = "btn-custom")
    })
    
    # Organiser les boutons dans une grille CSS
    div(class = "matrice", grid)
  })
}

######################################################################################################
#                                    Run the application
######################################################################################################
shinyApp(ui = ui, server = server)

