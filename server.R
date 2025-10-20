library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(zoo)
library(lubridate)

# CFHI module (reads cfhi_data/cfhi_master_2000_onward.csv)
source("R_Scripts/cfhi_feature_server.R")

shinyServer(function(input, output, session) {
  
  # ---------------- CFHI MODULE ----------------
  cfhi_feature_server(
    id = "cfhi",
    master_path = "cfhi_data/cfhi_master_2000_onward.csv"
  )
  
  # ---------------- BUDGET CALCULATOR ----------------
  # Recommended 50/30/20
  calc_recommended <- reactive({
    income <- input$inNumber
    if (is.null(income) || !is.numeric(income) || income <= 0) {
      return(list(needs = 0, wants = 0, savings = 0))
    }
    list(
      needs = income * 0.50,
      wants = income * 0.30,
      savings = income * 0.20
    )
  })
  
  # Current spending (sum of inputs)
  calc_current <- reactive({
    # Needs inputs
    needs <- sum(
      input$inNumber2,  # Rent
      input$inNumber3,  # Utilities
      input$inNumber4,  # Healthcare
      input$inNumber5,  # Insurance
      input$inNumber6,  # Other Needs
      na.rm = TRUE
    )
    # Wants inputs
    wants <- sum(
      input$inNumber7,   # Subscriptions
      input$inNumber8,   # Dining Out
      input$inNumber9,   # Entertainment
      input$inNumber10,  # Shopping
      input$inNumber11,  # Travel
      na.rm = TRUE
    )
    income  <- input$inNumber %||% 0
    savings <- max(income - (needs + wants), 0)
    list(needs = needs, wants = wants, savings = savings)
  })
  
  # Recommended outputs
  output$needs_out <- renderText({
    paste0("$", format(round(calc_recommended()$needs, 2), big.mark = ","))
  })
  output$wants_out <- renderText({
    paste0("$", format(round(calc_recommended()$wants, 2), big.mark = ","))
  })
  output$savings_out <- renderText({
    paste0("$", format(round(calc_recommended()$savings, 2), big.mark = ","))
  })
  
  # Current outputs
  output$needs_current <- renderText({
    paste0("$", format(round(calc_current()$needs, 2), big.mark = ","))
  })
  output$wants_current <- renderText({
    paste0("$", format(round(calc_current()$wants, 2), big.mark = ","))
  })
  output$savings_current <- renderText({
    paste0("$", format(round(calc_current()$savings, 2), big.mark = ","))
  })
  
  # Color box helper
  colorBox <- function(current, recommended, title,
                       invert = FALSE) {
    # invert=TRUE means "higher is better" (used for savings)
    ok <- if (invert) current >= recommended else current <= recommended
    color <- if (ok) "#d9fcd9" else "#ffd6d6"
    border <- if (ok) "#28a745" else "#dc3545"
    symbol <- if (ok) "✅" else "⚠️"
    
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
        p(symbol, if (ok) "Within target" else "Outside target")
      )
    )
  }
  
  # Render dynamic boxes
  output$needsBox <- renderUI({
    colorBox(calc_current()$needs, calc_recommended()$needs, "Needs")
  })
  output$wantsBox <- renderUI({
    colorBox(calc_current()$wants, calc_recommended()$wants, "Wants")
  })
  output$savingsBox <- renderUI({
    colorBox(calc_current()$savings, calc_recommended()$savings, "Savings", invert = TRUE)
  })
  
})
