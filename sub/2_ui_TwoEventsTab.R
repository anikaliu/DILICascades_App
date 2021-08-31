tabPanel(
  title = "Two events of interest",
  icon = icon("arrows-alt-h",  lib = "font-awesome"),
  sidebarLayout(
    sidebarPanel(
      h4("Preceding event",
         bsButton(
           "q2_1", label = "", 
           icon = icon("question"),
           size = "extra-small")
         ),
      bsPopover(
        id = "q2_1", 
        title = "Preceding event",
        content = "This is the event which comes first (Source node). Multiple events can be selected."),
      radioButtons(
        inputId="source", 
        label="Event class", 
        choices=c("TF","Pathway", "Histopathology"),
        inline=TRUE),
      pickerInput(
        inputId = "select_source", label='Event', multiple=T,
        options = pickerOptions(liveSearch=T), 
        choices = NULL),
    
      h4("Later event",
         bsButton(
           "q2_2", label = "", 
           icon = icon("question"),
           size = "extra-small")
      ),
      bsPopover(
        id = "q2_2", 
        title = "Later event",
        content = "This is the event which comes afterwards (Target node). Multiple events can be selected."),
      radioButtons(
        inputId="target", label="Event class", 
        choices=c("TF","Pathway", "Histopathology"),inline=TRUE, selected = "Histopathology"),
      pickerInput(
        inputId = "select_target", label='Event', multiple=T,
        options = pickerOptions(liveSearch=T), choices = NULL,
        selected = adverse_cond),
      conditionalPanel(
        condition= 'input.select_target == "Histopathology"',
        radioButtons(inputId="bg_histo", 
                     label="Which histopathology is tolerated in background time series?", 
                     choices=c("None","Not selected", "Specify"),inline=TRUE, selected = "Histopathology")
      )
    ),
    
    
    # Show a plot of the generated distribution
    
    mainPanel(
      h3('1) Frequency of events in comparison to events of the same class'),
      fluidRow(
        column(6,title='Source distribution', plotOutput("source_hist", height = 300)),
        column(6,title='Target distribution',plotOutput("target_hist", height = 300))
      ),
      h3('2) Overview of time series with at least one of the events'),
      textOutput("value"),
      tableOutput("first_stats_summary"),
      h3('3) Individual time series with at least one of the events'),
      h4('Heatmap'),
      plotOutput("main_heatmap", height = 300),
      h4('Table'),
      dataTableOutput("first_stats")
    )
  )
)
