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
market_correlation_tab <- safe_source_tab("tabs/market_correlation_tab.R", "market_correlation")
market_data_tab <- safe_source_tab("tabs/market_data_sources_tab.R", "market_data")
guide_tab      <- safe_source_tab("tabs/savingsguide.R", "guide")
overview_tab   <- safe_source_tab("tabs/overview.R", "overview")
loan_tab       <- safe_source_tab("tabs/loans.R", "loans")

dashboardPage(
  dashboardHeader(title = "FINANCIAL HEALTH"),
  
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs", 
      menuItem("Home",            tabName = "home",     icon = icon("home")),
      menuItem("CFHI Analysis",   icon = icon("chart-line"),
               menuSubItem("Analysis", tabName = "cfhi"),
               menuSubItem("Forecasting", tabName = "forecast"),
               menuSubItem("Data Sources", tabName = "cfhi_data")
      ),
      menuItem("State Analysis", icon = icon("map-marked-alt"),
               menuSubItem("Explore States", tabName = "explore"),
               menuSubItem("Data Sources", tabName = "state_data")
      ),
      menuItem("Market Analysis", icon = icon("chart-bar"),
               menuSubItem("S&P 500 Correlation", tabName = "market_correlation"),
               menuSubItem("Market Data Sources", tabName = "market_data")
      ),
      menuItem("Personal Finance", icon = icon("lightbulb"),
               menuSubItem("Overview",   tabName = "overview",    icon = icon("lightbulb")),
               menuSubItem("Savings Guide",   tabName = "guide",    icon = icon("lightbulb")),
               menuSubItem("Loan Calculator", tabName = "loans",     icon = icon("university"))
      ),
      menuItem("About",           tabName = "about",    icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .main-header .logo {
          font-family: 'Poppins', sans-serif !important;
          font-size: 24px !important;
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
      
      # OVERVIEW TAB (from overview.R)
      overview_tab,
      
      # SAVINGS GUIDE (from savingsguide.R)
      guide_tab,
      
      # LOAN CALCULATOR (from loans.R)
      loan_tab,
      
      # ABOUT
      tabItem(
        tabName = "about",
        
        fluidRow(
          column(12,
            h2(style = "font-weight: 600; color: #1e293b; margin-bottom: 20px;", 
               "About This Dashboard"),
            p(style = "color: #64748b; font-size: 15px; margin-bottom: 30px;",
              "A comprehensive financial health analytics platform developed for Business and Economics Analytics.")
          )
        ),
        
        # Project Overview
        fluidRow(
          box(
            title = "Project Overview",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            tags$div(
              style = "padding: 15px; line-height: 1.8;",
              
              tags$p(
                style = "color: #475569; font-size: 15px;",
                "This interactive dashboard provides comprehensive analysis of household financial well-being through the Composite Financial Health Index (CFHI). ",
                "The platform integrates multiple economic indicators, state-level comparisons, market correlations, and personal finance tools to offer ",
                "insights into financial health trends and forecasts. Built as a data science visualization project for BIOL 185."
              ),
              
              tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Key Capabilities"),
              tags$ul(
                style = "color: #475569; font-size: 15px;",
                tags$li(tags$strong("CFHI Analysis:"), " Track composite financial health from 2000-2025 with component breakdowns"),
                tags$li(tags$strong("Time Series Forecasting:"), " Ensemble ARIMA/ETS models with multiple economic scenarios"),
                tags$li(tags$strong("Market Correlation:"), " Analyze relationships between S&P 500 and household finances"),
                tags$li(tags$strong("State Comparisons:"), " Geographic analysis of economic indicators across U.S. states"),
                tags$li(tags$strong("Personal Finance Tools:"), " Loan calculators, savings guides, and financial planning resources")
              )
            )
          )
        ),
        
        # Development Team
        fluidRow(
          box(
            title = "Development Team",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            
            tags$div(
              style = "padding: 15px;",
              tags$p(
                style = "color: #475569; font-size: 15px; margin-bottom: 20px;",
                "This project was developed by:"
              ),
              tags$ul(
                style = "color: #475569; font-size: 15px; line-height: 2;",
                tags$li(tags$strong("Ammar Alhajmee")),
                tags$li(tags$strong("Bemnet Ali")),
                tags$li(tags$strong("Colin Bridges"))
              ),
              tags$p(
                style = "color: #64748b; font-size: 14px; margin-top: 20px;",
                "Course: BIOL 185 - Data Science: Visualizing and Exploring Big Data"
              )
            )
          ),
          
          box(
            title = "Technical Stack",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            
            tags$div(
              style = "padding: 15px;",
              tags$ul(
                style = "color: #475569; font-size: 15px; line-height: 2;",
                tags$li(tags$strong("Framework:"), " R Shiny with shinydashboard"),
                tags$li(tags$strong("Visualization:"), " plotly, ggplot2"),
                tags$li(tags$strong("Data Processing:"), " tidyverse (dplyr, tidyr, readr)"),
                tags$li(tags$strong("Time Series:"), " forecast package"),
                tags$li(tags$strong("Statistical Modeling:"), " glmnet")
              )
            )
          )
        ),
        
        # Data Sources Section
        fluidRow(
          box(
            title = "Data Sources",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            
            tags$div(
              style = "padding: 15px; line-height: 1.8;",
              
              tags$h4(style = "color: #1e293b; margin-bottom: 15px;", "CFHI Components"),
              tags$ul(
                style = "color: #475569; font-size: 15px;",
                tags$li(tags$strong("Federal Reserve Economic Data (FRED):"), " Personal savings rates, borrowing rates, inflation metrics"),
                tags$li(tags$strong("Bureau of Labor Statistics (BLS):"), " Wage data, Consumer Price Index (CPI)"),
                tags$li(tags$strong("Coverage:"), " January 2000 to December 2025, monthly frequency")
              ),
              
              tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Market Data"),
              tags$ul(
                style = "color: #475569; font-size: 15px;",
                tags$li(tags$strong("FactSet Research Systems:"), " S&P 500 price history, total returns, volume data"),
                tags$li(tags$strong("Coverage:"), " April 2006 to August 2025, end-of-month observations")
              ),
              
              tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "State Economic Data"),
              tags$ul(
                style = "color: #475569; font-size: 15px;",
                tags$li(tags$strong("U.S. Census Bureau:"), " State median income statistics"),
                tags$li(tags$strong("Bureau of Labor Statistics:"), " State unemployment rates"),
                tags$li(tags$strong("Various Sources:"), " Cost of living indices")
              ),
              
              tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Loan Data"),
              tags$ul(
                style = "color: #475569; font-size: 15px;",
                tags$li(tags$strong("Note:"), " Synthetic dataset created for educational and demonstration purposes"),
                tags$li(tags$strong("Variables:"), " Credit scores, income levels, debt-to-income ratios, approval outcomes")
              )
            )
          )
        ),
        
        # Methodology
        fluidRow(
          box(
            title = "Methodology Notes",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            tags$div(
              style = "padding: 15px;",
              tags$ul(
                style = "color: #475569; font-size: 15px; line-height: 1.8;",
                tags$li(tags$strong("CFHI Calculation:"), " Composite index synthesizing normalized economic indicators with equal weighting"),
                tags$li(tags$strong("Forecasting Method:"), " Ensemble approach averaging ARIMA and ETS models for improved accuracy"),
                tags$li(tags$strong("Correlation Analysis:"), " Both Pearson and Spearman methods to capture linear and monotonic relationships"),
                tags$li(tags$strong("Date Normalization:"), " All monthly data standardized to first day of month for consistent merging")
              )
            )
          )
        ),
        
        # Repository and License
        fluidRow(
          box(
            title = "Repository Information",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            
            tags$div(
              style = "padding: 15px; background-color: #f8fafc; border-radius: 8px;",
              tags$p(
                style = "color: #334155; font-size: 14px; margin: 0;",
                tags$strong("GitHub Repository:"), " ",
                tags$a(
                  href = "https://github.com/aalhajmee/business-economics-analytics",
                  target = "_blank",
                  style = "color: #3b82f6; text-decoration: none;",
                  "aalhajmee/business-economics-analytics"
                )
              ),
              tags$p(
                style = "color: #64748b; font-size: 13px; margin-top: 10px; margin-bottom: 0;",
                "Last Updated: November 2025"
              )
            )
          )
        )
      )
    )
  )
)
