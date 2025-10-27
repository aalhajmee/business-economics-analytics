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
source("R_Scripts/cfhi_feature_server.R")

shinyServer(function(input, output, session) {
  
  # ---- FORECAST SERVER LOGIC ----
  source("forecast_server.R", local = TRUE)
  
  # ---- STATE ANALYSIS SERVER LOGIC ----
  source("state_analysis_server.R", local = TRUE)
  
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
        tags$h4("Master Dataset - Complete CFHI Data"),
        tags$p(
          "This comprehensive dataset combines all four key economic indicators that form the basis of the Consumer Financial Health Index (CFHI). 
          It provides a complete picture of the economic factors affecting American consumers' financial well-being from 2006 to present."
        ),
        tags$h5("Data Columns:"),
        tags$ul(
          tags$li(
            tags$strong("Date:"), " Monthly observations starting from October 2006 (the baseline month for index rebasing). 
            Each row represents economic conditions for that specific month."
          ),
          tags$li(
            tags$strong("Savings Rate:"), " Personal saving rate as a percentage of disposable income (Source: Bureau of Economic Analysis). 
            This measures what percentage of Americans' after-tax income is being saved rather than spent. 
            Historical range: approximately 2-20%. Higher values indicate stronger household balance sheets and better ability to weather financial shocks."
          ),
          tags$li(
            tags$strong("Wage YoY (Year-over-Year):"), " Percentage change in average hourly earnings compared to the same month one year ago (Source: Bureau of Labor Statistics). 
            This tracks whether workers' incomes are growing. Positive values mean wage increases; negative values indicate wage stagnation or decline. 
            Historical range: approximately -5% to +8%. This is crucial for understanding if Americans can afford rising costs."
          ),
          tags$li(
            tags$strong("Inflation YoY (Year-over-Year):"), " Percentage change in the Consumer Price Index for All Urban Consumers (CPI-U) compared to the same month one year ago (Source: Bureau of Labor Statistics). 
            This measures how fast prices are rising for a typical basket of consumer goods and services (food, housing, transportation, healthcare, etc.). 
            Historical range: approximately 0-9%. Higher inflation erodes purchasing power and makes it harder for families to make ends meet."
          ),
          tags$li(
            tags$strong("Borrow Rate:"), " Federal Funds Effective Rate - the interest rate at which banks lend to each other overnight (Source: Federal Reserve Economic Data). 
            This rate influences all other interest rates in the economy, including credit cards, mortgages, auto loans, and savings accounts. 
            Historical range: approximately 0-6%. Higher rates make borrowing more expensive and can strain household budgets for those carrying debt."
          )
        ),
        tags$h5("Why These Four Indicators?"),
        tags$p(
          "These four metrics were chosen because they represent the key dimensions of consumer financial health:"
        ),
        tags$ul(
          tags$li(tags$strong("Savings Rate:"), " Measures financial resilience and ability to build wealth"),
          tags$li(tags$strong("Wage Growth:"), " Indicates income trajectory and earning power"),
          tags$li(tags$strong("Inflation:"), " Affects purchasing power and cost of living"),
          tags$li(tags$strong("Borrowing Costs:"), " Impacts debt burden and financial flexibility")
        ),
        tags$p(
          style = "color:#6c757d; font-size:13px; margin-top:15px;",
          tags$em(
            "Note: The CFHI normalizes each of these indicators to a 0-100 scale using their historical min/max values, 
            then averages them together. Inflation and borrowing rates are inverted (lower = better) since high values hurt consumers."
          )
        )
      ),
      "savings" = tags$div(
        tags$h4("Personal Saving Rate Dataset"),
        tags$p(tags$strong("Source:"), " U.S. Bureau of Economic Analysis (BEA) - Table 2.1, Personal Income and Its Disposition"),
        tags$h5("What This Measures:"),
        tags$p(
          "The personal saving rate represents the percentage of disposable personal income (after-tax income) that Americans save rather than spend on consumption. 
          It's calculated as: (Personal Savings ÷ Disposable Personal Income) × 100."
        ),
        tags$h5("Why It Matters:"),
        tags$ul(
          tags$li(
            tags$strong("Emergency Preparedness:"), " Higher savings rates mean families have cushions to handle unexpected expenses like medical bills, car repairs, or job loss."
          ),
          tags$li(
            tags$strong("Financial Security:"), " Consistent saving builds wealth over time through investments, retirement accounts, and home equity."
          ),
          tags$li(
            tags$strong("Economic Health:"), " When people save more, they feel secure enough to reduce spending, which can signal economic anxiety. 
            Conversely, very low savings rates can indicate financial stress or overconfidence."
          )
        ),
        tags$h5("Historical Context:"),
        tags$p(
          "From 2006-2025, U.S. savings rates have ranged from about 2% (pre-financial crisis) to nearly 34% (during COVID-19 pandemic peak in April 2020). 
          The long-term average hovers around 7-8%. The dramatic spike during COVID-19 reflected government stimulus payments and reduced spending opportunities."
        ),
        tags$p(tags$strong("Frequency:"), " Monthly updates, typically released about 4 weeks after the end of each month"),
        tags$p(
          tags$strong("Impact on CFHI:"), " Higher savings rates directly improve the CFHI score. This component is normalized to 0-100 scale where 100 represents the highest historical savings rate."
        ),
        tags$p(
          style = "color:#6c757d; font-size:13px; margin-top:10px;",
          tags$em("Data URL: https://www.bea.gov/data/income-saving/personal-saving-rate")
        )
      ),
      "wage" = tags$div(
        tags$h4("Wage Growth Dataset (Year-over-Year)"),
        tags$p(tags$strong("Source:"), " U.S. Bureau of Labor Statistics (BLS) - Current Employment Statistics (CES) Survey"),
        tags$h5("What This Measures:"),
        tags$p(
          "This dataset tracks the percentage change in average hourly earnings for all private sector employees compared to the same month one year earlier. 
          It answers the question: 'Are workers' paychecks growing, staying flat, or shrinking?'"
        ),
        tags$h5("Why It Matters:"),
        tags$ul(
          tags$li(
            tags$strong("Real Income Growth:"), " When wages grow faster than inflation, workers can afford more goods and services - their 'real' purchasing power increases."
          ),
          tags$li(
            tags$strong("Economic Mobility:"), " Consistent wage growth enables families to improve their standard of living, pay down debt, and invest in their future."
          ),
          tags$li(
            tags$strong("Keeping Up with Costs:"), " If wage growth lags behind inflation, workers fall behind even if their nominal paycheck increases."
          )
        ),
        tags$h5("Historical Context:"),
        tags$p(
          "From 2006-2025, year-over-year wage growth has ranged from about -5% (during the 2008 financial crisis) to +8% (post-pandemic labor shortages in 2021-2022). 
          The 'healthy' range is typically 3-4% annual growth - enough to outpace moderate inflation. Negative growth is rare and signals severe economic distress."
        ),
        tags$p(tags$strong("Calculation Method:"), " YoY % Change = ((Current Month Wage - Same Month Last Year) ÷ Same Month Last Year) × 100"),
        tags$p(tags$strong("Frequency:"), " Monthly updates, typically released on the first Friday of each month"),
        tags$p(
          tags$strong("Impact on CFHI:"), " Higher wage growth improves the CFHI score. This component is normalized to 0-100 scale where 100 represents the highest historical wage growth rate."
        ),
        tags$p(
          style = "color:#6c757d; font-size:13px; margin-top:10px;",
          tags$em("Data URL: https://www.bls.gov/ces/ - Average Hourly Earnings of All Employees")
        )
      ),
      "inflation" = tags$div(
        tags$h4("Inflation Rate Dataset (Year-over-Year CPI)"),
        tags$p(tags$strong("Source:"), " U.S. Bureau of Labor Statistics (BLS) - Consumer Price Index for All Urban Consumers (CPI-U)"),
        tags$h5("What This Measures:"),
        tags$p(
          "The inflation rate tracks how fast prices are rising for a 'basket' of goods and services that typical American households purchase. 
          This basket includes: food and beverages (15%), housing (42%), apparel (3%), transportation (17%), medical care (9%), recreation (6%), education (3%), and other goods/services (5%)."
        ),
        tags$h5("Why It Matters:"),
        tags$ul(
          tags$li(
            tags$strong("Purchasing Power:"), " Higher inflation means your dollar buys less. A 5% inflation rate means something that cost $100 last year now costs $105."
          ),
          tags$li(
            tags$strong("Budget Pressure:"), " When inflation rises faster than wages, families must cut back on spending, dip into savings, or take on debt to maintain their lifestyle."
          ),
          tags$li(
            tags$strong("Planning Difficulty:"), " High or volatile inflation makes it harder to plan for major purchases, retirement, or other long-term financial goals."
          ),
          tags$li(
            tags$strong("Wealth Erosion:"), " Cash savings lose value over time during inflationary periods - $10,000 saved during 5% annual inflation is worth only $9,500 in purchasing power one year later."
          )
        ),
        tags$h5("Historical Context:"),
        tags$p(
          "From 2006-2025, U.S. inflation has ranged from about -2% (deflation during the 2009 recession) to +9% (peak in June 2022 due to supply chain disruptions and stimulus spending). 
          The Federal Reserve targets 2% annual inflation as 'healthy' - low enough to preserve purchasing power but high enough to encourage economic activity. 
          The 2021-2023 period saw the highest sustained inflation in 40 years, significantly impacting household budgets."
        ),
        tags$p(tags$strong("Calculation Method:"), " YoY % Change = ((Current Month CPI - Same Month Last Year) ÷ Same Month Last Year) × 100"),
        tags$p(tags$strong("Frequency:"), " Monthly updates, typically released around the 10th-15th of each month"),
        tags$p(
          tags$strong("Impact on CFHI:"), " This indicator is INVERTED in the CFHI calculation - higher inflation LOWERS the score. 
          It's normalized so that 0% inflation = 100 points, and the highest historical inflation = 0 points. This reflects the fact that inflation hurts consumers."
        ),
        tags$p(
          style = "color:#6c757d; font-size:13px; margin-top:10px;",
          tags$em("Data URL: https://www.bls.gov/cpi/ - Consumer Price Index Summary")
        )
      ),
      "borrow" = tags$div(
        tags$h4("Borrowing Rate Dataset (Federal Funds Rate)"),
        tags$p(tags$strong("Source:"), " Federal Reserve Economic Data (FRED) - Federal Funds Effective Rate"),
        tags$h5("What This Measures:"),
        tags$p(
          "The Federal Funds Rate is the interest rate at which depository institutions (banks and credit unions) lend reserve balances to each other overnight. 
          While consumers don't borrow at this rate directly, it serves as the foundation for all other interest rates in the economy."
        ),
        tags$h5("Why It Matters:"),
        tags$ul(
          tags$li(
            tags$strong("Borrowing Costs:"), " When the Fed raises this rate, banks pass those costs on to consumers through higher interest rates on credit cards (typically Fed rate + 10-15%), 
            mortgages, auto loans, student loans, and personal loans."
          ),
          tags$li(
            tags$strong("Debt Burden:"), " For Americans carrying credit card debt (average balance ~$6,000), a 1% increase in rates adds about $60/year in interest charges. 
            For a $300,000 mortgage, it can mean $3,000+ more per year."
          ),
          tags$li(
            tags$strong("Savings Returns:"), " Higher rates also mean better returns on savings accounts and CDs, but most consumers are net borrowers, so the negative impact dominates."
          ),
          tags$li(
            tags$strong("Economic Control:"), " The Federal Reserve adjusts this rate to control inflation (raise rates to cool economy) or stimulate growth (lower rates to encourage borrowing and spending)."
          )
        ),
        tags$h5("Historical Context:"),
        tags$p(
          "From 2006-2025, the Federal Funds Rate has ranged from near 0% (2008-2015 and 2020-2021 during crises) to 5.5% (2006-2007 before financial crisis and 2023-2024 fighting inflation). 
          The dramatic cuts to near-zero during the 2008 financial crisis and COVID-19 pandemic were emergency measures to prevent economic collapse. 
          The rapid increases in 2022-2023 (fastest in 40 years) were designed to combat the highest inflation since the 1980s."
        ),
        tags$p(tags$strong("How Consumers Are Affected:"), ""),
        tags$ul(
          tags$li("Credit card APRs: typically Federal Funds Rate + 12-17%"),
          tags$li("Mortgage rates: typically Federal Funds Rate + 2-4% (depending on loan type and credit score)"),
          tags$li("Auto loan rates: typically Federal Funds Rate + 3-7%"),
          tags$li("Savings account rates: typically Federal Funds Rate - 1% to +0.5%")
        ),
        tags$p(tags$strong("Frequency:"), " Updated daily, averaged monthly for this dataset. The Federal Reserve's Open Market Committee (FOMC) meets 8 times per year to set target rate ranges."),
        tags$p(
          tags$strong("Impact on CFHI:"), " This indicator is INVERTED in the CFHI calculation - higher borrowing rates LOWER the score. 
          It's normalized so that 0% rate = 100 points, and the highest historical rate = 0 points. This reflects the fact that high borrowing costs hurt consumers, especially those with debt."
        ),
        tags$p(
          style = "color:#6c757d; font-size:13px; margin-top:10px;",
          tags$em("Data URL: https://fred.stlouisfed.org/series/FEDFUNDS")
        )
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
