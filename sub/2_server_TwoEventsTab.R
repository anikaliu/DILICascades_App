

# shinyServer(function(input, output,session) {
####Select events of interest###
source_events <- reactive({switch(input$source,firstact[[input$source]])})
# source_events <- reactive(firstact[[input$source]])
observeEvent(source_events(), {
  choices <- sort(unique(source_events()$event))
  updatePickerInput(inputId = "select_source", choices = choices,session=session) 
})
target_events <- reactive({switch(input$target,firstact[[input$target]])})
observeEvent(target_events(), {
  choices <- sort(unique(target_events()$event))
  updatePickerInput(inputId = "select_target", choices = choices,session=session) 
})


###Test text
output$value=renderText({
  req(input$select_source,input$select_target)
  paste0('Does\ ', paste0(input$select_source, collapse='/ or'), '\ precede\ ' ,paste0(input$select_target, collapse = '/ or'),'?')
})
output$testtext=renderText({
  paste0(input$select_source, collapse='/ or')
})
first_stats=reactive({
  req(input$select_source,input$select_target,source_events,target_events)
  summarise_to_stats(source_events=source_events(), 
                     target_events=target_events(), 
                     select_source=input$select_source,
                     select_target=input$select_target)
  
})
output$first_stats_summary=renderTable(first_stats()%>%group_by(class, description)%>%summarise(n=n()))
output$first_stats = renderDataTable(first_stats()%>%select(-description, -timeindex_source, -timeindex_target),
                                     options = list(pageLength = 20))
output$main_heatmap=renderPlot({
  
  req(input$select_source,input$select_target)
  first_stats()%>%heatmap_firstact()%>%draw()})

output$source_hist=renderPlot({
  req(input$select_source)
  plot_hist(eventclass = input$source, select_event=input$select_source)      
})
output$target_hist=renderPlot({
  req(input$select_target)
  plot_hist(eventclass = input$target, select_event=input$select_target)      
})  