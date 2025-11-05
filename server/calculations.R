# --- NAVIGATION BUTTONS FOR PERSONAL FINANCE SECTION ---

observeEvent(input$go_to_credit_resources, {
  updateTabItems(session, "tabs", "credit")   # Change "credit" to your actual credit tab name if you have one
})

observeEvent(input$go_to_savings_guide, {
  updateTabItems(session, "tabs", "guide")    # Savings Guide tab
})

observeEvent(input$go_to_debt_tools, {
  updateTabItems(session, "tabs", "forecast") # Or wherever your debt/budget tools are
})

observeEvent(input$go_to_loan_calculator, {
  updateTabItems(session, "tabs", "loans")     # Loan calculator tab
})

observeEvent(input$go_to_overview, {
  updateTabItems(session, "tabs", "home")     # Back to overview/home
})



# === Recommended Calculation ===
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

# === Current Spending Calculation ===
calc_current <- reactive({
  needs <- sum(
    input$inNumber2,  # Rent
    input$inNumber3,  # Utilities
    input$inNumber4,  # Healthcare
    input$inNumber5,  # Insurance
    input$inNumber6,  # Other Needs
    na.rm = TRUE
  )
  
  wants <- sum(
    input$inNumber7,  # Subscriptions
    input$inNumber8,  # Dining Out
    input$inNumber9,  # Entertainment
    input$inNumber10, # Shopping
    input$inNumber11, # Travel
    na.rm = TRUE
  )
  
  income <- input$inNumber
  savings <- max(income - (needs + wants), 0)
  
  list(needs = needs, wants = wants, savings = savings)
})

# === Recommended Outputs ===
output$needs_out <- renderText({
  paste0("$", format(round(calc_recommended()$needs, 2), big.mark = ","))
})

output$wants_out <- renderText({
  paste0("$", format(round(calc_recommended()$wants, 2), big.mark = ","))
})

output$savings_out <- renderText({
  paste0("$", format(round(calc_recommended()$savings, 2), big.mark = ","))
})

# === Current Spending Outputs ===
output$needs_current <- renderText({
  paste0("$", format(round(calc_current()$needs, 2), big.mark = ","))
})

output$wants_current <- renderText({
  paste0("$", format(round(calc_current()$wants, 2), big.mark = ","))
})

output$savings_current <- renderText({
  paste0("$", format(round(calc_current()$savings, 2), big.mark = ","))
})

# === Fancy Dynamic Color Boxes ===
colorBox <- function(current, recommended, title, icon_type = "circle") {
  # Logic: savings = inverse condition
  if (title == "Savings") {
    color <- if (current >= recommended) "#e8f8f2" else "#fde8e8"
    border <- if (current >= recommended) "#00a65a" else "#dc3545"
    label <- if (current >= recommended) "Above recommended" else "Below recommended"
    emoji <- if (current >= recommended) "✅" else "⚠️"
  } else {
    color <- if (current <= recommended) "#e8f8f2" else "#fde8e8"
    border <- if (current <= recommended) "#00a65a" else "#dc3545"
    label <- if (current <= recommended) "Below recommended" else "Above recommended"
    emoji <- if (current <= recommended) "✅" else "⚠️"
  }
  
  # Card design
  wellPanel(
    div(
      style = paste0(
        "background:", color, ";",
        "border: 2px solid ", border, ";",
        "border-radius: 14px;",
        "padding: 25px;",
        "text-align: center;",
        "font-family: 'Segoe UI', sans-serif;",
        "box-shadow: 0 4px 12px rgba(0,0,0,0.1);",
        "transition: transform 0.2s ease-in-out;",
        "cursor: default;"
      ),
     
      # title
      h4(tags$i(class = paste0("fa fa-", icon_type)), 
         paste0(" ", title),
         style = "font-weight:600; margin-bottom:10px;"),
      
      # main amount
      h2(paste0("$", format(round(current, 0), big.mark = ",")),
         style = "margin:10px 0; font-weight:700; color:#222;"),
      
      # indicator pill
      span(emoji, label,
           style = paste0(
             "display:inline-block;",
             "margin-top:10px;",
             "padding:6px 12px;",
             "border-radius:6px;",
             "background-color:", border, ";",
             "color:white;",
             "font-size:14px;"
           ))
    )
  )
}

# === Render the UI Boxes ===
output$needsBox <- renderUI({
  colorBox(calc_current()$needs, calc_recommended()$needs, "Needs", "shopping-basket")
})

output$wantsBox <- renderUI({
  colorBox(calc_current()$wants, calc_recommended()$wants, "Wants", "heart")
})

output$savingsBox <- renderUI({
  colorBox(calc_current()$savings, calc_recommended()$savings, "Savings", "piggy-bank")
})


# Function for static recommended boxes (styled like colorBox but neutral)
recommendedBox <- function(title, amount, icon_type = "circle") {
  wellPanel(
    div(
      style = paste0(
        "background:#fafafa;",
        "border: 2px solid #dcdcdc;",
        "border-radius: 14px;",
        "padding: 25px;",
        "text-align: center;",
        "font-family: 'Segoe UI', sans-serif;",
        "box-shadow: 0 4px 12px rgba(0,0,0,0.05);"
      ),
      h4(tags$i(class = paste0("fa fa-", icon_type)), 
         paste0(" ", title),
         style = "font-weight:600; margin-bottom:10px;"),
      
      h2(paste0("$", format(round(amount, 0), big.mark = ",")),
         style = "margin:10px 0; font-weight:700; color:#222;")
    )
  )
}

# Render the recommended boxes
output$recNeedsBox <- renderUI({
  recommendedBox("Needs (50%)", calc_recommended()$needs, "shopping-basket")
})

output$recWantsBox <- renderUI({
  recommendedBox("Wants (30%)", calc_recommended()$wants, "heart")
})

output$recSavingsBox <- renderUI({
  recommendedBox("Savings (20%)", calc_recommended()$savings, "piggy-bank")
})

