tabItem(
  tabName = "market_data",
  
  fluidRow(
    column(12,
      h2(style = "font-weight: 600; color: #1e293b; margin-bottom: 20px;", 
         "Market Data Sources"),
      p(style = "color: #64748b; font-size: 15px; margin-bottom: 30px;",
        "Detailed information about the financial market data used in correlation analysis.")
    )
  ),
  
  # S&P 500 Data
  fluidRow(
    box(
      title = "S&P 500 Index Data",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      
      tags$div(
        style = "padding: 15px; line-height: 1.8;",
        
        tags$h4(style = "color: #1e293b; margin-bottom: 15px;", "Data Source"),
        tags$p(
          style = "color: #475569; font-size: 15px;",
          "The S&P 500 price history data is sourced from ",
          tags$strong("FactSet Research Systems"), 
          ". For reproducible research, equivalent data is publicly available from Yahoo Finance and other free providers."
        ),
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Coverage Period"),
        tags$ul(
          style = "color: #475569; font-size: 15px;",
          tags$li(tags$strong("Date Range:"), " April 2006 to August 2025"),
          tags$li(tags$strong("Frequency:"), " Monthly observations (end-of-month prices)"),
          tags$li(tags$strong("Total Data Points:"), " 233 months of market data")
        ),
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Data Fields"),
        tags$ul(
          style = "color: #475569; font-size: 15px;",
          tags$li(tags$strong("Price:"), " Closing price of the S&P 500 index at month-end"),
          tags$li(tags$strong("% Change:"), " Month-over-month percentage change"),
          tags$li(tags$strong("Volume:"), " Average cumulative trading volume"),
          tags$li(tags$strong("Total Return:"), " Gross total return including dividends (unhedged)"),
          tags$li(tags$strong("Open/High/Low:"), " Monthly opening, highest, and lowest index values")
        ),
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "About the S&P 500"),
        tags$p(
          style = "color: #475569; font-size: 15px;",
          "The Standard & Poor's 500 Index is a market-capitalization-weighted index of 500 of the largest publicly traded companies in the U.S. ",
          "It is widely regarded as the best single gauge of large-cap U.S. equities and serves as a proxy for the overall health of the U.S. stock market and economy."
        ),
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Correlation with CFHI"),
        tags$p(
          style = "color: #475569; font-size: 15px;",
          "Multiple regression analysis controlling for Federal Reserve policy reveals:"
        ),
        tags$div(
          style = "background:#fef9e7; padding:15px; border-left:4px solid #f39c12; margin:15px 0;",
          tags$ul(
            style = "color: #475569; font-size: 15px; margin:0;",
            tags$li(tags$strong("Statistical Significance:"), " Relationship is statistically significant (p < 0.01)"),
            tags$li(tags$strong("Practical Effect Size:"), " 1,000-point S&P 500 increase corresponds to ~0.7 CFHI increase"),
            tags$li(tags$strong("Percentage Impact:"), " Less than 1% of total CFHI range (17.9-93.34)"),
            tags$li(tags$strong("Interpretation:"), " Stock market explains minimal variance in household financial health")
          )
        ),
        tags$p(
          style = "color: #475569; font-size: 15px;",
          "The weak correlation reflects wealth concentration: the wealthiest 10% own approximately 90% of stocks, ",
          "meaning market gains primarily benefit high-net-worth households. Federal Reserve interest rate policy ",
          "demonstrates approximately 5× stronger impact on CFHI than equity market movements."
        )
      )
    )
  ),
  
  # Data Overlap Section
  fluidRow(
    box(
      title = "CFHI and S&P 500 Data Overlap",
      status = "info",
      solidHeader = TRUE,
      width = 6,
      
      tags$div(
        style = "padding: 15px;",
        tags$h4(style = "color: #1e293b; margin-bottom: 15px;", "Merged Dataset"),
        tags$ul(
          style = "color: #475569; font-size: 15px; line-height: 1.8;",
          tags$li(tags$strong("CFHI Period:"), " January 2000 - December 2025"),
          tags$li(tags$strong("S&P 500 Period:"), " April 2006 - August 2025"),
          tags$li(tags$strong("Overlap Period:"), " April 2006 - August 2025"),
          tags$li(tags$strong("Usable Observations:"), " 233 months")
        ),
        tags$p(
          style = "color: #64748b; font-size: 14px; margin-top: 20px;",
          "The correlation analysis uses the overlapping period where both CFHI and S&P 500 data are available, ",
          "ensuring valid comparisons and statistical reliability."
        )
      )
    )
  )
)
