tabItem(
  tabName = "forecast",
  h2("CFHI Forecasting"),
  p("Predict future Consumer Financial Health Index trends using historical data and scenario analysis."),
  br(),
  
  fluidRow(
    column(
      width = 3,
      box(
        title = "Forecast Settings",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        sliderInput(
          "forecast_months",
          "Forecast Horizon (months):",
          min = 3,
          max = 24,
          value = 12,
          step = 3
        ),
        
        selectInput(
          "forecast_method",
          "Forecasting Method:",
          choices = c(
            "ARIMA (Auto)" = "arima",
            "Exponential Smoothing" = "ets",
            "Both (Ensemble)" = "ensemble"
          ),
          selected = "arima"
        ),
        
        hr(),
        
        h4("Scenario Analysis"),
        p(style = "font-size:12px; color:#666;", 
          "Adjust projected economic conditions to see impact on future CFHI."),
        
        sliderInput(
          "scenario_savings",
          "Avg Savings Rate Adjustment (%):",
          min = -5,
          max = 5,
          value = 0,
          step = 0.5
        ),
        
        sliderInput(
          "scenario_wage",
          "Avg Wage Growth Adjustment (%):",
          min = -3,
          max = 3,
          value = 0,
          step = 0.5
        ),
        
        sliderInput(
          "scenario_inflation",
          "Avg Inflation Adjustment (%):",
          min = -2,
          max = 2,
          value = 0,
          step = 0.5
        ),
        
        sliderInput(
          "scenario_borrow",
          "Avg Borrow Rate Adjustment (%):",
          min = -1,
          max = 1,
          value = 0,
          step = 0.25
        ),
        
        actionButton(
          "apply_scenario",
          "Apply Scenario",
          class = "btn-warning",
          style = "width:100%;"
        )
      )
    ),
    
    column(
      width = 9,
      box(
        title = "CFHI Forecast",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        
        plotlyOutput("forecast_plot", height = "500px")
      ),
      
      box(
        title = "Forecast Statistics",
        width = 12,
        status = "warning",
        
        fluidRow(
          column(4, uiOutput("forecast_stat_current")),
          column(4, uiOutput("forecast_stat_predicted")),
          column(4, uiOutput("forecast_stat_change"))
        )
      ),
      
      box(
        title = "Model Performance",
        width = 12,
        status = "success",
        collapsible = TRUE,
        collapsed = TRUE,
        
        verbatimTextOutput("forecast_metrics")
      )
    )
  )
)
