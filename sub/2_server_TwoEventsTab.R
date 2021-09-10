####Select event class of interest####
source_events <- reactive({switch(input$source,firstact[[input$source]])})
source_top <- reactive({switch(input$source,topact[[input$source]])})
target_events <- reactive({switch(input$target,firstact[[input$target]])})

####Update UI based on user input####
observeEvent(source_events(), {
  choices <- sort(unique(source_events()$event))
  updatePickerInput(inputId = "select_source", choices = choices,session=session) 
})

observeEvent(target_events(), {
  choices <- sort(unique(target_events()$event))
  updatePickerInput(inputId = "select_target", choices = choices,session=session) 
})
observeEvent(input$default_target, {
  updatePickerInput(session,"select_target",selected = adverse_cond)
  updateRadioButtons(session,"target",selected = 'Histopathology')
})

####Text####
output$selected_source=renderText({
  req(input$select_source)
  paste0('Occurrences of any of the following ',input$source,'\ events: ', paste0(input$select_source, collapse=','))
})

output$selected_target=renderText({
  req(input$select_source, input$target)
  paste0('Occurrences of any of the following ',input$target,'\ events: ', paste0(input$select_target, collapse=','))
})
####Data####
first_stats=reactive({
  req(input$select_source,input$select_target,source_events,target_events)
  summarise_to_stats(source_events=source_events(), 
                     target_events=target_events(), 
                     select_source=input$select_source,
                     select_target=input$select_target)
  
})
####Table####
output$first_stats_summary=renderTable(first_stats()%>%group_by(class, description)%>%summarise(n=n()))
output$first_stats = DT::renderDataTable({
  first_stats()%>%select(-description, -timeindex_source, -timeindex_target)%>%
    DT::datatable(escape=F, filter = "top", 
                  extensions = "Buttons", rownames = F,
                  option = list(scrollX = T, 
                                autoWidth = T, 
                                dom = "Bfrtip",
                                buttons = c("copy", "csv", "excel")
                                )
                  )
}
)

####Plots####
output$main_heatmap=renderPlot({
  req(input$select_source,input$select_target)
  first_stats()%>%heatmap_firstact()%>%draw()
  })

output$source_hist=renderggiraph({
  req(input$select_source)
  plot_hist(eventclass = input$source, select_event=input$select_source, type='preceding')      
})
output$target_hist=renderggiraph({
  req(input$select_target)
  plot_hist(eventclass = input$target, select_event=input$select_target, type='later')      
})  

