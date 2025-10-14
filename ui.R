library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Financial Health"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Explore", tabName = "explore", icon = icon("search")),
      menuItem("Forecasting", tabName = "explore", icon = icon("line-chart")),
      menuItem("Savings Guide", tabName = "guide", icon = icon("lightbulb")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "home",
              h2("Welcome to the Home Page")
      ),
      tabItem(tabName = "about",
              h2("About This Dashboard"),
              p("This is a simple example built using shinydashboard.")
      )
    )
  )
)
