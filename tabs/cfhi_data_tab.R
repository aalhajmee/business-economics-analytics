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
        
        downloadButton("download_data", "Download CSV", class = "btn-primary"),
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
        collapsible = TRUE,
        collapsed = TRUE,
        
        tags$h4(style = "color:#1e40af; margin-top:0;", "Overview"),
        tags$p(
          "The Consumer Financial Health Index (CFHI) measures financial wellbeing by combining four key economic indicators. 
          There are two versions: National CFHI (for tracking U.S. economic trends) and Personal CFHI (for individual assessment)."
        ),
        
        tags$hr(style = "border-top: 2px solid #3b82f6;"),
        
        tags$h4(style = "color:#1e40af;", "Four Core Components"),
        tags$div(
          style = "background:#f0f9ff; padding:15px; border-left:4px solid #3b82f6; margin:10px 0;",
          tags$ul(
            tags$li(tags$strong("Savings Rate (S*):"), " Percentage of income saved after expenses"),
            tags$li(tags$strong("Wage Growth (W*):"), " Year-over-year change in income/earnings"),
            tags$li(tags$strong("Inflation Rate (I*):"), " Year-over-year cost of living increase ", tags$em("(inverted - lower is better)")),
            tags$li(tags$strong("Borrowing Rate (R*):"), " Interest rate on debt or lending rates ", tags$em("(inverted - lower is better)"))
          )
        ),
        
        tags$hr(),
        
        tags$h4(style = "color:#059669;", "National CFHI Calculation"),
        tags$p(tags$strong("Used in the main CFHI visualization to track U.S. economic trends over time.")),
        
        tags$p(tags$strong("Step 1: Normalize Components (0-100 scale)")),
        tags$div(
          style = "background:#f5f5f5; padding:10px; margin:10px 0; font-family:monospace;",
          "S* = 100 × (National Savings Rate - Historical Min) / (Historical Max - Historical Min)", tags$br(),
          "W* = 100 × (National Wage Growth - Historical Min) / (Historical Max - Historical Min)", tags$br(),
          "I* = 100 - [100 × (National Inflation - Historical Min) / (Historical Max - Historical Min)]", tags$br(),
          "R* = 100 - [100 × (Federal Funds Rate - Historical Min) / (Historical Max - Historical Min)]"
        ),
        
        tags$p(tags$strong("Step 2: Calculate Raw CFHI")),
        tags$div(
          style = "background:#f5f5f5; padding:10px; margin:10px 0; font-family:monospace; text-align:center; font-size:16px;",
          "CFHI (raw) = (S* + W* + I* + R*) / 4"
        ),
        
        tags$p(tags$strong("Step 3: Rebase to October 2006 = 100")),
        tags$div(
          style = "background:#fef3c7; padding:10px; margin:10px 0; font-family:monospace; text-align:center; font-size:16px; border:2px solid #f59e0b;",
          "CFHI (final) = (CFHI raw / Oct 2006 CFHI raw) × 100"
        ),
        tags$p(
          style = "font-size:14px; color:#666;",
          "Rebasing allows the index to exceed 100 if conditions improve beyond 2006 levels, 
          or fall below 100 if conditions worsen. October 2006 represents pre-financial crisis baseline."
        ),
        
        tags$hr(),
        
        tags$h4(style = "color:#7c3aed;", "Personal CFHI Calculation"),
        tags$p(tags$strong("Used in the CFHI tab's Personal Calculator to assess individual financial health.")),
        
        tags$p(tags$strong("Step 1: Calculate Your Personal Metrics")),
        tags$ul(
          tags$li(tags$strong("S:"), " (Monthly Savings ÷ Monthly Income) × 100"),
          tags$li(tags$strong("W:"), " Your reported year-over-year income growth %"),
          tags$li(tags$strong("I:"), " Current U.S. inflation rate (same for everyone)"),
          tags$li(tags$strong("R:"), " Your average debt interest rate (or 0% if no debt)")
        ),
        
        tags$p(tags$strong("Step 2: Normalize Using Historical Ranges")),
        tags$div(
          style = "background:#faf5ff; padding:10px; margin:10px 0; border-left:4px solid #7c3aed;",
          tags$p(
            "Each personal metric is normalized using the ", tags$strong("same historical min/max ranges"), 
            " from the national data (Oct 2006-present). This ensures your score is comparable to national trends."
          ),
          tags$div(
            style = "font-family:monospace; font-size:14px;",
            "S* = 100 × (Your Savings % - 2.1) / (33.8 - 2.1)", tags$br(),
            "W* = 100 × (Your Wage Growth - (-4.8)) / (7.9 - (-4.8))", tags$br(),
            "I* = 100 - [100 × (Current Inflation - (-2.1)) / (9.1 - (-2.1))]", tags$br(),
            "R* = 100 - [100 × (Your Debt Rate - 0) / (25 - 0)]"
          )
        ),
        
        tags$p(tags$strong("Step 3: Average and Cap at 100")),
        tags$div(
          style = "background:#faf5ff; padding:10px; margin:10px 0; font-family:monospace; text-align:center; font-size:16px; border:2px solid #7c3aed;",
          "Personal CFHI = min(100, (S* + W* + I* + R*) / 4)"
        ),
        tags$p(
          style = "font-size:14px; color:#666;",
          tags$strong("Note:"), " Personal CFHI is ", tags$em("NOT"), " rebased. It's capped at 100 to provide 
          a clear 0-100 scale where 100 = optimal financial health based on historical benchmarks."
        ),
        
        tags$hr(),
        
        tags$h4(style = "color:#1e40af;", "Key Differences"),
        tags$div(
          style = "background:#fff7ed; padding:15px; border-left:4px solid #f97316; margin:10px 0;",
          tags$table(
            style = "width:100%; border-collapse:collapse;",
            tags$thead(
              tags$tr(
                tags$th(style = "text-align:left; padding:8px; border-bottom:2px solid #ddd;", "Aspect"),
                tags$th(style = "text-align:left; padding:8px; border-bottom:2px solid #ddd;", "National CFHI"),
                tags$th(style = "text-align:left; padding:8px; border-bottom:2px solid #ddd;", "Personal CFHI")
              )
            ),
            tags$tbody(
              tags$tr(
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", tags$strong("Data Source")),
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", "BEA, BLS, FRED"),
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", "User inputs + current inflation")
              ),
              tags$tr(
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", tags$strong("Rebasing")),
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", "Yes (Oct 2006 = 100)"),
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", "No (capped at 100)")
              ),
              tags$tr(
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", tags$strong("Score Range")),
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", "0 to unlimited (can exceed 100)"),
                tags$td(style = "padding:8px; border-bottom:1px solid #ddd;", "0 to 100")
              ),
              tags$tr(
                tags$td(style = "padding:8px;", tags$strong("Purpose")),
                tags$td(style = "padding:8px;", "Track economic trends over time"),
                tags$td(style = "padding:8px;", "Assess individual financial health")
              )
            )
          )
        ),
        
        tags$hr(),
        
        tags$h4(style = "color:#1e40af;", "Data Sources"),
        tags$ul(
          tags$li(tags$strong("Savings Rate:"), " U.S. Bureau of Economic Analysis (BEA) Table 2.1"),
          tags$li(tags$strong("Wage Growth:"), " U.S. Bureau of Labor Statistics (BLS) Average Hourly Earnings"),
          tags$li(tags$strong("Inflation:"), " U.S. Bureau of Labor Statistics (BLS) CPI-U"),
          tags$li(tags$strong("Borrowing Rate:"), " Federal Reserve Economic Data (FRED) Federal Funds Rate")
        ),
        
        tags$p(
          style = "font-size:12px; color:#666; font-style:italic; margin-top:15px;",
          "Data updated monthly. Historical values may be recalculated as government agencies revise estimates."
        )
      )
    )
  )
)
