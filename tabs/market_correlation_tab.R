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
      collapsible = TRUE,
      
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
        ),
        column(3,
          selectInput(
            "correlation_method",
            "Correlation Method:",
            choices = c("Pearson" = "pearson", "Spearman" = "spearman"),
            selected = "pearson"
          )
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
      status = "warning",
      solidHeader = TRUE,
      width = 6,
      plotlyOutput("rolling_correlation_plot", height = "400px")
    )
  ),
  
  # Insights and Model Summary
  fluidRow(
    box(
      title = "Regression Model Summary",
      status = "primary",
      solidHeader = TRUE,
      width = 6,
      verbatimTextOutput("regression_summary")
    ),
    box(
      title = "Key Insights",
      status = "info",
      solidHeader = TRUE,
      width = 6,
      htmlOutput("correlation_insights")
    )
  )
)
