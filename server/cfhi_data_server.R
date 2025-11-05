# ---- CFHI DATA SOURCES TAB SERVER LOGIC ----
# This file contains the server logic for the CFHI Data tab
# Handles data loading, table rendering, and downloads for different CFHI data sources

# Load data based on selection
selected_data <- reactive({
  req(input$data_source_select)
  data_path <- switch(input$data_source_select,
                      "master" = "data/cfhi/cfhi_master_2000_onward.csv",
                      "savings" = "data/cfhi/series_raw/savings_rate.csv",
                      "wage" = "data/cfhi/series_raw/wage_yoy.csv",
                      "inflation" = "data/cfhi/series_raw/inflation_yoy.csv",
                      "borrow" = "data/cfhi/series_raw/borrow_rate.csv"
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

# Render data table (correct output name to match UI)
output$data_table <- DT::renderDT({
  df <- selected_data()
  DT::datatable(
    df,
    options = list(
      pageLength = 25,
      scrollX = TRUE,
      searchHighlight = TRUE
    ),
    rownames = FALSE,
    class = 'cell-border stripe hover'
  )
})

# Data description based on selection
output$data_description <- renderUI({
  source <- input$data_source_select
  
  description <- switch(source,
    "master" = tagList(
      tags$h4("Master Dataset", style = "color:#2c3e50;"),
      tags$p("Complete historical dataset containing all CFHI components from October 2006 to present."),
      tags$ul(
        tags$li(tags$strong("Date:"), " Monthly observations"),
        tags$li(tags$strong("Savings Rate:"), " Personal saving as percentage of disposable income (BEA)"),
        tags$li(tags$strong("Wage Growth:"), " Year-over-year change in average hourly earnings (BLS)"),
        tags$li(tags$strong("Inflation:"), " Year-over-year CPI-U change (BLS)"),
        tags$li(tags$strong("Borrow Rate:"), " Federal Funds Effective Rate (FRED)"),
        tags$li(tags$strong("Normalized Components:"), " S*, W*, I*, R* (0-100 scale)"),
        tags$li(tags$strong("CFHI:"), " Consumer Financial Health Index (rebased to Oct 2006 = 100)")
      ),
      tags$div(
        style = "background:#e0f2fe; border-left:4px solid #0284c7; padding:12px; margin-top:15px;",
        tags$p(
          style = "margin:0; font-size:13px;",
          tags$strong(style = "color:#0369a1;", "📋 DATA DISTRIBUTION NOTICE:"), 
          " This dataset is derived from publicly available U.S. government sources (BEA, BLS, FRED). ",
          tags$strong("All source data is in the public domain and freely distributable."), 
          " Our calculated CFHI components and normalized values may be shared for educational and research purposes with appropriate attribution to original government sources."
        )
      )
    ),
    "savings" = tagList(
      tags$h4("Personal Savings Rate", style = "color:#2e7d32;"),
      tags$p("Personal saving as a percentage of disposable personal income."),
      tags$ul(
        tags$li(tags$strong("Source:"), " U.S. Bureau of Economic Analysis (BEA) Table 2.1"),
        tags$li(tags$strong("Frequency:"), " Monthly"),
        tags$li(tags$strong("Formula:"), " (Personal Saving ÷ Disposable Personal Income) × 100"),
        tags$li(tags$strong("Interpretation:"), " Higher values indicate greater financial resilience")
      ),
      tags$div(
        style = "background:#f0fdf4; border-left:4px solid #16a34a; padding:12px; margin-top:15px;",
        tags$p(
          style = "margin:0; font-size:13px;",
          tags$strong(style = "color:#15803d;", "📋 DATA DISTRIBUTION NOTICE:"), 
          " This data is sourced from the U.S. Bureau of Economic Analysis (BEA), a federal agency. ",
          tags$strong("BEA data is in the public domain and freely distributable without restrictions."), 
          " You may share, modify, and use this data for any purpose."
        )
      )
    ),
    "wage" = tagList(
      tags$h4("Average Hourly Earnings Growth", style = "color:#2e7d32;"),
      tags$p("Year-over-year percentage change in average hourly earnings for all private employees."),
      tags$ul(
        tags$li(tags$strong("Source:"), " U.S. Bureau of Labor Statistics (BLS) Current Employment Statistics"),
        tags$li(tags$strong("Frequency:"), " Monthly"),
        tags$li(tags$strong("Formula:"), " ((Current Wage - Wage 12 Months Ago) ÷ Wage 12 Months Ago) × 100"),
        tags$li(tags$strong("Interpretation:"), " Higher growth indicates improved earning capacity")
      ),
      tags$div(
        style = "background:#fef3c7; border-left:4px solid #f59e0b; padding:12px; margin-top:15px;",
        tags$p(
          style = "margin:0; font-size:13px;",
          tags$strong(style = "color:#d97706;", "📋 DATA DISTRIBUTION NOTICE:"), 
          " This data is sourced from the U.S. Bureau of Labor Statistics (BLS) Current Employment Statistics program. ",
          tags$strong("All BLS data is in the public domain and freely distributable."), 
          " As a U.S. government agency, BLS data has no copyright restrictions. You may share and use this data freely."
        )
      )
    ),
    "inflation" = tagList(
      tags$h4("Consumer Price Inflation (CPI-U)", style = "color:#2e7d32;"),
      tags$p("Year-over-year percentage change in the Consumer Price Index for All Urban Consumers."),
      tags$ul(
        tags$li(tags$strong("Source:"), " U.S. Bureau of Labor Statistics (BLS) Consumer Price Index"),
        tags$li(tags$strong("Frequency:"), " Monthly"),
        tags$li(tags$strong("Formula:"), " ((Current CPI - CPI 12 Months Ago) ÷ CPI 12 Months Ago) × 100"),
        tags$li(tags$strong("Interpretation:"), " Lower inflation is generally better for financial health, but the normalization treats this as a component where stability matters")
      ),
      tags$div(
        style = "background:#fef2f2; border-left:4px solid #ef4444; padding:12px; margin-top:15px;",
        tags$p(
          style = "margin:0; font-size:13px;",
          tags$strong(style = "color:#dc2626;", "📋 DATA DISTRIBUTION NOTICE:"), 
          " This data is sourced from the U.S. Bureau of Labor Statistics (BLS) Consumer Price Index program. ",
          tags$strong("CPI data is in the public domain and freely available for any use."), 
          " BLS, as a federal agency, does not copyright its data. You may freely share, redistribute, and use this data for commercial or non-commercial purposes."
        )
      )
    ),
    "borrow" = tagList(
      tags$h4("Borrowing Rate", style = "color:#7b1fa2;"),
      tags$p("Federal Funds Effective Rate - the overnight lending rate between banks."),
      tags$ul(
        tags$li(tags$strong("Source:"), " Federal Reserve Economic Data (FRED)"),
        tags$li(tags$strong("Frequency:"), " Monthly average"),
        tags$li(tags$strong("Impact:"), " Influences all consumer borrowing costs (mortgages, credit cards, auto loans)"),
        tags$li(tags$strong("Interpretation:"), " Lower rates make borrowing cheaper for consumers"),
        tags$li(tags$strong("Note:"), " Inverted in CFHI calculation (high rates = lower score)")
      ),
      tags$div(
        style = "background:#faf5ff; border-left:4px solid #a855f7; padding:12px; margin-top:15px;",
        tags$p(
          style = "margin:0; font-size:13px;",
          tags$strong(style = "color:#9333ea;", "📋 DATA DISTRIBUTION NOTICE:"), 
          " This data is sourced from the Federal Reserve Bank of St. Louis via Federal Reserve Economic Data (FRED). ",
          tags$strong("FRED data is provided by the Federal Reserve System and is in the public domain."), 
          " As a U.S. government source, this data may be freely used, shared, and redistributed without restrictions."
        )
      )
    ),
    tagList(tags$p("Select a data source to view details."))
  )
  
  description
})

# Download handler (correct output name to match UI)
output$download_data <- downloadHandler(
  filename = function() {
    source_name <- input$data_source_select
    paste0("cfhi_", source_name, "_", Sys.Date(), ".csv")
  },
  content = function(file) {
    write_csv(selected_data(), file)
  }
)
