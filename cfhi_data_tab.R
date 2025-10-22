tabItem(
  tabName = "cfhi_data",
  h2("CFHI Data Sources"),
  p("View the raw data used to calculate the Consumer Financial Health Index."),
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
        
        # Download button
        downloadButton("download_data", "Download CSV", class = "btn-primary"),
        
        br(), br(),
        
        # Data table output
        DT::dataTableOutput("data_table")
      )
    )
  ),
  
  br(),
  
  fluidRow(
    column(
      width = 12,
      box(
        title = "Data Description",
        width = 12,
        status = "info",
        
        uiOutput("data_description")
      )
    )
  ),
  
  br(),
  
  # Personal CFHI Calculation Explanation
  fluidRow(
    column(
      width = 12,
      box(
        title = "How Your Personal CFHI is Calculated",
        width = 12,
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        tags$h4("Formula Overview"),
        tags$p(
          "Your Personal Consumer Financial Health Index (CFHI) is calculated using the same methodology as the U.S. national index, 
          but with your personal financial data. The index ranges from 0 to 100, where:"
        ),
        tags$ul(
          tags$li(tags$strong("0-30:"), " Poor financial health"),
          tags$li(tags$strong("30-50:"), " Below average financial health"),
          tags$li(tags$strong("50-70:"), " Average financial health"),
          tags$li(tags$strong("70-85:"), " Good financial health"),
          tags$li(tags$strong("85-100:"), " Excellent financial health")
        ),
        
        hr(),
        
        tags$h4("Step-by-Step Calculation"),
        
        tags$div(
          style = "background:#f8f9fa; border-left:4px solid #ffc107; padding:15px; margin:10px 0;",
          tags$h5("Step 1: Calculate Your Personal Metrics"),
          tags$ul(
            tags$li(tags$strong("Savings Rate (S):"), " (Monthly Savings ÷ Monthly Income) × 100"),
            tags$li(tags$strong("Wage Growth (W):"), " Income Growth vs Last Year (%)"),
            tags$li(tags$strong("Inflation Impact (I):"), " Uses current U.S. inflation rate (same for everyone)"),
            tags$li(tags$strong("Borrowing Cost (R):"), " Your average interest rate on debt (0 if no debt)")
          )
        ),
        
        tags$div(
          style = "background:#f8f9fa; border-left:4px solid #ffc107; padding:15px; margin:10px 0;",
          tags$h5("Step 2: Normalize Each Component (0-100 scale)"),
          tags$p("Each metric is normalized using historical U.S. data (2006-present) to put it on a 0-100 scale:"),
          tags$div(
            style = "font-family:monospace; background:#ffffff; padding:10px; border:1px solid #dee2e6; margin:10px 0;",
            tags$strong("S* = 100 × (Your Savings Rate - Min) ÷ (Max - Min)"), tags$br(),
            tags$strong("W* = 100 × (Your Wage Growth - Min) ÷ (Max - Min)"), tags$br(),
            tags$strong("I* = 100 - 100 × (Current Inflation - Min) ÷ (Max - Min)"), " ", 
            tags$span(style="color:#dc3545;", "[inverted: lower inflation = higher score]"), tags$br(),
            tags$strong("R* = 100 - 100 × (Your Borrow Rate - Min) ÷ (Max - Min)"), " ",
            tags$span(style="color:#dc3545;", "[inverted: lower rate = higher score]")
          ),
          tags$p(
            style = "color:#6c757d; font-size:13px; margin-top:10px;",
            tags$em("Why normalize? This allows us to compare your metrics fairly against historical U.S. ranges. 
            For example, if you save 15% and the historical range is 2-20%, your normalized score would be about 72.")
          )
        ),
        
        tags$div(
          style = "background:#f8f9fa; border-left:4px solid #ffc107; padding:15px; margin:10px 0;",
          tags$h5("Step 3: Calculate Your Personal CFHI"),
          tags$div(
            style = "font-family:monospace; background:#ffffff; padding:15px; border:2px solid #ffc107; margin:10px 0; text-align:center; font-size:16px;",
            tags$strong("Personal CFHI = (S* + W* + I* + R*) ÷ 4")
          ),
          tags$p("This is a simple average of the four normalized components, giving equal weight to each factor.")
        ),
        
        tags$div(
          style = "background:#f8f9fa; border-left:4px solid #ffc107; padding:15px; margin:10px 0;",
          tags$h5("Step 4: Compare to U.S. Average"),
          tags$p("Your index is compared to the 2025 U.S. average CFHI to show how you're doing relative to the nation."),
          tags$ul(
            tags$li("If your CFHI is ", tags$strong("higher"), " than the U.S. average → You're doing better than average"),
            tags$li("If your CFHI is ", tags$strong("similar"), " (±2 points) → You're about average"),
            tags$li("If your CFHI is ", tags$strong("lower"), " than the U.S. average → You have room for improvement")
          )
        ),
        
        hr(),
        
        tags$h4("Example Calculation"),
        tags$div(
          style = "background:#e7f3ff; border:1px solid #0066cc; padding:15px; margin:10px 0;",
          tags$p(tags$strong("Your Inputs:")),
          tags$ul(
            tags$li("Monthly Income: $5,000"),
            tags$li("Monthly Savings: $750"),
            tags$li("Income Growth: +3%"),
            tags$li("Total Debt: $0 (no debt)")
          ),
          
          tags$p(tags$strong("Step 1: Calculate Metrics")),
          tags$ul(
            tags$li("Savings Rate: ($750 ÷ $5,000) × 100 = ", tags$strong("15%")),
            tags$li("Wage Growth: ", tags$strong("3%")),
            tags$li("Current Inflation: ", tags$strong("3.2%"), " (2025 average)"),
            tags$li("Borrow Rate: ", tags$strong("0%"), " (no debt)")
          ),
          
          tags$p(tags$strong("Step 2: Normalize (using historical ranges)")),
          tags$ul(
            tags$li("S*: If historical range is 2-20%, then (15-2)/(20-2) × 100 = ", tags$strong("72")),
            tags$li("W*: If historical range is -5% to +8%, then (3-(-5))/(8-(-5)) × 100 = ", tags$strong("62")),
            tags$li("I*: If historical range is 0-9%, then 100 - (3.2-0)/(9-0) × 100 = ", tags$strong("64"), " (inverted)"),
            tags$li("R*: If you have no debt, rate is 0, and range is 0-6%, then 100 - (0-0)/(6-0) × 100 = ", tags$strong("100"))
          ),
          
          tags$p(tags$strong("Step 3: Calculate CFHI")),
          tags$div(
            style = "font-family:monospace; background:#ffffff; padding:10px; margin:10px 0;",
            "Personal CFHI = (72 + 62 + 64 + 100) ÷ 4 = ", tags$strong(style="color:#28a745; font-size:18px;", "74.5")
          ),
          
          tags$p(tags$strong("Result:"), " A score of 74.5 indicates ", tags$strong(style="color:#28a745;", "Good financial health!"))
        ),
        
        hr(),
        
        tags$h4("Why These Four Components?"),
        tags$div(
          style = "background:#fff3cd; padding:15px; margin:10px 0; border-radius:5px;",
          tags$p(tags$strong("Savings Rate"), " - Measures your ability to build wealth and handle emergencies"),
          tags$p(tags$strong("Wage Growth"), " - Indicates whether your income is keeping pace with your career and economy"),
          tags$p(tags$strong("Inflation"), " - Affects your purchasing power (inverted because high inflation hurts everyone)"),
          tags$p(tags$strong("Borrowing Cost"), " - Reflects your debt burden (inverted because high rates mean more financial strain)")
        ),
        
        tags$p(
          style = "color:#6c757d; font-size:12px; font-style:italic; margin-top:15px;",
          "Note: This index is designed to provide a snapshot of your financial health. It should be used as a guide, 
          not as financial advice. For personalized financial planning, consult with a certified financial advisor."
        )
      )
    )
  )
)
