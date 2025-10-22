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
home_tab   <- safe_source_tab("frontpage.R",     "home")
cfhi_tab   <- safe_source_tab("cfhi_tab.R",     "cfhi")
explore_tab<- safe_source_tab("explore.R",      "explore")
guide_tab  <- safe_source_tab("savingsguide.R", "guide")
loan_tab  <- safe_source_tab("loans.R", "loan")

dashboardPage(
  dashboardHeader(title = "Financial Health"),
  
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs", 
      menuItem("Home",            tabName = "home",     icon = icon("home")),
      menuItem("CFHI Analysis",   tabName = "cfhi",     icon = icon("chart-line")),
      menuItem("Explore",         tabName = "explore",  icon = icon("search")),
      menuItem("Forecasting",     tabName = "forecast", icon = icon("line-chart")),
      menuItem("Savings Guide",   tabName = "guide",    icon = icon("lightbulb")),
      menuItem("Loan Calculator", tabName = "loan",     icon = icon("university")),
      menuItem("About",           tabName = "about",    icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    useShinyjs(),
      source("frontpage.R")$value,
    
    tabItems(
      # HOME (from homepage.R)
      source("frontpage.R")$value,
      
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
      
      # LOAN CALCULATOR
      tabItem(
        tabName = "loan",
        h2("Loan Calculator"),
        p("Need a loan? Try out our calculator!")
      ),
      
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
