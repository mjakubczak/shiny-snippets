library(shiny)

# avoid cache
with_hash <- function(file_path, www_path){
  hash <- tools::md5sum(file_path)
  paste(www_path, hash, sep = "?")
}

ui <- fluidPage(
  # load scripts from www directory
  tags$head(
    tags$script(src = with_hash(
      file_path = "www/main.js",
      www_path = "main.js")
    ),
    tags$link(
      rel = "stylesheet", 
      type = "text/css", 
      href = with_hash(
        file_path = "www/main.css",
        www_path = "main.css"
      )
    )
  ),
  
  titlePanel("Long choice names demo"),
  
  sidebarLayout(
    sidebarPanel = sidebarPanel(
      selectizeInput(
        inputId = "my_input",
        label = "Pick some items",
        choices = NULL,
        multiple = TRUE,
        width = "300px",
        options = list(
          # this plugin adds the 'X" button
          plugins = list("remove_button"),
          # format_item is a js function available in the main.js file
          # full documentation for this option:
          # https://selectize.dev/docs/usage#custom-rendering
          render = I("{option: format_item, item: format_item}")
        )
      )
    ),
    
    mainPanel = mainPanel(
      h3("Original values are passed to the server side"),
      verbatimTextOutput("result")
    )
  )
)

long_choices <- c(
  "some_very_long_name_that_cannot_fit_in_the_selectize_box_but_we_really_want_to_use_it_in_our_application",
  "another_long_name_that_also_cannot_fit_but_its_essential_to_use_it_because_of_its_significance",
  "if_this_option_wasnt_used_world_would_collapse_because_of_the_temporal_paradox_like_in_the_back_to_the_future"
)

server <- function(input, output, session) {
  Choices <- reactive({
    # normally some geneset list comes here
    long_choices
  })
  
  observe({
    updateSelectizeInput(
      session = session, 
      inputId = "my_input",
      choices = Choices(), 
      server = TRUE
    )
  })
  
  output$result <- renderPrint({
    input$my_input
  })
}

shinyApp(ui, server)
