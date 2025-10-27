tabItem(
  tabName = "explore",
  h2("State-by-State Economic Analysis"),
  p("Compare economic health indicators across U.S. states using official government data."),
  
  fluidRow(
    column(12,
      box(
        title = "Data Sources",
        width = 12,
        status = "info",
        solidHeader = FALSE,
        collapsible = TRUE,
        collapsed = TRUE,
        
        tags$ul(
          tags$li(tags$b("Median Income & Poverty:"), " U.S. Census Bureau, American Community Survey 2023 5-Year Estimates"),
          tags$li(tags$b("Unemployment Rate:"), " Bureau of Labor Statistics, Local Area Unemployment Statistics (August 2025)"),
          tags$li(tags$b("Cost of Living Index:"), " Missouri Economic Research and Information Center (100 = U.S. average, higher values = more expensive)")
        )
      )
    )
  ),
  
  br(),
  
  fluidRow(
    column(
      width = 3,
      box(
        title = "Map Controls",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        selectInput(
          "map_metric",
          "Select Metric to Display:",
          choices = c(
            "Median Household Income" = "median_income",
            "Unemployment Rate" = "unemployment",
            "Poverty Rate" = "poverty",
            "Cost of Living Index" = "cost_living"
          ),
          selected = "median_income"
        ),
        
        p(style = "font-size: 12px; color: #666; margin-top: 10px;",
          textOutput("metric_explanation"))
        ),
      
      box(
        title = "State Comparison",
        width = 12,
        status = "warning",
        solidHeader = TRUE,
        
        selectInput(
          "compare_state_1",
          "State 1:",
          choices = NULL
        ),
        
        selectInput(
          "compare_state_2",
          "State 2:",
          choices = NULL
        ),
        
        actionButton(
          "compare_states",
          "Compare States",
          class = "btn-info",
          style = "width:100%;"
        )
      ),
      
      box(
        title = "Top 5 States",
        width = 12,
        status = "success",
        
        tableOutput("top_states")
      ),
      
      box(
        title = "Bottom 5 States",
        width = 12,
        status = "danger",
        
        tableOutput("bottom_states")
      )
    ),
    
    column(
      width = 9,
      box(
        title = "State Choropleth Map",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        
        plotlyOutput("state_map", height = "500px")
      ),
      
      box(
        title = "State Comparison",
        width = 12,
        status = "warning",
        
        uiOutput("comparison_output")
      )
    )
  )
)
