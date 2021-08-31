tabPanel(
  title = "Before adverse histopathology",
  icon = icon("dot-circle",  lib = "font-awesome"),
  sidebarLayout(
    sidebarPanel(
      pickerInput(
        inputId = "picker_adverse", 
        choices = sort(unique(firstact[['Histopathology']]$event)),
        options = list(
          `actions-box` = TRUE, 
          size = 12,
          liveSearch=T
          ), 
        multiple = TRUE,
        label=h5(
          "Adverse histopathology",
          bsButton("q1_0", label = "", icon = icon("question"),size = "extra-small")
          )
        ),
      bsPopover(
        id = "q1_0", 
        title = "Adverse histopathology",
        content = paste0(
          "Findings which are considered adverse.",
          "By default this is based on previous classifications by histopathologists as described in Liu et al."
          )
        ),
      actionButton(
        inputId = "default_adverse",
        label = "Use default from paper"
        ),
      hr(),
      pickerInput(
        inputId = "picker_background",
        label=h5("Background histopathology",
              bsButton("q1_1", label = "", icon = icon("question"),size = "extra-small")
              ),
        multiple=T,
        options = list(
          `actions-box` = TRUE, 
          size = 12,
          liveSearch=T
          ), 
        choices = sort(unique(firstact[['Histopathology']]$event))
        ),
      bsPopover(
        id = "q1_1", 
        title = "Background histopathology",
        content = paste0(
          "Findings which are considered non-adverse.",
          "These are combined with time-series without any observed histopathology to estimate the background frequency of events.",
          "By default none are tolerated given that early events in the pathogenesis cannot be identified if pre-adverse time-series are included as background."
          )
        ),
      actionButton(
        inputId = "default_background",
        label = "Use default from paper (None)"
      ),
      materialSwitch(
        inputId = "include_same_time",
        value=T,
        label=h5("Regard first activation at the same time as time concordant",
                 bsButton("q1_2", label = "", icon = icon("question"),size = "extra-small")
                 )
        ),
      hr(),
      bsPopover(
        id = "q1_2", 
        title = "Temporal relation",
        content = "Define whether events with first activation at the same time should be considered as time-concordant or not. As default this is included due to evidence for co-occurrence in the same time series and absence of evidence suggesting a different temporal order."
        )
      ),# close sidePanel
    mainPanel(
      tabsetPanel(
        type = "tabs",
        tabPanel(title = "TFs",dataTableOutput("stats_TF")),
        tabPanel(title = "Pathway",dataTableOutput("stats_pathway")),
        tabPanel(title = "Histopathology",dataTableOutput("stats_histo"))
        )
      )# close mainPanel
    )# close sidebarLayout
  )# close TabPanel
