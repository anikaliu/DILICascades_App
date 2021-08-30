tabPanel(title = "One anchoring event of interest",
         icon = icon("dot-circle",  lib = "font-awesome"),
         sidebarLayout(
           sidebarPanel(
             radioButtons(inputId="adverse_histo_class", 
                          label="Adverse histopathology", 
                          choices=c("Adverse (Paper)","Define")
                          ),
             conditionalPanel(condition= 'input.adverse_histo_class == "Define"',
                              pickerInput(inputId = "adverse_histo", 
                                          multiple=T,selected = adverse_cond,
                                          options = list(actionsBox = TRUE, 
                                                         size = 10,
                                                         `selected-text-format` = "count > 3",
                                                         liveSearch=T), 
                                          choices = sort(unique(firstact[['Histopathology']]$event)))
                              ),
             radioButtons(inputId="bg_histo_class", 
                          label="Background histopathology", 
                          choices=c("Background (Paper)","Define"),
                          inline=TRUE),
             conditionalPanel(condition= 'input.bg_histo_class == "Define"',
                              pickerInput(inputId = "bg_histo", 
                                          multiple=T,
                                          options = pickerOptions(liveSearch=T), 
                                          choices = sort(unique(firstact[['Histopathology']]$event)))
                              ),
             radioButtons(inputId="temporal_relation", 
                          label="Temporal relation", 
                          choices=c("Before","Before or at the same time"),
                          inline=TRUE)
             ),
           mainPanel(
             tabsetPanel(type = "tabs",
                         tabPanel(title = "TFs"),
                         tabPanel(title = "Pathway"),
                         tabPanel(title = "Histopathology")
                         )
             )
           )
         )