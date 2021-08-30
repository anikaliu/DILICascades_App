source('sub/global.R')

ui = function(request) {
    fluidPage(
        useShinyjs(),
        navbarPage(title="Time concordance in TG-GATES in vivo liver data",
                   footer = column(12, align="center", "DILI Time Concordance - App"),
                   source("sub/0_ui_overview.R")$value,
                   source("sub/1_ui_OneEventsTab.R")$value,
                   source("sub/2_ui_TwoEventsTab.R")$value,
                   # source("sub/02_ui_targets.R")$value,
                   # source("sub/03_ui_analysis.R")$value,
                   # source("sub/04_ui_vis.R")$value,
                   hr()
        ) # close navbarPage
    ) # close fluidPage
}
