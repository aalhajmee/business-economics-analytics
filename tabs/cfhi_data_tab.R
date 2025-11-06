tabItem(
  tabName = "cfhi_data",
  h2("CFHI Data Sources",
     style = "text-align:center; font-family:'Trebuchet MS',sans-serif; font-weight:600; font-size:32px;"),
  br(),
  
  fluidRow(
    column(
      width = 12,
      box(
        title = "Select Data Source",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        selectInput(
          "data_source_select",
          "Choose a data file:",
          choices = c(
            "Master Dataset (All Data)" = "master",
            "Savings Rate" = "savings",
            "Wage Growth (YoY)" = "wage",
            "Inflation Rate (YoY)" = "inflation",
            "Borrowing Rate" = "borrow"
          ),
          selected = "master"
        ),
        
        hr(),
        
        downloadButton("download_data", "Download CSV", class = "btn-success"),
        br(), br(),
        DT::dataTableOutput("data_table")
      )
    )
  ),
  
  br(),
  
  fluidRow(
    column(
      width = 12,
      box(
        title = "Data Sources",
        width = 12,
        status = "info",
        uiOutput("data_description")
      )
    )
  ),
  
  br(),
  
  fluidRow(
    column(
      width = 12,
      box(
        title = "CFHI Calculation Methodology",
        width = 12,
        status = "warning",
        solidHeader = TRUE,
        collapsible = FALSE,
        
        tags$h4(style = "color:#1e40af; margin-top:0;", "Overview"),
        tags$p(
          "The Composite Financial Health Index (CFHI) measures household financial wellbeing by combining four key economic indicators. 
          The index uses historical U.S. economic data to track financial health trends from 2000 to present."
        ),
        
        tags$hr(style = "border-top: 2px solid #3b82f6;"),
        
        tags$h4(style = "color:#1e40af;", "Four Core Components"),
        tags$div(
          style = "background:#f0f9ff; padding:15px; border-left:4px solid #3b82f6; margin:10px 0;",
          tags$ul(
            tags$li(tags$strong("Personal Savings Rate (S*):"), " Percentage of disposable income saved (BEA)"),
            tags$li(tags$strong("Average Hourly Earnings Growth (W*):"), " Year-over-year wage growth percentage (BLS)"),
            tags$li(tags$strong("Consumer Price Index (I*):"), " Year-over-year inflation rate ", tags$em("(inverted - lower is better)")),
            tags$li(tags$strong("Federal Funds Rate (R*):"), " Effective federal funds rate ", tags$em("(inverted - lower is better)"))
          )
        ),
        
        tags$hr(),
        
        tags$h4(style = "color:#059669;", "CFHI Calculation Methodology"),
        tags$p(tags$strong("Historical data from January 2000 to August 2025 (233 monthly observations)")),
        
        tags$p(tags$strong("Step 1: Component Normalization (Min-Max Scaling to 0-100)")),
        tags$div(
          style = "background:#f5f5f5; padding:10px; margin:10px 0; font-family:monospace;",
          "S* = 100 × (Savings Rate - Min) / (Max - Min)", tags$br(),
          "W* = 100 × (Wage Growth - Min) / (Max - Min)", tags$br(),
          "I* = 100 - [100 × (Inflation - Min) / (Max - Min)]  // Inverted", tags$br(),
          "R* = 100 - [100 × (Fed Rate - Min) / (Max - Min)]   // Inverted"
        ),
        
        tags$p(tags$strong("Step 2: Simple Average (Equal Weighting)")),
        tags$div(
          style = "background:#f5f5f5; padding:10px; margin:10px 0; font-family:monospace; text-align:center; font-size:16px;",
          "CFHI = (S* + W* + I* + R*) / 4"
        ),
        tags$p(
          style = "font-size:14px; color:#666; margin-top:10px;",
          tags$strong("Result:"), " CFHI naturally ranges from 0 (all components at historical worst) to 100 (all components at historical best). ",
          "Observed range: 17.90 (May 2007 pre-crisis trough) to 93.34 (April 2020 pandemic savings peak)."
        ),
        
        tags$hr(),
        
        tags$hr(),
        
        tags$h4(style = "color:#1e40af;", "Data Sources & Coverage"),
        tags$ul(
          tags$li(tags$strong("Personal Savings Rate:"), " Bureau of Economic Analysis (BEA)"),
          tags$li(tags$strong("Average Hourly Earnings (Wage Growth):"), " Bureau of Labor Statistics (BLS)"),
          tags$li(tags$strong("Consumer Price Index (Inflation):"), " Bureau of Labor Statistics (BLS)"),
          tags$li(tags$strong("Federal Funds Rate:"), " Federal Reserve Economic Data (FRED)")
        ),
        
        tags$div(
          style = "background:#f0f9ff; padding:12px; border-left:4px solid #3b82f6; margin:15px 0;",
          tags$p(
            style = "margin:0; font-size:14px;",
            tags$strong("Time Period:"), " January 2000 to August 2025 (233 monthly observations)", tags$br(),
            tags$strong("Update Frequency:"), " Monthly", tags$br(),
            tags$strong("Normalization:"), " All components scaled using full historical min/max across entire dataset"
          )
        ),
        
        tags$h4(style = "color:#1e40af; margin-top:20px;", "Interpretation"),
        tags$ul(
          tags$li(tags$strong("CFHI = 0-25:"), " Severe financial stress (similar to 2007 pre-crisis conditions)"),
          tags$li(tags$strong("CFHI = 25-50:"), " Below-average financial health (moderate stress)"),
          tags$li(tags$strong("CFHI = 50-75:"), " Above-average financial health (improving conditions)"),
          tags$li(tags$strong("CFHI = 75-100:"), " Excellent financial health (near-optimal conditions)")
        ),
        
        tags$p(
          style = "font-size:12px; color:#666; font-style:italic; margin-top:15px;",
          "Note: Historical values may be revised as government agencies update estimates. ",
          "Equal weighting (25% per component) reflects assumption of comparable importance across financial health dimensions."
        )
      )
    )
  )
)
