tabItem(
  tabName = "forecast",
  h2("CFHI Forecasting",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  p(style = "text-align:center; font-size:16px;", 
    "Predict future CFHI trends based on historical patterns and economic scenarios."),
  
  fluidRow(
    column(12,
      box(
        title = "How to Use This Tool",
        width = 12,
        status = "info",
        solidHeader = FALSE,
        collapsible = TRUE,
        collapsed = TRUE,
        
        tags$ol(
          tags$li(tags$b("Choose how far ahead to predict:"), " Use the slider to select 3-24 months into the future."),
          tags$li(tags$b("Select forecasting method:"), " ARIMA uses statistical patterns, Exponential Smoothing uses weighted averages."),
          tags$li(tags$b("Run 'what-if' scenarios:"), " Adjust the sliders to see how changes in savings, wages, inflation, or interest rates might affect the future."),
          tags$li(tags$b("Click 'Apply Scenario':"), " The chart updates to show your custom prediction.")
        )
      )
    )
  ),
  
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
          "Forecast Period:",
          min = 3,
          max = 24,
          value = 12,
          step = 3,
          post = " months"
        ),
        
        selectInput(
          "forecast_method",
          "Method:",
          choices = c(
            "ARIMA" = "arima",
            "Exponential Smoothing" = "ets",
            "Ensemble" = "ensemble"
          ),
          selected = "ensemble"
        ),
        
        hr(),
        
        h4("Economic Scenarios"),
        p(style = "font-size:12px; color:#666;", 
          "Simulate economic changes (leave at 0 for baseline forecast):"),
        
        sliderInput(
          "scenario_savings",
          "Savings Rate:",
          min = -5,
          max = 5,
          value = 0,
          step = 0.5,
          post = "%"
        ),
        
        sliderInput(
          "scenario_wage",
          "Wage Growth:",
          min = -3,
          max = 3,
          value = 0,
          step = 0.5,
          post = "%"
        ),
        
        sliderInput(
          "scenario_inflation",
          "Inflation:",
          min = -2,
          max = 2,
          value = 0,
          step = 0.5,
          post = "%"
        ),
        
        sliderInput(
          "scenario_borrow",
          "Interest Rates:",
          min = -1,
          max = 1,
          value = 0,
          step = 0.25,
          post = "%"
        ),
        
        br(),
        
        actionButton(
          "apply_scenario",
          "Generate Forecast",
          class = "btn-primary",
          icon = icon("chart-line"),
          style = "width:100%; font-weight:bold; font-size:16px;"
        ),
        
        br(), br(),
        
        actionButton(
          "reset_scenario",
          "Reset to Baseline",
          class = "btn-default",
          icon = icon("undo"),
          style = "width:100%;"
        )
      )
    ),
    
    column(
      width = 9,
      box(
        title = "Forecast Results",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        
        p(style = "font-size:14px; color:#555;",
          tags$b("Blue:"), " Historical | ",
          tags$b("Orange dashed line:"), " Predicted future values | ",
          tags$b("Shaded areas:"), " Confidence ranges (darker = 80% confident, lighter = 95% confident)"),
        
        plotlyOutput("forecast_plot", height = "500px")
      ),
      
      box(
        title = "Forecast Summary",
        width = 12,
        status = "success",
        
        fluidRow(
          column(4, 
            div(style = "text-align:center; padding:15px;",
              uiOutput("forecast_stat_current")
            )
          ),
          column(4,
            div(style = "text-align:center; padding:15px;",
              uiOutput("forecast_stat_predicted")
            )
          ),
          column(4,
            div(style = "text-align:center; padding:15px;",
              uiOutput("forecast_stat_change")
            )
          )
        )
      ),
      
      box(
        title = "Technical Details (Optional)",
        width = 12,
        status = "warning",
        collapsible = TRUE,
        collapsed = TRUE,
        
        p(tags$b("What do these methods mean?")),
        tags$ul(
          tags$li(tags$b("ARIMA:"), " Finds patterns in how the index changes over time (trends, seasonality)"),
          tags$li(tags$b("Exponential Smoothing:"), " Gives more weight to recent data when predicting"),
          tags$li(tags$b("Ensemble:"), " Combines both methods for a balanced prediction")
        ),
        
        hr(),
        
        p(tags$b("Model Statistics:")),
        verbatimTextOutput("forecast_metrics")
      )
    )
  )
)
