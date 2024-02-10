library(shiny)

source("module.R")
source("helpers.R")

logger::log_threshold(logger::TRACE)

# the app ---------------------------------------------------------------------
ui <- fluidPage(
  tags$head(
    tags$script(src = with_hash(
      file_path = "www/main.js",
      www_path = "main.js"
    ))
  ),
  
  titlePanel("Data Table expandable rows demo"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      actionButton(
        inputId = "update_rows",
        label = "Update row value"
      ),
      actionButton(
        inputId = "update_dt",
        label = "Refresh DT"
      )
    ),
    
    mainPanel(
      width = 9,
      DT::dataTableOutput("table")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  Click_source <- reactive({
    input$update_rows
  })
  
  # make sure we create only required modules ---------------------------------
  modules <- list()
  
  event_id <- "row_expanded"
  observeEvent(
    eventExpr = input[[event_id]],
    handlerExpr = {
      module_id <- input[[event_id]]$value # table callback sends this value
      logger::log_debug("event received for module {module_id}")
      
      if (is.null(modules[[module_id]])){
        modules[[module_id]] <<- TRUE
        logger::log_trace("creating new module")
        
        my_moduleServer(
          id = module_id,
          Click_source = Click_source
        )
      } else {
        logger::log_trace("module already existst, no need to create a new one")
      }
    }
  )
  
  # display the table ---------------------------------------------------------
  Input_data <- reactive({
    iris
  })
  
  output$table <- DT::renderDataTable({
    input$update_dt # refresh trigger
    df <- Input_data()
    
    logger::log_debug("table refresh")
    
    df <- format_dt(df)
    
    # 0-based indexes
    id_column_idx <- which(colnames(df) == "module_id") - 1
    ui_column_idx <- which(colnames(df) == "output_container") - 1
    
    options <- list(
      columnDefs = list(
        list(
          orderable = FALSE,
          searchable = FALSE,
          className = "dt-control",
          targets = 0 # expandable buttons
        ),
        list(
          visible = FALSE,
          targets = c(id_column_idx, ui_column_idx)
        )
      )
    )
    
    js_callback <- glue::glue(
      "mainTableCallback(table, '{event_id}', {id_column_idx}, {ui_column_idx});"
    )
    
    DT::datatable(
      data = df,
      callback = DT::JS(js_callback),
      options = options,
      selection = "none",
      rownames = FALSE,
      escape = FALSE, # otherwise module outputs won't be displayed as HTML
      filter = "top"
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
