tabPanel(
  title = "Before adverse histopathology",
  icon = icon("dot-circle",  lib = "font-awesome"),
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        label=h5("Event class"),
        inputId="source", 
        choices=c("TF","Pathway", "Histopathology"),
        inline=TRUE),
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
      hr(),
      materialSwitch(
        inputId = "include_same_time",
        value=T,
        label=h5("Include same time as time concordant",
                 bsButton("q1_2", label = "", icon = icon("question"),size = "extra-small")
                 )
        ),
      hr(),
      bsPopover(
        id = "q1_2", 
        title = "Temporal relation",
        content = "Define whether events with first activation at the same time should be considered as time-concordant or not. As default this is included due to evidence for co-occurrence in the same time series and absence of evidence suggesting a different temporal order."
        ),
      hr(),
      sliderTextInput("pval", "P-value cut-off:",
        choices = c(0.0001,0.001,0.01,0.05,0.1,1),selected = 1,
        grid = TRUE
      )
      ),# close sidePanel
    mainPanel(
      conditionalPanel(
        condition = "input.picker_adverse == ''",
        strong('Please select adverse histopathology to calculate time concordance metrics.')
      ),
      conditionalPanel(
        condition = "input.picker_adverse != ''",
      h2("Summary Table"),
      conditionalPanel(
        condition = "input.wtf == 'Histopathology'",
        strong('WARNING: Adverse and background time series are defined based on histopathology. Therefore statistics for histopathology is biased and should be treated with caution.'),
        hr()
      ),
      dataTableOutput("stats")%>%withSpinner(color="#F25D18"),
      h2('Plots'),
      
      tabsetPanel(
        tabPanel(
          title = "Multiple metrics overview",
          pickerInput(
            inputId = "picker_metrics",
            label=h5("Time concordance metrics to show"),
            multiple=T,
            selected = c('Odds ratio','FPR','TPR','PPV','pval','logFC','Jaccard'),
            options = list(
              `actions-box` = TRUE, 
              size = 12,
              liveSearch=T
            ), 
            choices = c('Odds ratio','TP','FP','FPR','TPR','PPV','pval','logFC','Jaccard','Lift')
          ),
          plotOutput("plot_pairs",
                     hover = "plot_hover",
                     height='1000px')%>%
            withSpinner(color="#F25D18")
        ),
        tabPanel(
          title='Two metrics in detail',
          fluidRow(
            column(4,
              pickerInput(
                inputId = "picker_metrics_x",
                label="x-axis",
                multiple=F,
                selected = c('logFC'),
                options = list(`actions-box` = TRUE, size = 12,liveSearch=T), 
                choices = c('Odds ratio','TP','FP','FPR','TPR','PPV','pval','logFC','Jaccard','Lift')
                ),
              prettyCheckbox(
                inputId = "logarithmic_x",
                label = "Logarithmic x-axis", 
                value = F
                )
              ),
            column(
              4,
              pickerInput(
                inputId = "picker_metrics_y",
                label="y-axis",
                multiple=F,
                selected = c('pval'),
                options = list(`actions-box` = TRUE, size = 12,liveSearch=T), 
                choices = c('Odds ratio','TP','FP','FPR','TPR','PPV','pval','logFC','Jaccard','Lift')
              ),
              prettyCheckbox(
                inputId = "logarithmic_y",
                label = "Logarithmic y-axis", 
                value = TRUE
              )
            )
          )
        ,
          ggiraphOutput("plots_standard")%>%
            withSpinner(color="#F25D18")
        
        )
      )
      )
      )# close mainPanel
    )# close sidebarLayout
  )# close TabPanel
