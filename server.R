library(shiny)
library(shinydashboard)


ui <- dashboardPage(
  dashboardHeader(title="Consumer Financial Health"),
  dashboardSidebar(),
  dashboardBody()
)

server <- function(input, output) { }

shinyApp(ui, server)
