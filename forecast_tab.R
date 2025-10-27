tabItem(
  tabName = "forecast",
  h2("CFHI Future Predictions"),
  p("Use historical data to predict future trends in Consumer Financial Health. Adjust economic scenarios to see potential impacts."),
  
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
          "How many months ahead to predict:",
          min = 3,
          max = 24,
          value = 12,
          step = 3
        ),
        
        selectInput(
          "forecast_method",
          "Prediction Method:",
          choices = c(
            "ARIMA (Statistical Patterns)" = "arima",
            "Exponential Smoothing (Weighted Average)" = "ets",
            "Both Combined (Ensemble)" = "ensemble"
          ),
          selected = "arima"
        ),
        
        hr(),
        
        h4("What-If Scenario Analysis"),
        p(style = "font-size:12px; color:#666;", 
          "Adjust these to simulate different economic futures:"),
        
        sliderInput(
          "scenario_savings",
          "Change in Avg Savings Rate (%):",
          min = -5,
          max = 5,
          value = 0,
          step = 0.5
        ),
        helpText("If people save 2% more, set to +2"),
        
        sliderInput(
          "scenario_wage",
          "Change in Avg Wage Growth (%):",
          min = -3,
          max = 3,
          value = 0,
          step = 0.5
        ),
        helpText("If wages grow 1.5% faster, set to +1.5"),
        
        sliderInput(
          "scenario_inflation",
          "Change in Avg Inflation (%):",
          min = -2,
          max = 2,
          value = 0,
          step = 0.5
        ),
        helpText("If inflation rises 1%, set to +1"),
        
        sliderInput(
          "scenario_borrow",
          "Change in Avg Interest Rates (%):",
          min = -1,
          max = 1,
          value = 0,
          step = 0.25
        ),
        helpText("If Fed raises rates 0.5%, set to +0.5"),
        
        br(),
        
        actionButton(
          "apply_scenario",
          "Apply Scenario & Update Forecast",
          class = "btn-warning",
          style = "width:100%; font-weight:bold;"
        )
      )
    ),
    
    column(
      width = 9,
      box(
        title = "CFHI Forecast Chart",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        
        p(style = "font-size:13px; color:#555;",
          tags$b("Blue line:"), " Historical CFHI data | ",
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
