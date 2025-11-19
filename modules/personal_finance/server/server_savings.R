# ============================================================================
# Savings Calculator - Server Logic
# ============================================================================

savings_server <- function(input, output, session) {
  
  # Reactive calculation - Auto-updates on input change
  savings_data <- reactive({
    req(input$sav_current, input$sav_monthly, input$sav_rate, input$sav_years)
    
    # Get inputs
    current_savings <- input$sav_current
    monthly_contrib <- input$sav_monthly
    annual_return <- input$sav_rate / 100
    years <- input$sav_years
    
    # Calculations (Monthly Compounding)
    monthly_rate <- annual_return / 12
    months <- 0:(years * 12)
    
    # Future Value Formula: 
    # FV = P*(1+r)^n + PMT * ((1+r)^n - 1)/r
    balance <- numeric(length(months))
    contribution <- numeric(length(months))
    
    if (monthly_rate > 0) {
      balance <- current_savings * (1 + monthly_rate)^months + 
                 monthly_contrib * (((1 + monthly_rate)^months - 1) / monthly_rate)
    } else {
      balance <- current_savings + (monthly_contrib * months)
    }
    
    contribution <- current_savings + (monthly_contrib * months)
    
    data.frame(
      Year = months / 12,
      Balance = balance,
      Contribution = contribution
    )
  })
  
  # Income-based savings rate recommendation
  savings_recommendation <- reactive({
    req(input$sav_monthly)
    
    # Estimate annual income from monthly contribution (assuming 20% savings rate as baseline)
    # If user saves $500/month, that's $6,000/year, which at 20% rate suggests $30k income
    # But we'll use a more conservative estimate
    estimated_annual_income <- (input$sav_monthly * 12) / 0.15  # Assume 15% savings rate
    
    # Savings rate recommendations by income level (based on financial planning best practices)
    if (estimated_annual_income < 50000) {
      rec_rate <- 10  # Lower income: aim for 10%
      rec_monthly <- estimated_annual_income * 0.10 / 12
    } else if (estimated_annual_income < 100000) {
      rec_rate <- 15  # Middle income: aim for 15%
      rec_monthly <- estimated_annual_income * 0.15 / 12
    } else {
      rec_rate <- 20  # Higher income: aim for 20%
      rec_monthly <- estimated_annual_income * 0.20 / 12
    }
    
    current_rate_est <- if(estimated_annual_income > 0) {
      (input$sav_monthly * 12) / estimated_annual_income * 100
    } else {
      0
    }
    
    list(
      estimated_income = estimated_annual_income,
      recommended_rate = rec_rate,
      recommended_monthly = rec_monthly,
      current_monthly = input$sav_monthly,
      current_rate_est = current_rate_est
    )
  })
  
  # Render Plot
  output$sav_plot <- renderPlotly({
    df <- savings_data()
    
    p <- plot_ly(df, x = ~Year) %>%
      add_trace(y = ~Balance, name = 'Total Balance', type = 'scatter', mode = 'lines', 
                line = list(color = '#2563eb', width = 3), fill = 'tozeroy', fillcolor = 'rgba(37, 99, 235, 0.1)') %>%
      add_trace(y = ~Contribution, name = 'Total Contribution', type = 'scatter', mode = 'lines',
                line = list(color = '#64748b', width = 2, dash = 'dash')) %>%
      layout(
        title = list(text = "Projected Savings Growth", font = list(color = "#1e293b", size = 18)),
        yaxis = list(title = "Amount ($)", tickformat = "$,"),
        xaxis = list(title = "Years"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        legend = list(orientation = "h", x = 0.1, y = -0.15)
      )
    
    p
  })
  
  # Render Summary with Recommendations
  output$sav_summary <- renderUI({
    df <- savings_data()
    rec <- savings_recommendation()
    
    final_amount <- tail(df$Balance, 1)
    total_contributions <- tail(df$Contribution, 1)
    total_interest <- final_amount - total_contributions
    
    tagList(
      div(class = "alert alert-info",
        h5("Projection Summary"),
        tags$ul(
          tags$li(strong("Final Balance:"), scales::dollar(final_amount)),
          tags$li(strong("Total Contributions:"), scales::dollar(total_contributions)),
          tags$li(strong("Total Interest Earned:"), scales::dollar(total_interest))
        )
      ),
      div(class = "alert alert-light border",
        h5("Savings Rate Recommendation"),
        p(class = "mb-1",
          "Based on your monthly contribution of ", scales::dollar(input$sav_monthly), 
          ", we estimate your annual income around ", scales::dollar(round(rec$estimated_income)), "."
        ),
        p(class = "mb-1",
          "Recommended savings rate: ", strong(paste0(rec$recommended_rate, "%")), 
          " (", scales::dollar(round(rec$recommended_monthly)), " per month)"
        ),
        if (input$sav_monthly < rec$recommended_monthly) {
          p(class = "text-warning mb-0", 
            "💡 Consider increasing your monthly savings to meet the recommended rate.")
        } else {
          p(class = "text-success mb-0", 
            "✅ You're meeting or exceeding the recommended savings rate!")
        }
      )
    )
  })
}
