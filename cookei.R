library(shiny)
library(later)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      actionButton("increment_btn", "Cookie"),
      h3("Boost cost:"),
      textOutput("bc_value"),
      actionButton("increment_buyBoost", "buy boost"),
      h3("Auto cost:"),
      textOutput("ac_value"),
      actionButton("increment_buyAuto", "buy auto")
    ),
    mainPanel(
      h3("Cookie :"),
      textOutput("x_value"),
      h3("Boost level:"),
      textOutput("y_value"),
      h3("Auto level:"),
      textOutput("a_value")
    )
  )
)


server <- function(input, output, session) {
  x <- reactiveVal(0)
  y <- reactiveVal(1)
  a <- reactiveVal(0)
  
  observeEvent(input$increment_btn, {
    x(x() + y())  # Increment X by Y
  })
  
  
  output$bc_value <- renderText({
    y() * y() * 5
  })
  
  observeEvent(input$increment_buyBoost, {
    cost <- y() * y() * 5  # Cost formula: boost^2 * 5
    if (x() >= cost) {     # Check if cookies are sufficient
      x(x() - cost)        # Deduct cookies for the cost
      y(y() + 1)           # Increment boost level
    }
  })
  
  output$ac_value <- renderText({
    if(a() < 100){
      a() * a()/1.75 * 10 + 25
    }
    else{
      "Max level"
    }
  })
  
  observeEvent(input$increment_buyAuto, {
    cost <- a() * a()/1.75 * 10 + 25  # Cost formula: boost^2 * 5
    if (x() >= cost && a() < 100) {     # Check if cookies are sufficient
      x(x() - cost)        # Deduct cookies for the cost
      a(a() + 1)           # Increment auto level
    }
  })
  
  autoIncrement <- function() {
    isolate({#pour modifier les valeur reactives hors d'un observe
      if (a() > 0) {
          x(x()+(a() - ((a()) / 115)))
      }
    later::later(autoIncrement, 1 - (a()/115))  # Schedule next call in 1 second
    })
  }
  
  # Start auto-increment logic
  autoIncrement()
  
  
  
  output$x_value <- renderText({
    x()
  })
  
  output$y_value <- renderText({
    y()
  })
  
  
  output$a_value <- renderText({
    a()
  })
  
}

shinyApp(ui = ui, server = server)

