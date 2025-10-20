library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Financial Health"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Explore", tabName = "explore", icon = icon("search")),
      menuItem("Forecasting", tabName = "forecast", icon = icon("line-chart")),
      menuItem("Savings Guide", tabName = "guide", icon = icon("lightbulb")),
      menuItem("Loan Calculator", tabName = "loan", icon = icon("university")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      #HOME TAB
      source("homepage.R")$value,
      
      #EXPLORE TAB
      tabItem(tabName = "explore",
              h2("Explore"),
              p("Dive into the data and uncover insights.")
      ),
      
      #FORECASTING TAB
      tabItem(tabName = "forecast",
              h2("Forecasting"),
              p("Predict future trends.")
      ),
      
      #SAVINGS GUIDE TAB
      source("savingsguide.R")$value,
      
      #LOAN CALCULATOR
      tabItem(tabName = "loans",
              h2("Loan Calculator"),
              p("Need a loan? Try out our calculator!")
      ),
      
      #ABOUT
      tabItem(tabName = "about",
      h2("About This Dashboard"),
      p("This is a project done by Ammar Alhajmee, Bemnet Ali, and Colin Bridges."),
      br(),
      p("Data Sources:")
      )
    )
  )
)
