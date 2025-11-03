library(shiny)
library(shinydashboard)
library(shinythemes)
library(shinyjs)

# CFHI UI module
source("R_Scripts/cfhi_feature_ui.R")

# ---- Safe sourcing helper: returns a tabItem or a friendly error tab ----
safe_source_tab <- function(path, tab_fallback_name) {
  tryCatch(
    source(path, local = TRUE)$value,
    error = function(e) {
      tabItem(
        tabName = tab_fallback_name,
        h2(sprintf("Error loading %s", path)),
        div(
          style="white-space:pre-wrap; font-family:monospace; background:#fff3cd; border:1px solid #ffeeba; padding:12px; border-radius:8px;",
          paste("•", conditionMessage(e))
        )
      )
    }
  )
}

# Source your tabs (each file should return a single tabItem(...))
id = "tabs"
<<<<<<< HEAD
home_tab   <- safe_source_tab("frontpage.R",     "home")
cfhi_tab   <- safe_source_tab("cfhi_tab.R",     "cfhi")
explore_tab<- safe_source_tab("explore.R",      "explore")
guide_tab  <- safe_source_tab("savingsguide.R", "guide")
loan_tab  <- safe_source_tab("loans.R", "loans")
=======
home_tab       <- safe_source_tab("frontpage.R",     "home")
cfhi_tab       <- safe_source_tab("cfhi_tab.R",     "cfhi")
cfhi_data_tab  <- safe_source_tab("cfhi_data_tab.R", "cfhi_data")
explore_tab    <- safe_source_tab("state_analysis_tab.R", "explore")
state_data_tab <- safe_source_tab("state_data_tab.R", "state_data")
forecast_tab   <- safe_source_tab("forecast_tab.R", "forecast")
guide_tab      <- safe_source_tab("savingsguide.R", "guide")
overview_tab   <- safe_source_tab("overview.R", "overview")
loan_tab       <- safe_source_tab("loans.R", "loans")
>>>>>>> f379675c3c38465170f8f0235abad12fb9c52063

dashboardPage(
  dashboardHeader(title = "Financial Health"),
  
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs", 
      menuItem("Home",            tabName = "home",     icon = icon("home")),
      menuItem("CFHI Analysis",   tabName = "cfhi",     icon = icon("chart-line")),
      menuItem("Explore",         tabName = "explore",  icon = icon("search")),
      menuItem("Forecasting",     tabName = "forecast", icon = icon("line-chart")),
<<<<<<< HEAD
      menuItem("Savings Guide",   tabName = "guide",    icon = icon("lightbulb")),
      menuItem("Loan Calculator", tabName = "loans",     icon = icon("university")),
=======
      menuItem("Personal Finance", icon = icon("lightbulb"),
        menuSubItem("Overview",   tabName = "overview",    icon = icon("lightbulb")),
        menuSubItem("Savings Guide",   tabName = "guide",    icon = icon("lightbulb")),
        menuSubItem("Loan Calculator", tabName = "loans",     icon = icon("university"))
      ),
>>>>>>> f379675c3c38465170f8f0235abad12fb9c52063
      menuItem("About",           tabName = "about",    icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    useShinyjs(),
    
      source("frontpage.R")$value,
    
    tabItems(
      # HOME (from homepage.R)
      home_tab,
      
      # CFHI ANALYSIS (from cfhi_tab.R)
      cfhi_tab,
      
      # EXPLORE (from explore.R)
      explore_tab,
      
      # FORECASTING
      tabItem(
        tabName = "forecast",
        h2("Forecasting"),
        p("Predict future trends.")
      ),
      
      # SAVINGS GUIDE (from savingsguide.R)
      guide_tab,
      
<<<<<<< HEAD
      # LOAN CALCULATOR
      loan_tab,
        
      
=======
      # LOAN CALCULATOR (from loans.R)
      loan_tab,
>>>>>>> f379675c3c38465170f8f0235abad12fb9c52063
      
      # ABOUT
      tabItem(
        tabName = "about",
        h2("About This Dashboard"),
        p("This is a project done by Ammar Alhajmee, Bemnet Ali, and Colin Bridges."),
        br(),
        p("Data Sources:")
      )
    )
  )
)
