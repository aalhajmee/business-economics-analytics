library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(zoo)
library(lubridate)
library(shinydashboard)
library(plotly)
library(shinyjs)
library(DT)
library(forecast)

# CFHI module (reads cfhi_data/cfhi_master_2000_onward.csv)
source("modules/cfhi_feature_server.R")

shinyServer(function(input, output, session) {
  observeEvent(input$go_to_tab, {
    updateTabItems(session, "tabs", input$go_to_tab)
  })
  # ---- FORECAST SERVER LOGIC ----
  source("server/forecast_server.R", local = TRUE)
  # ---- STATE ANALYSIS SERVER LOGIC ----
  source("server/state_analysis_server.R", local = TRUE)
  # ---- CALCULATOR LOGIC ----
  # Source the calculation and loan approval logic
  # These define outputs that need to be in the server scope,
  # so they have access to input/output/session.
  if (file.exists("server/calculations.R")) {
    source("server/calculations.R", local = TRUE)
  }
  if (file.exists("server/Loan_Approval_Calculator.R")) {
    source("server/Loan_Approval_Calculator.R", local = TRUE)
  }
  
  # ---- LOAN CALCULATOR TAB ----
  # Source the loans.R file to get the loan_server function
  if (file.exists("tabs/loans.R")) {
    source("tabs/loans.R", local = TRUE)
    # Call the loan server function
    loan_server(input, output, session)
  }
  
  # ---- STATE DATA SOURCES TAB ----
  # Render state economic data table
  output$state_data_table <- DT::renderDT({
    df <- read_csv("Financial_Calculator_datasets/State_Data_Demographics.csv", show_col_types = FALSE)
    # Filter out DC and Puerto Rico
    df <- df %>% filter(!State %in% c("District of Columbia", "Puerto Rico"))
    # Format the data for display
    df_display <- df %>%
      mutate(
        Median_Income = paste0("$", format(round(Median_Income), big.mark = ",")),
        Unemployment_Rate = paste0(round(Unemployment_Rate, 1), "%"),
        Poverty_Rate = paste0(round(Poverty_Rate, 1), "%"),
        Cost_of_Living_Index = round(Cost_of_Living_Index, 1)
      ) %>%
      select(
        State,
        `State Code` = State_Code,
        `Median Income` = Median_Income,
        `Unemployment Rate` = Unemployment_Rate,
        `Poverty Rate` = Poverty_Rate,
        `Cost of Living Index` = Cost_of_Living_Index
      )
    DT::datatable(
      df_display,
      options = list(
        pageLength = 25,
        scrollX = TRUE,
        searchHighlight = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'excel', 'pdf')
      ),
      rownames = FALSE,
      class = 'cell-border stripe hover',
      filter = 'top'
    )
  })
  # Download handler for state data
  output$download_state_data <- downloadHandler(
    filename = function() {
      paste0("state_economic_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      df <- read_csv("Financial_Calculator_datasets/State_Data_Demographics.csv", show_col_types = FALSE)
      # Filter out DC and Puerto Rico
      df <- df %>% filter(!State %in% c("District of Columbia", "Puerto Rico"))
      write_csv(df, file)
    }
  )
  # ---- CFHI MODULE ----
  cfhi_feature_server(
    id = "cfhi",
    master_path = "cfhi_data/cfhi_master_2000_onward.csv"
  )
  
  # ---- CFHI DATA SOURCES TAB ----
  source("server/cfhi_data_server.R", local = TRUE)
})


