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


stats=reactive({
  req(input$picker_adverse, input$source)
  get_stats(source=input$source,
            top_events=topact[[input$source]],
            bg_target=input$picker_background,
            select_target=input$picker_adverse,
            include_same_time = input$include_same_time)
})
output$stats = DT::renderDataTable({
  stats()%>%
    mutate(pval=signif(pval, 3),
           FPR=signif(FPR,3),
           Jaccard=signif(Jaccard,3),
           TPR=signif(TPR,3),
           PPV=signif(PPV,3),
           Lift=signif(Lift,3),
           `Odds Ratio`=signif(`Odds Ratio`,3))%>%
    filter(pval<=input$pval)%>%
    DT::datatable(escape=F, filter = "top", 
                  extensions = "Buttons", rownames = F,
                  option = list(scrollX = T, 
                                autoWidth = T, 
                                dom = "Bfrtip",
                                buttons = c("copy", "csv", "excel")))
  })


stats_filtered <- reactive({
  req(stats())
  stats()[input$stats_rows_all, ]  
})

output$plot_pairs=renderPlot({
  variance=stats_filtered()%>%ungroup()%>%summarise(across(TP:colnames(.)[length(colnames(.))],var))%>%t()
  n_levels=stats_filtered()%>%ungroup()%>%summarise(across(TP:colnames(.)[length(colnames(.))],function(x){length(unique(x))}))%>%t()
  variable=intersect(setdiff(rownames(variance)[(variance>0)],c(NA, NaN)),rownames(n_levels)[(n_levels>2)])
  ggpairs(stats_filtered()%>%select_at(c('direction', intersect(input$picker_metrics, variable))),
          mapping=aes(color=direction, alpha=0.9),showStrips = T,
            upper = list(continuous = "density", combo = "box_no_facet"))+
    theme_bw()+
    scale_color_manual(values = cols)+
    scale_fill_manual(values = cols)
})

output$plots_standard=renderggiraph({
  stats_filtered_tmp=stats_filtered()%>%rowwise()%>%
    mutate(event=gsub(event, pattern = "\'", replacement = '"'))
  gg1=ggplot(stats_filtered_tmp, aes(TPR, PPV, color=direction), alpha=0.8)+
    geom_point_interactive(aes(tooltip = event, data_id = event ))+
    scale_color_manual(values = cols)+
    theme_bw()+
    theme(legend.position = 'None')

  gg3=ggplot(stats_filtered_tmp,aes_string(input$picker_metrics_x, input$picker_metrics_y, color='direction'), alpha=0.8)+
    geom_point_interactive(aes(tooltip = event, data_id = event )) +
    scale_color_manual(values = cols)+
    theme_bw()+
    scale_x_continuous(trans = ifelse(input$logarithmic_x,"log10","identity"))+
    scale_y_continuous(trans = ifelse(input$logarithmic_y,"log10","identity"))
  girafe(
    ggobj = plot_grid(gg1, gg3, rel_widths = c(3,4)), 
    width_svg = 8, height_svg = 4,
    options = list(opts_hover_inv(css = "opacity:0.5"),
                   opts_hover(css = "fill:wheat;stroke:orange;r:6pt;"),
                   opts_selection(type = "single")
                   )
    )
})
