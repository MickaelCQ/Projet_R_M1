library(shiny)
library(later)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      actionButton("increment_btn", "Cookie"),
      
      fluidRow(
        column(6, wellPanel(
            h3("Boost cost:"),
            textOutput("bc_value"),
            actionButton("increment_buyBoost", "buy boost"),
            h3("GrandMa cost:"),
            textOutput("ac_value"),
            actionButton("increment_buyAuto", "buy GrandMa")
          )),
          column(6, wellPanel(
            h3("Mine cost:"),
            textOutput("mc_value"),
            actionButton("increment_buyMine", "buy Mine"),
            h3("Usine cost:"),
            textOutput("uc_value"),
            actionButton("increment_buyUsine", "buy Usine")
          )
        )
      )
    ),
    mainPanel(
      h3("Cookie :"),
      textOutput("x_value"),
      fluidRow(
        column(6, wellPanel(
      h3("Boost level:"),
      textOutput("y_value"),
      h3("GrandMa level:"),
      textOutput("a_value")
        )
      ),
      column(6, wellPanel(
        h3("Mine level:"),
        textOutput("m_value"),
        h3("Usine level:"),
        textOutput("u_value")
      )
      )
      
      
      )
    )
  )
)



server <- function(input, output, session) {
  x <- reactiveVal(0)
  y <- reactiveVal(1)
  a <- reactiveVal(0)
  m <- reactiveVal(0)
  u <- reactiveVal(0)
  
  observeEvent(input$increment_btn, {
    x(x() + y())  # Increment X by Y
  })
  
  
  output$bc_value <- renderText({
    y() * y() * 3
  })
  
  observeEvent(input$increment_buyBoost, {
    cost <- y() * y() * 3  # Cost formula: boost^2 * 5
    if (x() >= cost) {     # Check if cookies are sufficient
      x(x() - cost)        # Deduct cookies for the cost
      y(y() + 1)           # Increment boost level
    }
  })
  
  output$ac_value <- renderText({
    if(a() < 100){
      round(a() * a()/1.75 * 10 + 25)
    }
    else{
      "Max level"
    }
  })
  
  observeEvent(input$increment_buyAuto, {
    cost <- round(a() * a()/1.75 * 10 + 25)  # Cost formula: boost^2 * 5
    if (x() >= cost && a() < 100) {     # Check if cookies are sufficient
      x(x() - cost)        # Deduct cookies for the cost
      a(a() + 1)           # Increment auto level
    }
  })
  
  
  output$mc_value <- renderText({
    if(m() < 100){
      round(m() * m()/1.5 * 50 + 150)
    }
    else{
      "Max level"
    }
  })
  
  observeEvent(input$increment_buyMine, {
    cost <- round(m() * m()/1.5 * 50 + 150)  # Cost formula: boost^2 * 5
    if (x() >= cost && m() < 100) {     # Check if cookies are sufficient
      x(x() - cost)        # Deduct cookies for the cost
      m(m() + 1)           # Increment auto level
    }
  })
  
  
  output$uc_value <- renderText({
    if(u() < 100){
      round(u() * u()/1.25 * 100 + 750)
    }
    else{
      "Max level"
    }
  })
  
  observeEvent(input$increment_buyUsine, {
    cost <- round(u() * u()/1.5 * 100 + 750)  # Cost formula: boost^2 * 5
    if (x() >= cost && u() < 100) {     # Check if cookies are sufficient
      x(x() - cost)        # Deduct cookies for the cost
      u(u() + 1)           # Increment auto level
    }
  })
  
  autoIncrement <- function() {
    isolate({#pour modifier les valeur reactives hors d'un observe
      if (a() > 0) {
          x(round(x()+(a() - ((a() / 125)))))
      }
    later::later(autoIncrement, 1 - (a()/115))  # Schedule next call in 1 second
    })
  }
  
  autoIncrement2 <- function() {
    isolate({#pour modifier les valeur reactives hors d'un observe
      if (m() > 0) {
        x(round(x()+(m() * 25 - ((m() / 125) * 25))))
      }
      later::later(autoIncrement2, 1 - (m()/115))  # Schedule next call in 1 second
    })
  }
  
  autoIncrement3 <- function() {
    isolate({#pour modifier les valeur reactives hors d'un observe
      if (u() > 0) {
        x(round(x()+(u() * 50 - ((u() / 125) * 50))))
      }
      later::later(autoIncrement3, 1 - (m()/115))  # Schedule next call in 1 second
    })
  }
  
  # Start auto-increment logic
  autoIncrement()
  autoIncrement2()
  autoIncrement3()
  
  
  output$x_value <- renderText({
    round(x())
  })
  
  output$y_value <- renderText({
    y()
  })
  
  output$a_value <- renderText({
    a()
  })

  output$m_value <- renderText({
    m()
  })
  
  output$u_value <- renderText({
    u()
  })  
}

shinyApp(ui = ui, server = server)

