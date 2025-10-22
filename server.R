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

# CFHI module (reads cfhi_data/cfhi_master_2000_onward.csv)
source("R_Scripts/cfhi_feature_server.R")

shinyServer(function(input, output, session) {
  observeEvent(input$go_to_tab, {
    updateTabItems(session, "tabs", input$go_to_tab)
  })
  
  updateTabItems(session, "tabs", "home")
  # ---- CFHI MODULE ----
  cfhi_feature_server(
    id = "cfhi",
    master_path = "cfhi_data/cfhi_master_2000_onward.csv"
  )
  
  # ---- CFHI DATA SOURCES TAB ----
  # Load data based on selection
  selected_data <- reactive({
    req(input$data_source_select)
    
    data_path <- switch(input$data_source_select,
      "master" = "cfhi_data/cfhi_master_2000_onward.csv",
      "savings" = "cfhi_data/series_raw/savings_rate.csv",
      "wage" = "cfhi_data/series_raw/wage_yoy.csv",
      "inflation" = "cfhi_data/series_raw/inflation_yoy.csv",
      "borrow" = "cfhi_data/series_raw/borrow_rate.csv"
    )
    
    if (file.exists(data_path)) {
      df <- read_csv(data_path, show_col_types = FALSE)
      # Convert date column if it exists
      if ("date" %in% tolower(names(df))) {
        date_col <- names(df)[tolower(names(df)) == "date"]
        df[[date_col]] <- as.Date(df[[date_col]])
      }
      return(df)
    } else {
      return(data.frame(Error = paste("File not found:", data_path)))
    }
  })
  
  # Render data table
  output$data_table <- DT::renderDataTable({
    DT::datatable(
      selected_data(),
      options = list(
        pageLength = 25,
        scrollX = TRUE,
        order = list(list(0, 'desc'))  # Sort by first column descending (newest first)
      ),
      rownames = FALSE
    )
  })
  
  # Data descriptions
  output$data_description <- renderUI({
    desc <- switch(input$data_source_select,
      "master" = tags$div(
        tags$h4("Master Dataset"),
        tags$p("This file contains all economic indicators combined in one place:"),
        tags$ul(
          tags$li(tags$strong("Date:"), " Monthly observations from 2006 onwards"),
          tags$li(tags$strong("Savings Rate:"), " Personal saving rate as % of disposable income (BEA)"),
          tags$li(tags$strong("Wage YoY:"), " Year-over-year change in average hourly earnings (BLS)"),
          tags$li(tags$strong("Inflation YoY:"), " Year-over-year change in Consumer Price Index (BLS)"),
          tags$li(tags$strong("Borrow Rate:"), " Federal Funds Effective Rate (FRED)")
        )
      ),
      "savings" = tags$div(
        tags$h4("Personal Saving Rate"),
        tags$p(tags$strong("Source:"), " U.S. Bureau of Economic Analysis (BEA)"),
        tags$p(tags$strong("Description:"), " Personal saving as a percentage of disposable personal income."),
        tags$p(tags$strong("Frequency:"), " Monthly"),
        tags$p(tags$strong("Impact:"), " Higher savings rates indicate better financial health.")
      ),
      "wage" = tags$div(
        tags$h4("Wage Growth (Year-over-Year)"),
        tags$p(tags$strong("Source:"), " U.S. Bureau of Labor Statistics (BLS)"),
        tags$p(tags$strong("Description:"), " Percentage change in average hourly earnings compared to the same month last year."),
        tags$p(tags$strong("Frequency:"), " Monthly"),
        tags$p(tags$strong("Impact:"), " Positive wage growth improves purchasing power and financial health.")
      ),
      "inflation" = tags$div(
        tags$h4("Inflation Rate (Year-over-Year)"),
        tags$p(tags$strong("Source:"), " U.S. Bureau of Labor Statistics (BLS)"),
        tags$p(tags$strong("Description:"), " Percentage change in Consumer Price Index (CPI-U) compared to the same month last year."),
        tags$p(tags$strong("Frequency:"), " Monthly"),
        tags$p(tags$strong("Impact:"), " Higher inflation erodes purchasing power and reduces financial health.")
      ),
      "borrow" = tags$div(
        tags$h4("Borrowing Rate (Federal Funds Rate)"),
        tags$p(tags$strong("Source:"), " Federal Reserve Economic Data (FRED)"),
        tags$p(tags$strong("Description:"), " The federal funds effective rate - the interest rate at which depository institutions lend to each other overnight."),
        tags$p(tags$strong("Frequency:"), " Monthly average"),
        tags$p(tags$strong("Impact:"), " Higher rates increase borrowing costs and reduce financial flexibility.")
      )
    )
    
    return(desc)
  })
  
  # Download handler
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("cfhi_", input$data_source_select, "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(selected_data(), file, row.names = FALSE)
    }
  )
  
  # ---- OPTIONAL: Savings Guide or other outputs ----
  # If you keep additional server logic in a separate file, source it here
  # so it has access to input/output/session.
  if (file.exists("calculations.R")) {
    source("calculations.R", local = TRUE)
  }
  
})
