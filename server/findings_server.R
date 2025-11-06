# ===============================================================================
# FINDINGS SERVER LOGIC
# ===============================================================================

# Load CFHI data for findings
  findings_data <- reactive({
    read_csv("data/cfhi/cfhi_master_2000_onward.csv", show_col_types = FALSE) %>%
      mutate(date = as.Date(date))
  })

# Peak value box
output$findings_peak <- renderValueBox({
  df <- findings_data()
  peak_idx <- which.max(df$CFHI)
  peak_val <- df$CFHI[peak_idx]
  peak_date <- format(df$date[peak_idx], "%b %Y")
  
  valueBox(
    value = sprintf("%.1f", peak_val),
    subtitle = paste0("Peak (", peak_date, ")"),
    icon = icon("arrow-trend-up"),
    color = "green"
  )
})

# Trough value box
output$findings_trough <- renderValueBox({
  df <- findings_data()
  trough_idx <- which.min(df$CFHI)
  trough_val <- df$CFHI[trough_idx]
  trough_date <- format(df$date[trough_idx], "%b %Y")
  
  valueBox(
    value = sprintf("%.1f", trough_val),
    subtitle = paste0("Trough (", trough_date, ")"),
    icon = icon("arrow-trend-down"),
    color = "red"
  )
})

# Current value box
output$findings_current <- renderValueBox({
  df <- findings_data()
  current_val <- tail(df$CFHI, 1)
  current_date <- format(tail(df$date, 1), "%b %Y")
  
  # Color based on quartiles
  color <- if (current_val > median(df$CFHI)) {
    "yellow"
  } else {
    "orange"
  }
  
  valueBox(
    value = sprintf("%.1f", current_val),
    subtitle = paste0("Current (", current_date, ")"),
    icon = icon("calendar-day"),
    color = color
  )
})

# Mean value box
output$findings_mean <- renderValueBox({
  df <- findings_data()
  mean_val <- mean(df$CFHI, na.rm = TRUE)
  
  valueBox(
    value = sprintf("%.1f", mean_val),
    subtitle = "Historical Average",
    icon = icon("chart-line"),
    color = "blue"
  )
})
