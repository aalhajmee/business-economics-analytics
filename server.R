library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(readxl)
library(zoo)
library(lubridate)
library(shinydashboard)
library(plotly)
library(shinyjs)
library(DT)
library(forecast)

# CFHI module (reads data/cfhi/cfhi_master_2000_onward.csv)
source("server/cfhi_feature_server.R")

shinyServer(function(input, output, session) {
  observeEvent(input$go_to_tab, {
    updateTabItems(session, "tabs", input$go_to_tab)
  })
  # ---- FORECAST SERVER LOGIC ----
  source("server/forecast_server.R", local = TRUE)
  # ---- STATE ANALYSIS SERVER LOGIC ----
  source("server/state_analysis_server.R", local = TRUE)
  # ---- MARKET CORRELATION SERVER LOGIC ----
  source("server/market_correlation_server.R", local = TRUE)
  # ---- FINDINGS SERVER LOGIC ----
  source("server/findings_server.R", local = TRUE)
  # ---- PERSONAL INSIGHTS LOGIC ----
  source("server/insights_server.R", local = TRUE)
  # ---- CALCULATOR LOGIC ----
  # Source the calculation and loan approval logic
  # These define outputs that need to be in the server scope,
  # so they have access to input/output/session.
  if (file.exists("server/credit_server.R")) {
    source("server/credit_server.R", local = TRUE)
  }
  if (file.exists("server/calculations.R")) {
    source("server/calculations.R", local = TRUE)
  }
  if (file.exists("server/Loan_Approval_Calculator.R")) {
    source("server/Loan_Approval_Calculator.R", local = TRUE)
  }
  if (file.exists("server/retirement_calculator.R")) {
    source("server/retirement_calculator.R", local = TRUE)
  }
  
  # ---- LOAN CALCULATOR TAB ----
  # Source the loans.R file to get the loan_server function
  if (file.exists("tabs/loans.R")) {
    source("tabs/loans.R", local = TRUE)
    # Call the loan server function
    loan_server(input, output, session)
  }
  
  # ---- STATE DATA SOURCES TAB ----
  source("server/state_data_server.R", local = TRUE)
  
  if (file.exists("server/Employment.R")) {
    source("server/Employment.R", local = TRUE)
  }
  
  # ---- CFHI MODULE ----
  cfhi_feature_server(
    id = "cfhi",
    master_path = "data/cfhi/cfhi_master_2000_onward.csv"
  )
  
  # ---- CFHI DATA SOURCES TAB ----
  source("server/cfhi_data_server.R", local = TRUE)
})


