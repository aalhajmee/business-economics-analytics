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
      width = 3,
      box(
        title = "Forecast Settings",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        h4("Time Period", style="margin-top:0;"),
        radioButtons(
          "forecast_months",
          NULL,
          choices = c("6 months" = 6, "1 year" = 12, "2 years" = 24),
          selected = 12,
          inline = FALSE
        ),
        
        hr(),
        
        h4("Economic Scenario"),
        radioButtons(
          "scenario_preset",
          NULL,
          choices = c(
            "Current Trends (Baseline)" = "baseline",
            "Economic Growth" = "growth",
            "Economic Decline" = "decline",
            "High Inflation" = "inflation"
          ),
          selected = "baseline",
          inline = FALSE
        ),
        
        div(style="background:#f8f9fa; padding:12px; border-radius:5px; margin-top:15px; font-size:12px;",
          tags$b("What do these mean?"),
          tags$ul(style="margin:8px 0 0 0; padding-left:18px;",
            tags$li(tags$b("Current Trends:"), " Historical patterns continue"),
            tags$li(tags$b("Economic Growth:"), " Rising wages, stable savings"),
            tags$li(tags$b("Economic Decline:"), " Lower wages, higher costs"),
            tags$li(tags$b("High Inflation:"), " Increased prices, reduced purchasing power")
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
      width = 9,
      box(
        title = "Forecast Results",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        
        plotlyOutput("forecast_plot", height = "500px"),
        
        br(),
        
        div(style="background:#e3f2fd; padding:15px; border-radius:5px; border-left:4px solid #2196f3;",
          tags$p(style="margin:0; font-size:14px;",
            tags$b(icon("info-circle"), " How to read this chart:"),
            tags$ul(style="margin:8px 0 0 0; padding-left:20px;",
              tags$li(tags$b("Blue line:"), " Historical CFHI values (what actually happened)"),
              tags$li(tags$b("Orange line:"), " Forecasted CFHI (predicted future values)"),
              tags$li(tags$b("Shaded areas:"), " Confidence intervals (where values will likely fall)")
            )
          )
        )
      )
    )
  )
)
