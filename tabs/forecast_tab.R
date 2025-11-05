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
            tags$b("Shaded areas"), " represent confidence intervals (darker = more confident)."
          )
        )
      )
    )
  )
)
