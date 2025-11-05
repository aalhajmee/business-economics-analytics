tabItem(
  tabName = "explore",
  h2("Which States Have Better Economic Health?",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  
  fluidRow(
    column(12,
      box(
        title = "What You're Looking At",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        tags$div(style = "font-size:15px;",
          tags$p(tags$b("This tool compares all 50 U.S. states on key economic measures:")),
          tags$ul(
            tags$li(tags$b("Income:"), " How much do households earn? (median = middle value)"),
            tags$li(tags$b("Jobs:"), " How many people are unemployed and looking for work?"),
            tags$li(tags$b("Poverty:"), " How many people live below the poverty line?"),
            tags$li(tags$b("Cost of Living:"), " How expensive is it to live there compared to the U.S. average?")
          ),
          tags$p(tags$b("How to use:"), " Pick a metric below to see the map change colors. ", 
            tags$span(style = "color:#16a34a; font-weight:bold;", "Green = better"), ", ",
            tags$span(style = "color:#dc2626; font-weight:bold;", "Red = worse"), 
            ". Hover over any state to see its exact value.")
        )
      )
    )
  ),
  
  fluidRow(
    column(12,
      box(
        title = "Official Data Sources",
        width = 12,
        status = "info",
        solidHeader = FALSE,
        collapsible = FALSE,
        
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
        title = "Pick Any Two States to Compare",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        p(style = "font-size:13px; color:#555;", 
          "Select two states below to see their economic data side-by-side:"),
        
        selectInput(
          "compare_state_1",
          "First State:",
          choices = NULL
        ),
        
        selectInput(
          "compare_state_2",
          "Second State:",
          choices = NULL
        ),
        
        actionButton(
          "compare_states",
          "Show Comparison",
          class = "btn-primary",
          style = "width:100%; font-weight:bold;"
        )
      ),
      
      box(
        title = "Top 5 Best States",
        width = 12,
        status = "success",
        solidHeader = TRUE,
        
        p(style = "font-size:12px; color:#666; margin-bottom:10px;",
          "States with the best (highest/lowest) values for selected metric:"),
        tableOutput("top_states")
      ),
      
      box(
        title = "Bottom 5 Worst States",
        width = 12,
        status = "success",
        solidHeader = TRUE,
        
        p(style = "font-size:12px; color:#666; margin-bottom:10px;",
          "States with the worst (lowest/highest) values for selected metric:"),
        tableOutput("bottom_states")
      )
    ),
    
    column(
      width = 9,
      box(
        title = "Interactive State Map",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        
        p(style = "font-size:13px; color:#555; margin-bottom:15px;",
          tags$b("Hover over any state"), " to see its exact value. ",
          tags$span(style = "color:#16a34a; font-weight:bold;", "Green"), 
          " states are doing better, ",
          tags$span(style = "color:#dc2626; font-weight:bold;", "red"), 
          " states are doing worse on the selected metric."),
        
        plotlyOutput("state_map", height = "500px")
      ),
      
      box(
        title = "Side-by-Side State Comparison",
        width = 12,
        status = "success",
        solidHeader = TRUE,
        
        p(style = "font-size:13px; color:#555; margin-bottom:10px;",
          "Select two states from the left sidebar and click 'Show Comparison' to see detailed data:"),
        
        uiOutput("comparison_output")
      )
    )
  )
)
