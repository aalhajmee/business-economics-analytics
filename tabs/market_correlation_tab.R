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
          tags$b(icon("info-circle"), " Methodology:"),
          " This analysis employs ", tags$b("Pearson correlation"), " to quantify the linear association between CFHI and S&P 500 values. ",
          "Pearson correlation is appropriate for continuous variables when assessing linear relationships. ",
          "The correlation coefficient (r) ranges from -1 to +1, where |r| > 0.7 indicates strong correlation, ",
          "0.3 < |r| < 0.7 indicates moderate correlation, and |r| < 0.3 indicates weak correlation. ",
          "Positive values indicate variables move in the same direction; negative values indicate inverse movement. ",
          "Statistical significance is tested at α = 0.05 level (p < 0.05 rejects the null hypothesis of no correlation)."
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
  
  # Data Verification Box - Shows stability of normalization
  fluidRow(
    box(
      title = "Data Verification (Fixed Baseline Normalization)",
      status = "success",
      solidHeader = TRUE,
      width = 12,
      collapsible = FALSE,
      
      tags$div(
        style = "background:#f0fdf4; padding:12px; border-radius:5px; border-left:4px solid #22c55e;",
        tags$p(style="margin:0 0 8px 0; font-size:13px;",
          tags$b(icon("check-circle"), " Fixed Baseline Guarantee:"),
          " All CFHI and S&P 500 values are indexed to ", tags$b("October 2006 = 100"), 
          " using the full dataset (April 2006 - August 2025) for normalization. ",
          tags$b("These values remain constant regardless of the date range you select."),
          " This ensures mathematically valid correlation analysis across all time periods."
        ),
        htmlOutput("data_verification_display")
      )
    )
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
      plotlyOutput("scatter_regression_plot", height = "400px"),
      
      tags$div(
        style = "background:#f0fdf4; padding:10px; border-radius:5px; border-left:4px solid #16a34a; margin-top:10px;",
        tags$p(style="margin:0; font-size:12px;",
          tags$b(icon("chart-line"), " Regression Scatter Plot:"),
          " Each point represents monthly observations. Points clustered along the fitted regression line indicate a strong linear relationship. ",
          "Greater scatter suggests weaker predictive power. The slope indicates the direction and magnitude of the relationship."
        )
      )
    ),
    box(
      title = "Rolling 12-Month Correlation",
      status = "info",
      solidHeader = TRUE,
      width = 6,
      plotlyOutput("rolling_correlation_plot", height = "400px"),
      
      tags$div(
        style = "background:#eff6ff; padding:10px; border-radius:5px; border-left:4px solid #3b82f6; margin-top:10px;",
        tags$p(style="margin:0; font-size:12px;",
          tags$b(icon("calendar"), " Rolling Correlation:"),
          " Displays 12-month windowed correlation coefficients to examine temporal stability of the relationship. ",
          "Values consistently above |0.5| indicate persistent strong correlation. Fluctuations suggest the relationship varies across different economic periods."
        )
      )
    )
  ),
  
  # Insights and Model Summary
  fluidRow(
    box(
      title = "Statistical Details",
      status = "warning",
      solidHeader = TRUE,
      width = 6,
      
      tags$div(
        style = "background:#fff7ed; padding:10px; border-radius:5px; border-left:4px solid #f59e0b; margin-bottom:10px;",
        tags$p(style="margin:0; font-size:12px;",
          tags$b(icon("calculator"), " Regression Output:"),
          " Linear regression model summary with key diagnostics: ",
          tags$b("R²"), " (proportion of variance explained), ",
          tags$b("coefficients"), " (estimated effect size and direction), ",
          tags$b("p-values"), " (significance at α = 0.05 threshold), and ",
          tags$b("residual standard error"), " (model fit quality)."
        )
      ),
      
      verbatimTextOutput("regression_summary")
    ),
    box(
      title = "Statistical Interpretation",
      status = "success",
      solidHeader = TRUE,
      width = 6,
      
      tags$div(
        style = "background:#f0fdf4; padding:10px; border-radius:5px; border-left:4px solid #16a34a; margin-bottom:10px;",
        tags$p(style="margin:0; font-size:12px;",
          tags$b(icon("lightbulb"), " Analysis Summary:"),
          " This section synthesizes statistical findings into contextual interpretations, assessing the practical significance of the correlation, ",
          "hypothesis test results, and potential economic mechanisms underlying observed relationships."
        )
      ),
      
      htmlOutput("correlation_insights")
    )
  )
)
