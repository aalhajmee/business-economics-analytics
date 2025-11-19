# ============================================================================
# Scenario Analysis - Server Logic
# ============================================================================

scenarios_server <- function(input, output, session) {
  
  # Reactive scenario data - Auto-updates on input change
  scenario_data <- reactive({
    req(input$scen_age, input$scen_retire_age, input$scen_savings, input$scen_contrib)
    
    years <- input$scen_retire_age - input$scen_age
    
    if (years <= 0) {
      return(NULL)
    }
    
    # Define 3 scenarios with realistic parameters
    scenarios <- list(
      Conservative = list(r = 0.05, vol = 0.08, name = "Conservative (5% return, 8% volatility)"),
      Moderate     = list(r = 0.07, vol = 0.12, name = "Moderate (7% return, 12% volatility)"),
      Aggressive   = list(r = 0.09, vol = 0.18, name = "Aggressive (9% return, 18% volatility)")
    )
    
    # Deterministic projection (using expected return, no volatility)
    results <- lapply(names(scenarios), function(name) {
      s <- scenarios[[name]]
      
      balance <- numeric(years + 1)
      balance[1] <- input$scen_savings
      annual_contrib <- input$scen_contrib * 12
      
      # Compound annually: add contributions at start of year, then apply return
      for(t in 1:years) {
        balance[t+1] <- (balance[t] + annual_contrib) * (1 + s$r)
      }
      
      data.frame(
        Age = input$scen_age + (0:years),
        Balance = balance,
        Strategy = name,
        Return = s$r
      )
    })
    
    do.call(rbind, results)
  })
  
  output$scen_plot <- renderPlotly({
    df <- scenario_data()
    req(df)
    
    # Professional color palette
    colors <- c("Conservative" = "#10b981", "Moderate" = "#3b82f6", "Aggressive" = "#f59e0b")
    
    p <- plot_ly(df, x = ~Age, y = ~Balance, color = ~Strategy, colors = colors, 
                  type = 'scatter', mode = 'lines', line = list(width = 3)) %>%
      layout(
        title = list(text = "Strategy Comparison (Deterministic Projections)", 
                    font = list(color = "#1e293b", size = 18)),
        yaxis = list(title = "Portfolio Value ($)", tickformat = "$,"),
        xaxis = list(title = "Age"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        legend = list(orientation = "h", x = 0.1, y = -0.15)
      )
    
    p
  })
  
  output$scen_table <- renderDT({
    df <- scenario_data()
    req(df)
    
    # Calculate total contributions once to avoid repetition and division by zero
    total_contrib <- input$scen_savings + input$scen_contrib * 12 * (input$scen_retire_age - input$scen_age)
    
    final <- df %>% 
      group_by(Strategy) %>% 
      filter(Age == max(Age)) %>%
      arrange(match(Strategy, c("Conservative", "Moderate", "Aggressive"))) %>%
      mutate(
        `Final Amount` = scales::dollar(Balance),
        `Total Contributions` = scales::dollar(total_contrib),
        `Total Return` = scales::dollar(Balance - total_contrib),
        `Return %` = ifelse(total_contrib > 0, 
                           scales::percent((Balance - total_contrib) / total_contrib),
                           "N/A")
      ) %>%
      select(Strategy, `Final Amount`, `Total Contributions`, `Total Return`, `Return %`)
    
    datatable(
      final,
      options = list(dom = 't', pageLength = 3),
      rownames = FALSE
    )
  })
}
