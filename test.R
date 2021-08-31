library(shiny)
library(shinyWidgets)

ui <- fluidPage(
  pickerInput(
    inputId = "picker_adverse", 
    selected = adverse_cond,
    label = NULL, 
    choices = sort(unique(firstact[['Histopathology']]$event)),
    options = list(
      `actions-box` = TRUE, 
      size = 12
    ), 
    multiple = TRUE
  ),
  
  actionButton(
    inputId = "default_adverse",
    label = "Use default"
  )
)

server <- function(session, input, output) {
  observeEvent(input$default_adverse, {
    updatePickerInput(
      session, 
      "picker_adverse", 
      selected = adverse_cond
    )
  })
}

shinyApp(ui = ui, server = server)