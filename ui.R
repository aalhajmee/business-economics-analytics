library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title="Consumer Financial Health"),
  dashboardSidebar(),
  dashboardBody()
)

dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Your Financial Health", tabName = "your", icon = icon("th"))
  )
)