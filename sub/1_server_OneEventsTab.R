observeEvent(input$default_adverse, {
  updatePickerInput(
    session,
    "picker_adverse",
    selected = adverse_cond
  )
})

observeEvent(input$default_background, {
  updatePickerInput(
    session,
    "picker_background",
    selected = ""
  )
})


stats_TF=reactive({
  req(input$picker_adverse)
  get_stats(source_events=firstact$TF,
            bg_target=input$picker_background,
            select_target=input$picker_adverse,
            include_same_time = input$include_same_time)%>%
    arrange(desc(pval))
})
output$stats_TF = renderDataTable(
  {datatable(stats_TF()$df_result%>%
               mutate(pval=format.pval(pval, digits=2)))%>%
      formatRound(c(5:10), 2)}
  )

stats_pathway=reactive({
  req(input$picker_adverse)
  get_stats(source_events=firstact$Pathway,
            bg_target=input$picker_background,
            select_target=input$picker_adverse,
            include_same_time = input$include_same_time)
})
output$stats_pathway = renderDataTable(
  {datatable(stats_pathway()$df_result%>%
               mutate(pval=format.pval(pval, digits=2)))%>%
      formatRound(c(4:9), 2)}
)

stats_histo=reactive({
  req(input$picker_adverse)
  get_stats(source_events=firstact$Histopathology,
            bg_target=input$picker_background,
            select_target=input$picker_adverse,
            include_same_time = input$include_same_time)
})
output$stats_histo = renderDataTable(
  {datatable(stats_histo()$df_result)%>%
      formatRound(c(4:9), 2)}
)