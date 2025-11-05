tabItem(
  tabName = "market_correlation",
  
  fluidRow(
    column(12,
      h2(style = "font-weight: 600; color: #1e293b; margin-bottom: 20px;", 
         "S&P 500 & CFHI Correlation Analysis"),
      p(style = "color: #64748b; font-size: 15px; margin-bottom: 25px;",
        "Explore the relationship between the S&P 500 market index and the Composite Financial Health Index (CFHI). ",
        "This analysis helps understand how stock market performance correlates with household financial well-being.")
    )
  ),
  
  # Controls Row
  fluidRow(
    box(
      title = "Analysis Settings",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      collapsible = FALSE,
      
      fluidRow(
        column(3,
          selectInput(
            "market_date_range",
            "Date Range:",
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
        style = "background:#e3f2fd; padding:12px; border-radius:5px; border-left:4px solid #2196f3; margin-top:15px;",
        tags$p(style="margin:0; font-size:13px;",
          tags$b(icon("info-circle"), " Correlation Method:"),
          " This analysis uses ", tags$b("Pearson correlation"), " to measure the linear relationship between CFHI and S&P 500 returns. ",
          "Pearson is appropriate here because both variables are continuous numeric measurements and we're testing if they move together in a straight-line pattern. ",
          "The correlation coefficient (r) ranges from -1 to +1: values near +1 indicate strong positive correlation (both increase together), ",
          "values near -1 indicate strong negative correlation (one increases while the other decreases), and values near 0 suggest no linear relationship. ",
          "The p-value tests if this correlation is statistically significant (p < 0.05 indicates the relationship is unlikely due to chance)."
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
      title = "Time Series Comparison",
      status = "info",
      solidHeader = TRUE,
      width = 12,
      plotlyOutput("dual_axis_plot", height = "450px")
    )
  ),
  
  # Scatter Plot and Rolling Correlation
  fluidRow(
    box(
      title = "Regression Analysis",
      status = "success",
      solidHeader = TRUE,
      width = 6,
      plotlyOutput("scatter_regression_plot", height = "400px")
    ),
    box(
      title = "Rolling 12-Month Correlation",
      status = "info",
      solidHeader = TRUE,
      width = 6,
      plotlyOutput("rolling_correlation_plot", height = "400px")
    )
  ),
  
  # Insights and Model Summary
  fluidRow(
    box(
      title = "Regression Model Summary",
      status = "success",
      solidHeader = TRUE,
      width = 6,
      verbatimTextOutput("regression_summary")
    ),
    box(
      title = "Key Insights",
      status = "success",
      solidHeader = TRUE,
      width = 6,
      htmlOutput("correlation_insights")
    )
  )
)
