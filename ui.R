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
home_tab <- safe_source_tab("frontpage.R", "home")
cfhi_tab <- safe_source_tab("cfhi_tab.R", "cfhi")
cfhi_data_tab <- safe_source_tab("cfhi_data_tab.R", "cfhi_data")
explore_tab <- safe_source_tab("state_analysis_tab.R", "explore")
state_data_tab <- safe_source_tab("state_data_tab.R", "state_data")
forecast_tab <- safe_source_tab("forecast_tab.R", "forecast")
guide_tab <- safe_source_tab("savingsguide.R", "guide")
overview_tab <- safe_source_tab("overview.R", "overview")
loan_tab <- safe_source_tab("loans.R", "loans")

dashboardPage(
  dashboardHeader(title = span("FINANCIAL HEALTH", style = "
font-family: 'Poppins', sans-serif;
font-size: 19px;
font-weight: 600;
color: white;
letter-spacing: 0.5px;
")),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs", 
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("CFHI Analysis", icon = icon("chart-line"),
               menuSubItem("Dashboard", tabName = "cfhi"),
               menuSubItem("Data Sources", tabName = "cfhi_data")
      ),
      menuItem("State Analysis", icon = icon("map-marked-alt"),
               menuSubItem("Explore States", tabName = "explore"),
               menuSubItem("Data Sources", tabName = "state_data")
      ),
      menuItem("Forecasting", tabName = "forecast", icon = icon("line-chart")),
      menuItem("Personal Finance", icon = icon("lightbulb"),
               menuSubItem("Overview", tabName = "overview", icon = icon("lightbulb")),
               menuSubItem("Savings Guide", tabName = "guide", icon = icon("lightbulb")),
               menuSubItem("Loan Calculator", tabName = "loans", icon = icon("university"))
      ),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
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
      
      # LOAN CALCULATOR
      tabItem(
        tabName = "loan",
        h2("Loan Calculator",
           style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
        p("Need a loan? Try out our calculator!")
      ),
      
      
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


