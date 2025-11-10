# ===============================================================================
# AUTO-INSTALL MISSING PACKAGES
# ===============================================================================
# This checks and installs any missing packages before loading them
required_packages <- c("shiny", "shinydashboard", "shinythemes", "shinyjs",
                       "tidyverse", "readxl", "plotly", "DT", "zoo",
                       "lubridate", "forecast", "glmnet", "randomForest")


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
library(DT)


# CFHI UI module
source("tabs/cfhi_feature_ui.R")


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
market_correlation_tab <- safe_source_tab("tabs/market_correlation_tab.R", "market_correlation")
market_data_tab <- safe_source_tab("tabs/market_data_sources_tab.R", "market_data")
findings_tab   <- safe_source_tab("tabs/findings_tab.R", "findings")
guide_tab      <- safe_source_tab("tabs/savingsguide.R", "guide")
overview_tab   <- safe_source_tab("tabs/overview.R", "overview")
loan_tab       <- safe_source_tab("tabs/loans.R", "loans")
retirement_tab <- safe_source_tab("tabs/retirement_tab.R", "retirement_tab")
credit_tab     <- safe_source_tab("tabs/credit_tab.R", "credit_tab")
about_tab      <- safe_source_tab("tabs/about_tab.R", "about")


dashboardPage(
  dashboardHeader(title = "Financial Health"),
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Home",            tabName = "home",     icon = icon("home")),
      menuItem("CFHI Analysis",   icon = icon("chart-line"),
               menuSubItem("Overview", tabName = "cfhi"),
               menuSubItem("Key Findings", tabName = "findings"),
               menuSubItem("Forecasting", tabName = "forecast"),
               menuSubItem("S&P 500 Correlation", tabName = "market_correlation"),
               menuSubItem("Data Sources", tabName = "cfhi_data"),
               menuSubItem("Market Data Sources", tabName = "market_data")
      ),
      menuItem("State Analysis", icon = icon("map-marked-alt"),
               menuSubItem("Explore States", tabName = "explore"),
               menuSubItem("Data Sources", tabName = "state_data")
      ),
      menuItem("Personal Finance", icon = icon("wallet"),
               menuSubItem("Overview",   tabName = "overview",    icon = icon("compass")),
               menuSubItem("Credit Card Approval",   tabName = "credit",    icon = icon("dollar-sign")),
               menuSubItem("Savings Guide",   tabName = "guide",    icon = icon("money-check-alt")),
               menuSubItem("Loan Calculator", tabName = "loans",     icon = icon("university")),
               menuSubItem("Retirement", tabName = "retirement",     icon = icon("umbrella-beach"))
      ),
      menuItem("About",           tabName = "about",    icon = icon("info-circle"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
       .main-header .logo {
         font-family: 'Trebuchet MS', sans-serif !important;
         font-size: 22px !important;
         font-weight: 600 !important;
         letter-spacing: 0.5px !important;
       }
      
       /* Fix button text visibility */
       .btn-primary,
       .btn-primary:hover,
       .btn-primary:focus,
       .btn-primary:active,
       .btn-success,
       .btn-success:hover,
       .btn-success:focus,
       .btn-success:active,
       .btn-info,
       .btn-info:hover,
       .btn-info:focus,
       .btn-info:active,
       .btn-warning,
       .btn-warning:hover,
       .btn-warning:focus,
       .btn-warning:active,
       .btn-danger,
       .btn-danger:hover,
       .btn-danger:focus,
       .btn-danger:active,
       .shiny-download-link.btn-primary,
       .shiny-download-link.btn-success,
       .shiny-download-link.btn-info,
       .action-button {
         color: #ffffff !important;
       }
      
       /* Ensure icons are also white */
       .btn-primary i,
       .btn-success i,
       .btn-info i,
       .btn-warning i,
       .btn-danger i,
       .shiny-download-link i {
         color: #ffffff !important;
       }
     "))
    ),
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
      
      # MARKET CORRELATION ANALYSIS
      market_correlation_tab,
      
      # MARKET DATA SOURCES
      market_data_tab,
      
      # KEY FINDINGS
      findings_tab,
      
      # OVERVIEW TAB (from overview.R)
      overview_tab,
      
      # CREDIT CARD GUIDE (from credit_tab.R)
      credit_tab,
      
      # SAVINGS GUIDE (from savingsguide.R)
      guide_tab,
      
      # LOAN CALCULATOR (from loans.R)
      loan_tab,
      
      # RETIREMENT (from retirement.R)
      retirement_tab,
      
      # ABOUT (from about_tab.R)
      about_tab
    )
  )
)



