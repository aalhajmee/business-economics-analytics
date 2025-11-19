# ============================================================================
# Savings Guide (50/30/20 Rule) - Server Logic
# ============================================================================

planning_guide_server <- function(input, output, session) {
  
  # === Recommended Calculation ===
  calc_recommended <- reactive({
    income <- input$sav_guide_income
    
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
      input$sav_guide_rent %||% 0,
      input$sav_guide_utilities %||% 0,
      input$sav_guide_healthcare %||% 0,
      input$sav_guide_insurance %||% 0,
      input$sav_guide_other_needs %||% 0,
      na.rm = TRUE
    )
    
    wants <- sum(
      input$sav_guide_subscriptions %||% 0,
      input$sav_guide_dining %||% 0,
      input$sav_guide_entertainment %||% 0,
      input$sav_guide_shopping %||% 0,
      input$sav_guide_travel %||% 0,
      na.rm = TRUE
    )
    
    income <- input$sav_guide_income %||% 0
    savings <- max(income - (needs + wants), 0)
    
    list(needs = needs, wants = wants, savings = savings)
  })
  
  # === Color Box Function ===
  colorBox <- function(current, recommended, title, icon_name) {
    # Logic: savings = inverse condition
    if (title == "Savings") {
      color <- if (current >= recommended) "#e8f8f2" else "#fde8e8"
      border <- if (current >= recommended) "#10b981" else "#ef4444"
      label <- if (current >= recommended) "Above recommended" else "Below recommended"
    } else {
      color <- if (current <= recommended) "#e8f8f2" else "#fde8e8"
      border <- if (current <= recommended) "#10b981" else "#ef4444"
      label <- if (current <= recommended) "Below recommended" else "Above recommended"
    }
    
    # Card design
    card(
      div(
        style = paste0(
          "background:", color, ";",
          "border: 2px solid ", border, ";",
          "border-radius: 14px;",
          "padding: 25px;",
          "text-align: center;",
          "box-shadow: 0 4px 12px rgba(0,0,0,0.1);"
        ),
        h4(tags$span(bs_icon(icon_name), paste0(" ", title)),
           style = "font-weight:600; margin-bottom:10px;"),
        h2(paste0("$", format(round(current, 0), big.mark = ",")),
           style = "margin:10px 0; font-weight:700; color:#1e293b;"),
        span(label,
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
  
  # === Recommended Box Function ===
  recommendedBox <- function(title, amount, icon_name) {
    card(
      div(
        style = paste0(
          "background:#f8fafc;",
          "border: 2px solid #e2e8f0;",
          "border-radius: 14px;",
          "padding: 25px;",
          "text-align: center;",
          "box-shadow: 0 4px 12px rgba(0,0,0,0.05);"
        ),
        h4(tags$span(bs_icon(icon_name), paste0(" ", title)),
           style = "font-weight:600; margin-bottom:10px;"),
        h2(paste0("$", format(round(amount, 0), big.mark = ",")),
           style = "margin:10px 0; font-weight:700; color:#1e293b;")
      )
    )
  }
  
  # === Render Current Spending Boxes ===
  output$sav_guide_needs_box <- renderUI({
    current <- calc_current()
    recommended <- calc_recommended()
    colorBox(current$needs, recommended$needs, "Needs", "basket")
  })
  
  output$sav_guide_wants_box <- renderUI({
    current <- calc_current()
    recommended <- calc_recommended()
    colorBox(current$wants, recommended$wants, "Wants", "heart")
  })
  
  output$sav_guide_savings_box <- renderUI({
    current <- calc_current()
    recommended <- calc_recommended()
    colorBox(current$savings, recommended$savings, "Savings", "piggy-bank")
  })
  
  # === Render Recommended Budget Boxes ===
  output$sav_guide_rec_needs_box <- renderUI({
    recommended <- calc_recommended()
    recommendedBox("Needs (50%)", recommended$needs, "basket")
  })
  
  output$sav_guide_rec_wants_box <- renderUI({
    recommended <- calc_recommended()
    recommendedBox("Wants (30%)", recommended$wants, "heart")
  })
  
  output$sav_guide_rec_savings_box <- renderUI({
    recommended <- calc_recommended()
    recommendedBox("Savings (20%)", recommended$savings, "piggy-bank")
  })
}

