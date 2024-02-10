# simple module ---------------------------------------------------------------
my_moduleUI <- function(id){
  ns <- NS(id)
  
  uiOutput(ns("info"))
}

my_moduleServer <- function(id, Click_source){
  moduleServer(
    id = id,
    module = function(input, output, session){
      output$info <- renderUI({
        idx <- Click_source()
        paste("Current value:", idx)
      })
    }
  )
}