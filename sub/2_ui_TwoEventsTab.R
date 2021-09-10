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
      actionButton(
        inputId = "default_target",
        label = "Use adverse conditions from paper"
      )
    ),
    
    
    # Show a plot of the generated distribution
    
    mainPanel(
      conditionalPanel(
        condition = "input.select_source == ''||input.select_target==''",
        strong("Please select events of interest to calculate time concordance.")
      ),
      conditionalPanel(
        condition = "input.select_source != ''&&input.select_target!=''",
        h3('Definitions'),
        strong("Definition of preceding event (Source)"),
        textOutput("selected_source"),
        strong("Definition of later event (Target)"),
        textOutput("selected_target"),
        h3('Results'),
        tabsetPanel(
          tabPanel(title = 'Overview',
                   tableOutput("first_stats_summary"),
                   hr(),
                   fluidRow(
                     column(6,title='Source distribution', ggiraphOutput("source_hist")),
                     column(6,title='Target distribution',ggiraphOutput("target_hist"))
                   )%>%
                     withSpinner(color="#F25D18")
                   ),
          tabPanel(title='Individual time series',
                   plotOutput("main_heatmap", height = 300)%>%
                     withSpinner(color="#F25D18"), 
                   dataTableOutput("first_stats"))
        )
      )
    )
  )
)
