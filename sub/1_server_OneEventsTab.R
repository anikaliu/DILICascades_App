stats_anchor=reactive({
  req(input$select_source,input$select_target,source_events,target_events)
  
  get_stats(source_events=source_events(), 
            target_events=target_events(), 
            bg_target=input$bg_target,
            select_target=input$select_target,
            temporal_relation = input$temporal_relation
  )
  
})