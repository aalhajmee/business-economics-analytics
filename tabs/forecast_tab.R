tabItem(
  tabName = "forecast",
  h2("CFHI Forecasting",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  p(style = "text-align:center; font-size:16px; max-width:800px; margin:0 auto;", 
    "See how CFHI might trend in the future. Choose a timeframe and scenario to explore different economic possibilities."),
  
  br(),
  
  fluidRow(
    column(
      width = 4,
      box(
        title = "Forecast Settings",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        h4("Time Period", style="margin-top:0; margin-bottom:10px;"),
        radioButtons(
          "forecast_months",
          NULL,
          choices = c("6 months" = 6, "1 year" = 12, "2 years" = 24),
          selected = 12,
          inline = FALSE
        ),
        
        hr(),
        
        h4("Quick Scenarios", style="margin-top:0; margin-bottom:10px;"),
        radioButtons(
          "scenario_preset",
          NULL,
          choices = c(
            "Current Trends" = "baseline",
            "Economic Growth" = "growth",
            "Economic Decline" = "decline",
            "High Inflation" = "inflation",
            "Custom..." = "custom"
          ),
          selected = "baseline",
          inline = FALSE
        ),
        
        conditionalPanel(
          condition = "input.scenario_preset == 'custom'",
          div(style="background:#fff3cd; padding:10px; border-radius:5px; margin-bottom:15px;",
            tags$small(tags$b("Custom Mode:"), " Adjust each factor below")
          ),
          
          sliderInput(
            "custom_savings",
            "Savings Rate Change:",
            min = -3,
            max = 3,
            value = 0,
            step = 0.5,
            post = "%"
          ),
          
          sliderInput(
            "custom_wage",
            "Wage Growth Change:",
            min = -3,
            max = 3,
            value = 0,
            step = 0.5,
            post = "%"
          ),
          
          sliderInput(
            "custom_inflation",
            "Inflation Change:",
            min = -3,
            max = 3,
            value = 0,
            step = 0.5,
            post = "%"
          ),
          
          sliderInput(
            "custom_borrow",
            "Interest Rate Change:",
            min = -2,
            max = 2,
            value = 0,
            step = 0.25,
            post = "%"
          )
        ),
        
        conditionalPanel(
          condition = "input.scenario_preset != 'custom'",
          div(style="background:#f8f9fa; padding:10px; border-radius:5px; font-size:12px;",
            tags$ul(style="margin:5px 0 0 0; padding-left:18px;",
              tags$li(tags$b("Current Trends:"), " No change"),
              tags$li(tags$b("Growth:"), " +2% wages, stable savings"),
              tags$li(tags$b("Decline:"), " -2% wages, higher costs"),
              tags$li(tags$b("Inflation:"), " -1.5% purchasing power")
            )
          )
        ),
        
        br(),
        
        actionButton(
          "apply_scenario",
          "Generate Forecast",
          class = "btn-primary btn-lg",
          icon = icon("chart-line"),
          style = "width:100%; font-weight:bold;"
        ),
        
        br(), br(),
        
        downloadButton(
          "download_forecast_data",
          "Download Forecast Data",
          class = "btn-success",
          icon = icon("download"),
          style = "width:100%;"
        )
      )
    ),
    
    column(
      width = 8,
      box(
        title = "Forecast Results",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        
        plotlyOutput("forecast_plot", height = "450px"),
        
        br(),
        
        div(style="background:#e3f2fd; padding:12px; border-radius:5px; border-left:4px solid #2196f3;",
          tags$p(style="margin:0; font-size:13px;",
            tags$b(icon("info-circle"), " Reading the chart:"),
            " The ", tags$b("blue line"), " shows historical data. The ",
            tags$b("orange dashed line"), " shows the forecast. ",
            tags$b("Shaded areas"), " represent confidence intervals: ",
            tags$b("80% band"), " (darker) means 80% probability the true value falls within this range; ",
            tags$b("95% band"), " (lighter) provides 95% confidence. Wider bands indicate greater uncertainty."
          )
        )
      )
    )
  ),
  
  # Model Diagnostics Section
  fluidRow(
    column(
      width = 12,
      box(
        title = "Model Validation & Diagnostics",
        width = 12,
        status = "warning",
        solidHeader = TRUE,
        collapsible = FALSE,
        
        h4("Model Comparison", style = "margin-top: 0;"),
        p("Comparing ARIMA and ETS models on training data. Lower values indicate better fit."),
        DTOutput("model_comparison_table"),
        
        br(),
        
        h4("Backtesting Results"),
        p("Out-of-sample validation using last 12 months as test set. This shows how well models predict unseen data."),
        DTOutput("backtest_accuracy_table"),
        
        br(),
        
        fluidRow(
          column(6, plotlyOutput("backtest_plot", height = "350px")),
          column(6, plotlyOutput("residual_diagnostics", height = "350px"))
        ),
        
        br(),
        
        fluidRow(
          column(6, plotOutput("arima_acf_plot", height = "300px")),
          column(6, plotOutput("arima_qq_plot", height = "300px"))
        ),
        
        br(),
        
        div(style="background:#fff3cd; padding:12px; border-radius:5px; border-left:4px solid #ffc107;",
          tags$p(style="margin:0; font-size:13px;",
            tags$b(icon("lightbulb"), " Interpretation Guide:"),
            tags$ul(
              style = "margin-bottom: 0;",
              tags$li(tags$b("AIC/BIC:"), " Lower is better. Penalizes model complexity."),
              tags$li(tags$b("RMSE:"), " Root Mean Square Error. Lower indicates better predictions."),
              tags$li(tags$b("MAE:"), " Mean Absolute Error. Average prediction error in CFHI points."),
              tags$li(tags$b("MAPE:"), " Mean Absolute Percentage Error. Average error as percentage."),
              tags$li(tags$b("ACF Plot:"), " Should show no significant autocorrelation in residuals (all bars within blue lines)."),
              tags$li(tags$b("Q-Q Plot:"), " Points should follow diagonal line for normally distributed residuals.")
            )
          )
        )
      )
    )
  )
)
