library(shiny)
library(shinydashboard)
library(shinythemes)
library(shinyjs)

# CFHI UI module
source("R_Scripts/cfhi_feature_ui.R")

dashboardPage(
  dashboardHeader(title = "Financial Health"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home",         tabName = "home",    icon = icon("home")),
      menuItem("Explore",      tabName = "explore", icon = icon("search")),
      menuItem("Forecasting",  tabName = "forecast",icon = icon("line-chart")),
      menuItem("Savings Guide",tabName = "guide",   icon = icon("lightbulb")),
      menuItem("Loan Calculator", tabName = "loan", icon = icon("university")),
      menuItem("About",        tabName = "about",   icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    useShinyjs(),   # only needed if you use shinyjs anywhere (safe to keep)
    tabItems(
      # HOME TAB (sourced file must return a tabItem with tabName = "home")
      source("homepage.R")$value,
      
<<<<<<< HEAD
      # SAVINGS GUIDE TAB (sourced file must return a tabItem with tabName = "guide")
      source("savingsguide.R")$value,
      
      # FORECASTING TAB
=======
      #EXPLORE TAB
      source("explore.R")$value,
      
      #FORECASTING TAB
>>>>>>> bf67db2ca52c702843138c93df502511ddd1c000
      tabItem(tabName = "forecast",
              h2("Forecasting"),
              p("Predict future trends.")
      ),
      
<<<<<<< HEAD
      # EXPLORE TAB
      tabItem(tabName = "explore",
              h2("Explore"),
              p("Dive into the data and uncover insights.")
      ),
      
      # LOAN CALCULATOR TAB (tabName must match the sidebar)
      tabItem(tabName = "loan",
=======
      #SAVINGS GUIDE TAB
      source("savingsguide.R")$value,
      
      #LOAN CALCULATOR
      tabItem(tabName = "loans",
>>>>>>> bf67db2ca52c702843138c93df502511ddd1c000
              h2("Loan Calculator"),
              p("Need a loan? Try out our calculator!")
      ),
      
<<<<<<< HEAD
      # ABOUT TAB
=======
      #ABOUT
>>>>>>> bf67db2ca52c702843138c93df502511ddd1c000
      tabItem(tabName = "about",
              h2("About This Dashboard"),
              p("This is a project done by Ammar Alhajmee, Bemnet Ali, and Colin Bridges."),
              br(),
              p("Data Sources:")
      )
    )
  )
)
