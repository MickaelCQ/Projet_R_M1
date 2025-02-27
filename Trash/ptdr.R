library(shiny)

# Define grid dimensions
num_rows <- 10
num_cols <- 10
num_buttons <- num_rows * num_cols

ui <- fluidPage(
  tags$head(
    tags$style(HTML(sprintf("
      .grid-container {
        display: grid;
        grid-template-columns: repeat(%d, 1fr);
        grid-template-rows: repeat(%d, 60px);
        gap: 0px;
        justify-content: center;
        max-width: %dpx;
        margin: auto;
      }
      .grid-button-container {
        position: relative;
      }
      .grid-button {
        width: 50px;
        height: 50px;
      }
      .msg {
        position: absolute;
        top: -30px; /* Position message above button */
        left: 50%%;
        transform: translateX(-50%%);
        background: yellow;
        padding: 5px;
        border-radius: 5px;
        font-size: 12px;
        white-space: nowrap;
      }
    ", num_cols, num_rows - 10, num_cols * 10)))  
  ),
  
  titlePanel("Button Grid with Temporary Messages"),
  
  div(class = "grid-container",
      lapply(1:num_buttons, function(i) {
        div(class = "grid-button-container",
            actionButton(inputId = paste0("btn", i), 
                         label = paste("0"), 
                         class = "grid-button"),
            uiOutput(paste0("msg", i)) # Space for temporary message
        )
      })
  )
)

server <- function(input, output, session) {
  messages <- reactiveValues()  # Store active messages
  
  lapply(1:num_buttons, function(i) {
    observeEvent(input[[paste0("btn", i)]], {
      messages[[paste0("msg", i)]] <- paste("Pressed!", Sys.time())
      
      # Schedule removal of message
      isolate({
        later::later(function() {
          messages[[paste0("msg", i)]] <- NULL
        }, delay = 1)
      })
    })
    
    output[[paste0("msg", i)]] <- renderUI({
      if (!is.null(messages[[paste0("msg", i)]])) {
        div(class = "msg", messages[[paste0("msg", i)]])
      }
    })
  })
}

# Ensure later package is available
if (!requireNamespace("later", quietly = TRUE)) {
  install.packages("later")
}
library(later)

shinyApp(ui, server)
