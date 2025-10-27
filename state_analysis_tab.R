tabItem(
  tabName = "explore",
  h2("State-by-State Economic Analysis"),
  p("Explore geographic variation in economic health indicators across U.S. states."),
  br(),
  
  fluidRow(
    column(
      width = 3,
      box(
        title = "Analysis Settings",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        selectInput(
          "map_metric",
          "Display Metric:",
          choices = c(
            "Personal Income" = "median_income",
            "GDP per Capita" = "unemployment",
            "Disposable Income per Capita" = "poverty",
            "Income per Capita" = "cost_living"
          ),
          selected = "median_income"
        ),
        
        hr(),
        
        h4("State Comparison"),
        
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
