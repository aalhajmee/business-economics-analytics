tabItem(
  tabName = "market_correlation",
  h2("S&P 500 & CFHI Correlation Analysis",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  
  fluidRow(
    column(12,
      box(
        title = "Research Methodology",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        tags$div(style = "font-size:15px;",
          tags$p(tags$b("Research Question:"), 
            " Does S&P 500 performance affect household financial health after controlling for Federal Reserve policy?"),
          
          tags$p(tags$b("Statistical Method:"), 
            " Multiple Linear Regression: ", 
            tags$code("CFHI ~ S&P500 + Fed Funds Rate")),
          
          tags$p(tags$b("Hypothesis Test:")),
          tags$ul(
            tags$li(tags$b("H₀:"), " β = 0 (S&P 500 has no effect on CFHI)"),
            tags$li(tags$b("Hₐ:"), " β ≠ 0 (S&P 500 significantly affects CFHI)"),
            tags$li(tags$b("Significance level:"), " α = 0.05")
          ),
          
          tags$p(style = "color:#555;",
            "This analysis controls for confounding monetary policy effects to isolate the true relationship between stock market performance and household financial well-being.")
        )
      )
    )
  ),
  
  fluidRow(
    box(
      title = "Analysis Settings",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      
      fluidRow(
        column(3,
          selectInput(
            "market_date_range",
            "Chart Date Range:",
            choices = c(
              "Full Period (2006-2025)" = "full",
              "Last 10 Years" = "10yr",
              "Last 5 Years" = "5yr",
              "Last 3 Years" = "3yr",
              "Custom Range" = "custom"
            ),
            selected = "full"
          )
        ),
        column(3,
          conditionalPanel(
            condition = "input.market_date_range == 'custom'",
            dateInput(
              "market_start_date",
              "Start Date:",
              value = "2006-04-01",
              min = "2006-04-01",
              max = Sys.Date()
            )
          )
        ),
        column(3,
          conditionalPanel(
            condition = "input.market_date_range == 'custom'",
            dateInput(
              "market_end_date",
              "End Date:",
              value = Sys.Date(),
              min = "2006-04-01",
              max = Sys.Date()
            )
          )
        )
      ),
      
      tags$div(
        style = "background:#fff3cd; padding:12px; border-radius:5px; border-left:4px solid #ffc107; margin-top:15px;",
        tags$p(style="margin:0; font-size:13px;",
          tags$b(icon("info-circle"), " Note:"),
          " Statistical calculations use the full dataset (April 2006 - August 2025). ",
          "The date range above only filters the chart visualization for closer examination of specific time periods."
        )
      )
    )
  ),
  
  # Statistics Cards Row
  fluidRow(
    valueBoxOutput("correlation_coef", width = 3),
    valueBoxOutput("r_squared", width = 3),
    valueBoxOutput("p_value", width = 3),
    valueBoxOutput("data_points", width = 3)
  ),
  
  # Dual-Axis Time Series
  fluidRow(
    box(
      title = "Time Series Comparison (Actual Values, Dual Axis)",
      status = "info",
      solidHeader = TRUE,
      width = 12,
      
      plotlyOutput("dual_axis_plot", height = "500px"),
      
      tags$div(
        style = "margin-top: 12px; padding: 12px; background: #e3f2fd; border-left: 4px solid #2196f3; border-radius: 4px;",
        tags$p(style = "margin: 0; font-size: 13px; color: #0c4a6e;",
          tags$b(icon("chart-line"), " Chart Explanation:"), 
          " This dual-axis chart displays ", tags$b("actual values"), " (not indexed) to reveal the true magnitude differences. ",
          tags$b("Blue line (left axis):"), " S&P 500 ranges from ~800 to ~6,000. ",
          tags$b("Red line (right axis):"), " CFHI ranges from ~0 to ~300. ",
          "Watch how during bull markets (blue climbing), CFHI often declines (red falling) due to Federal Reserve rate hikes. ",
          "Key periods to observe: ",
          tags$b("2008-09 crisis"), " (inverse V-patterns), ",
          tags$b("2017-19"), " (S&P up, CFHI down), ",
          tags$b("2020 COVID"), " (Fed cuts → CFHI spike), ",
          tags$b("2022-24"), " (aggressive rate hikes → CFHI plunge)."
        )
      )
    )
  ),
  
  # Statistical Interpretation
  fluidRow(
    box(
      title = "Statistical Analysis Results",
      status = "success",
      solidHeader = TRUE,
      width = 12,
      
      htmlOutput("correlation_insights"),
      
      tags$div(
        style = "margin-top: 15px; padding: 12px; background: #f0fdf4; border-left: 4px solid #16a34a; border-radius: 4px;",
        tags$p(style = "margin: 0 0 10px 0; font-size: 14px; color: #15803d;",
          tags$b(icon("lightbulb"), " What Does \"Controlling For\" Mean?")),
        
        tags$p(style = "margin: 0; font-size: 13px; color: #166534; line-height: 1.6;",
          "Both S&P 500 and CFHI respond to Federal Reserve policy. ",
          "When the Fed raises rates, stocks often fall ", tags$em("and"), " CFHI falls (due to higher borrowing costs). ",
          "Multiple regression removes the Fed's effect, revealing the ", tags$b("true independent relationship"), 
          " between markets and household finances.")
      )
    )
  )
)
