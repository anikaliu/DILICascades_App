####Select event class of interest####
wtf_events <- reactive({switch(input$wtf,firstact[[input$wtf]])})
target_events <- reactive({switch(input$target,firstact[[input$target]])})

####Update UI based on user input####
observeEvent(wtf_events(), {
  choices <- sort(unique(wtf_events()$event))
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
  req(input$select_source, input$wtf)
  paste0('Occurrences of any of the following ',input$wtf,'\ events: ', paste0(input$select_source, collapse=','))
})

output$selected_target=renderText({
  req(input$select_target, input$target)
  paste0('Occurrences of any of the following ',input$target,'\ events: ', paste0(input$select_target, collapse=','))
})
####Data####
first_stats=reactive({
  req(input$select_source,input$select_target,wtf_events,target_events)
  summarise_to_stats(source_events=wtf_events(), 
                     target_events=target_events(), 
                     select_source=input$select_source,
                     select_target=input$select_target)
  
})

topstats=reactive({
  req(input$include_same_time, target_events(),input$wtf, input$select_source, input$select_target)
  df_target=target_events()%>%
    filter(event %in% input$select_target)%>%
    group_by(COMPOUND_NAME, rDOSE_LEVEL)%>%
    summarise(timeindex_target=min(time_index))
  
  topact[[input$wtf]]%>%
    filter(event %in% input$select_source)%>%
    mutate(timeindex_source=time_index)%>%
    left_join(df_target%>%select(COMPOUND_NAME, rDOSE_LEVEL, timeindex_target))%>%
    mutate(timeindex_target=ifelse(is.na(timeindex_target),0,timeindex_target),
           description=case_when(timeindex_target==0~'Only preceding event activated in time-series',
                                 timeindex_source==timeindex_target~'First activation of preceding and later event at the same time',
                                 timeindex_source<timeindex_target~'First activation of preceding event before later event',
                                 timeindex_source>timeindex_target~'First activation of preceding event after later event'),
           class=case_when(timeindex_target==0~'only_preceding',
                           timeindex_source==timeindex_target~'same_time',
                           timeindex_source<timeindex_target~'before',
                           timeindex_source>timeindex_target~'after'),
           class=factor(class, levels=c('before','same_time','after','only_preceding','only_later')))%>%
    group_by(COMPOUND_NAME, rDOSE_LEVEL, direction, event, class)%>%
    filter(abs(logFC)==max(abs(logFC)))
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
output$time_definition=renderTable(
  data.frame(SACRIFICE_PERIOD=c("3 hr","6 hr","9 hr","24 hr","4 day","8 day","15 day","29 day"))%>%
    order_timepoints()%>%
    mutate(timeindex=as.numeric(SACRIFICE_PERIOD))%>%
    column_to_rownames(SACRIFICE_PERIOD)%>%
    t()
  )


####Plots####
output$main_heatmap=renderPlotly({
  req(input$select_source,input$select_target)
  #first_stats()%>%heatmap_firstact()%>%draw()
  first_stats()%>%heatmap_firstact()%>%layout(width=800, height=200)
  
  })

output$source_hist=renderggiraph({
  req(input$select_source)
  plot_hist(eventclass = input$wtf, select_event=input$select_source, type='preceding')      
})
output$target_hist=renderggiraph({
  req(input$select_target)
  plot_hist(eventclass = input$target, select_event=input$select_target, type='later')      
})  

output$logFC=renderggiraph({
  req(topstats())
  g=ggplot(topstats()%>%order_rdose_levels()%>%mutate(condition=paste0(COMPOUND_NAME,' (', rDOSE_LEVEL,')')), 
           aes(class,logFC))+
    geom_boxplot(outlier.shape = NA)+
    facet_wrap(~stringr::str_wrap(event, width = 20), ncol = 4)+
    geom_jitter_interactive(aes(tooltip = condition, data_id = condition, color=class),
                            width=0.3, alpha=0.8)+
    theme_bw()+
    scale_color_viridis_d(begin=0.2)+
    theme(axis.text.x = element_blank(), axis.title.x = element_blank(), axis.ticks.x =element_blank())
  
  girafe(ggobj = g,height_svg = 3,
         options = list(opts_hover_inv(css = "opacity:0.5"),
                        opts_hover(css = "fill:wheat;stroke:orange;r:6pt;"),
                        opts_selection(type = "single")
         )
  )
}) 
