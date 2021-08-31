source('sub/global.R')

ui = function(request) {
    fluidPage(
        useShinyjs(),
        navbarPage(title="DILI Cascades",
                   footer = column(12, align="center", "DILI Cascades - App"),
                   source("sub/0_ui_overview.R")$value,
                   source("sub/1_ui_OneEventsTab.R")$value,
                   source("sub/2_ui_TwoEventsTab.R")$value,
                   hr()
        ) # close navbarPage
    ) # close fluidPage
}
