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
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Relevance to CFHI"),
        tags$p(
          style = "color: #475569; font-size: 15px;",
          "The S&P 500 is relevant to household financial health for several reasons:"
        ),
        tags$ul(
          style = "color: #475569; font-size: 15px;",
          tags$li(tags$strong("Retirement Accounts:"), " Many 401(k)s, IRAs, and pension funds are invested in S&P 500 index funds"),
          tags$li(tags$strong("Wealth Effect:"), " Rising stock prices increase household net worth and consumer confidence"),
          tags$li(tags$strong("Economic Indicator:"), " Stock market performance often reflects and predicts broader economic conditions"),
          tags$li(tags$strong("Employment:"), " Corporate performance impacts job security, wages, and benefits")
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
