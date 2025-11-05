# ===============================================================================
# AUTO-INSTALL MISSING PACKAGES
# ===============================================================================
# This checks and installs any missing packages before loading them
required_packages <- c("shiny", "shinydashboard", "shinythemes", "shinyjs", 
                       "tidyverse", "readxl", "plotly", "DT", "zoo", 
                       "lubridate", "forecast", "glmnet")

missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]

if(length(missing_packages) > 0) {
  cat("\n=================================================================\n")
  cat("Installing missing packages:", paste(missing_packages, collapse=", "), "\n")
  cat("=================================================================\n\n")
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
  cat("\n✓ Package installation complete!\n\n")
}

# ===============================================================================
# LOAD LIBRARIES
# ===============================================================================
library(shiny)
library(shinydashboard)
library(shinythemes)
library(shinyjs)
library(plotly)

# CFHI UI module
source("modules/cfhi_feature_ui.R")

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
home_tab       <- safe_source_tab("tabs/frontpage.R",     "home")
cfhi_tab       <- safe_source_tab("tabs/cfhi_tab.R",     "cfhi")
cfhi_data_tab  <- safe_source_tab("tabs/cfhi_data_tab.R", "cfhi_data")
explore_tab    <- safe_source_tab("tabs/state_analysis_tab.R", "explore")
state_data_tab <- safe_source_tab("tabs/state_data_tab.R", "state_data")
forecast_tab   <- safe_source_tab("tabs/forecast_tab.R", "forecast")
guide_tab      <- safe_source_tab("tabs/savingsguide.R", "guide")
overview_tab   <- safe_source_tab("tabs/overview.R", "overview")
loan_tab       <- safe_source_tab("tabs/loans.R", "loans")

dashboardPage(
  dashboardHeader(title = span("FINANCIAL HEALTH", style = "
  font-family: 'Poppins', sans-serif;
  font-size: 24px;
  font-weight: 600;
  color: white;
  letter-spacing: 0.5px;
")),
  
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs", 
      menuItem("Home",            tabName = "home",     icon = icon("home")),
      menuItem("CFHI Analysis",   icon = icon("chart-line"),
               menuSubItem("Analysis", tabName = "cfhi"),
               menuSubItem("Data Sources", tabName = "cfhi_data")
      ),
      menuItem("State Analysis", icon = icon("map-marked-alt"),
               menuSubItem("Explore States", tabName = "explore"),
               menuSubItem("Data Sources", tabName = "state_data")
      ),
      menuItem("Forecasting",     tabName = "forecast", icon = icon("line-chart")),
      menuItem("Personal Finance", icon = icon("lightbulb"),
               menuSubItem("Overview",   tabName = "overview",    icon = icon("lightbulb")),
               menuSubItem("Savings Guide",   tabName = "guide",    icon = icon("lightbulb")),
               menuSubItem("Loan Calculator", tabName = "loans",     icon = icon("university"))
      ),
      menuItem("About",           tabName = "about",    icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tags$script(HTML("
  function goToTab(tabName) {
    Shiny.setInputValue('go_to_tab', tabName, {priority: 'event'});
  }
")),
    
    useShinyjs(),
    
    tabItems(
      # HOME (from homepage.R)
      home_tab,
      
      # CFHI ANALYSIS (from cfhi_tab.R)
      cfhi_tab,
      
      # CFHI DATA SOURCES
      cfhi_data_tab,
      
      # EXPLORE (from state_analysis_tab.R)
      explore_tab,
      
      # STATE DATA SOURCES
      state_data_tab,
      
      # FORECASTING (from forecast_tab.R)
      forecast_tab,
      
      # OVERVIEW TAB (from overview.R)
      overview_tab,
      
      # SAVINGS GUIDE (from savingsguide.R)
      guide_tab,
      
      # LOAN CALCULATOR (from loans.R)
      loan_tab,
      
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
