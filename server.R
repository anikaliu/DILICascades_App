#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
server = function(input, output, session) {
  source("sub/2_ui_TwoEventsTab.R")
  source("sub/1_server_OneEventsTab.R")
}
