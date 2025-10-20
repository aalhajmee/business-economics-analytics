#Recommended
calc_recommended <- reactive({
  income <- input$inNumber
  
  if (is.null(income) || income <= 0) {
    return(list(needs = 0, wants = 0, savings = 0))
  }
  
  list(
    needs = income * 0.5,
    wants = income * 0.3,
    savings = income * 0.2
  )
})

#Current Spending
calc_current <- reactive({
  # Needs inputs
  needs <- sum(
    input$inNumber2,  #Rent
    input$inNumber3,  #Utilities
    input$inNumber4,  #Healthcare
    input$inNumber5,  #Insurance
    input$inNumber6,  #Other Needs
    na.rm = TRUE
  )
  
  # Wants inputs
  wants <- sum(
    input$inNumber7,  #Subscriptions
    input$inNumber8,  #Dining Out
    input$inNumber9,  #Entertainment
    input$inNumber10, #Shopping
    input$inNumber11, #Travel
    na.rm = TRUE
  )
  
  income <- input$inNumber
  savings <- max(income - (needs + wants), 0)
  
  list(needs = needs, wants = wants, savings = savings)
})

#Recommended
output$needs_out <- renderText({
  paste0("$", format(round(calc_recommended()$needs, 2), big.mark = ","))
})

output$wants_out <- renderText({
  paste0("$", format(round(calc_recommended()$wants, 2), big.mark = ","))
})

output$savings_out <- renderText({
  paste0("$", format(round(calc_recommended()$savings, 2), big.mark = ","))
})

# === Current Budget Outputs ===
output$needs_current <- renderText({
  paste0("$", format(round(calc_current()$needs, 2), big.mark = ","))
})

output$wants_current <- renderText({
  paste0("$", format(round(calc_current()$wants, 2), big.mark = ","))
})

output$savings_current <- renderText({
  paste0("$", format(round(calc_current()$savings, 2), big.mark = ","))
})


#CHANGING COLORS DEPENDING ON THE INPUT MATCHING RECOMMENDED
colorBox <- function(current, recommended, title) {
  color <- if (current <= recommended) "#d9fcd9" else "#ffd6d6"   # green or red background
  border <- if (current <= recommended) "#28a745" else "#dc3545"  # green or red border
  symbol <- if (current <= recommended) "✅" else "⚠️"
  
  wellPanel(
    div(
      style = paste0(
        "background-color:", color, ";",
        "border: 2px solid ", border, ";",
        "border-radius: 8px;",
        "padding: 15px;",
        "text-align: center;",
        "box-shadow: 1px 1px 4px rgba(0,0,0,0.1);"
      ),
      h4(title),
      h3(paste0("$", format(round(current, 2), big.mark = ","))),
      p(symbol, if (current <= recommended) "Below recommended" else "Above recommended")
    )
  )
}

# Render the dynamic boxes
output$needsBox <- renderUI({
  colorBox(calc_current()$needs, calc_recommended()$needs, "Needs")
})

output$wantsBox <- renderUI({
  colorBox(calc_current()$wants, calc_recommended()$wants, "Wants")
})

output$savingsBox <- renderUI({
  current <- calc_current()$savings
  recommended <- calc_recommended()$savings
  
  # For savings: green if current >= recommended
  color <- if (current >= recommended) "#d9fcd9" else "#ffd6d6"
  border <- if (current >= recommended) "#28a745" else "#dc3545"
  symbol <- if (current >= recommended) "✅" else "⚠️"
  
  wellPanel(
    div(
      style = paste0(
        "background-color:", color, ";",
        "border: 2px solid ", border, ";",
        "border-radius: 8px;",
        "padding: 15px;",
        "text-align: center;",
        "box-shadow: 1px 1px 4px rgba(0,0,0,0.1);"
      ),
      h4("Savings"),
      h3(paste0("$", format(round(current, 2), big.mark = ","))),
      p(symbol, if (current >= recommended) "Above recommended" else "Below recommended")
    )
  )
}) 