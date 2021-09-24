source('sub/global.R')

ui = function(request) {
    fluidPage(
        useShinyjs(),
        navbarPage(
            title = div(img(src="logo.png",width="31.99295",  height="20"),
                        "DILI Cascades", style="text-align: center;"),
            windowTitle="DILI Cascades",
                   footer = column(12, align="center", div(img(src="logo.png",width="31.99295",  height="20"),
                                                           "DILI Cascades - App", style="text-align: center;")),
                   source("sub/0_ui_overview.R")$value,
                   source("sub/1_ui_OneEventsTab.R")$value,
                   source("sub/2_ui_TwoEventsTab.R")$value,
                   hr()
        ) # close navbarPage
    ) # close fluidPage
}
