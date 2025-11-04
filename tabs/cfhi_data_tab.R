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
          "The Consumer Financial Health Index (CFHI) combines four economic indicators to measure financial wellbeing. 
          Score ranges from 0-100 (personal) or rebased to Oct 2006 = 100 (national)."
        ),
        
        tags$h4(style = "color:#1e40af;", "Four Components"),
        tags$ul(
          tags$li(tags$strong("Savings Rate (S*):"), " Percentage of income saved, normalized 0-100"),
          tags$li(tags$strong("Wage Growth (W*):"), " Year-over-year income change, normalized 0-100"),
          tags$li(tags$strong("Inflation (I*):"), " CPI year-over-year, inverted (lower is better), normalized 0-100"),
          tags$li(tags$strong("Borrowing Rate (R*):"), " Average interest rate on debt, inverted (lower is better), normalized 0-100")
        ),
        
        tags$h4(style = "color:#1e40af;", "Calculation Process"),
        tags$p(
          tags$strong("1. Normalize:"), " Each component scaled 0-100 using min-max normalization based on historical data (Oct 2006-present):",
          tags$br(),
          tags$code("Component* = 100 × (Value - Historical Min) / (Historical Max - Historical Min)"),
          tags$br(),
          "Inverted metrics subtract from 100 (I* and R*)"
        ),
        tags$p(
          tags$strong("2. Average:"), " CFHI = (S* + W* + I* + R*) / 4"
        ),
        tags$p(
          tags$strong("3. Rebase (National only):"), " National CFHI is rebased to October 2006 = 100 for trend tracking. Personal CFHI capped at 100."
        ),
        
        tags$h4(style = "color:#1e40af;", "Data Sources (National Index)"),
        tags$ul(
          tags$li(tags$strong("Savings Rate:"), " BEA Table 2.1 Personal Saving Rate"),
          tags$li(tags$strong("Wage Growth:"), " BLS Average Hourly Earnings YoY change"),
          tags$li(tags$strong("Inflation:"), " BLS CPI-U YoY change"),
          tags$li(tags$strong("Borrowing Rate:"), " Federal Reserve FRED Federal Funds Rate")
        ),
        
        tags$p(
          style = "font-size:13px; color:#666; font-style:italic;",
          "Data updated monthly. Historical values recalculated as government agencies revise estimates."
        )
      )
    )
  )
)
