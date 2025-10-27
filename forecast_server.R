forecast_data <- reactive({
  df <- read_csv("cfhi_data/cfhi_master_2000_onward.csv", show_col_types = FALSE)
  df <- df %>%
    arrange(date) %>%
    distinct(date, .keep_all = TRUE) %>%
    filter(!is.na(CFHI))
  
  ts_data <- ts(df$CFHI, frequency = 12, start = c(year(min(df$date)), month(min(df$date))))
  
  list(
    df = df,
    ts = ts_data,
    latest_date = max(df$date),
    latest_value = df$CFHI[which.max(df$date)]
  )
})

forecast_model <- eventReactive(input$apply_scenario, {
  data <- forecast_data()
  horizon <- input$forecast_months
  method <- input$forecast_method
  
  base_forecast <- if (method == "arima") {
    fit <- auto.arima(data$ts)
    forecast(fit, h = horizon)
  } else if (method == "ets") {
    fit <- ets(data$ts)
    forecast(fit, h = horizon)
  } else {
    fit1 <- auto.arima(data$ts)
    fit2 <- ets(data$ts)
    f1 <- forecast(fit1, h = horizon)
    f2 <- forecast(fit2, h = horizon)
    
    f1$mean <- (f1$mean + f2$mean) / 2
    f1$lower <- (f1$lower + f2$lower) / 2
    f1$upper <- (f1$upper + f2$upper) / 2
    f1
  }
  
  scenario_adj <- (
    input$scenario_savings * 0.25 +
    input$scenario_wage * 0.25 +
    input$scenario_inflation * -0.25 +
    input$scenario_borrow * -0.25
  )
  
  base_forecast$mean <- base_forecast$mean + scenario_adj
  base_forecast$lower <- base_forecast$lower + scenario_adj
  base_forecast$upper <- base_forecast$upper + scenario_adj
  
  list(
    forecast = base_forecast,
    fit = if (exists("fit1")) fit1 else fit,
    method = method
  )
}, ignoreNULL = FALSE)

output$forecast_plot <- renderPlotly({
  data <- forecast_data()
  model <- forecast_model()
  fcast <- model$forecast
  
  future_dates <- seq.Date(
    from = data$latest_date + months(1),
    by = "month",
    length.out = input$forecast_months
  )
  
  historical_df <- data.frame(
    date = as.Date(time(data$ts)),
    value = as.numeric(data$ts),
    type = "Historical"
  )
  
  forecast_df <- data.frame(
    date = future_dates,
    value = as.numeric(fcast$mean),
    lower80 = as.numeric(fcast$lower[,1]),
    upper80 = as.numeric(fcast$upper[,1]),
    lower95 = as.numeric(fcast$lower[,2]),
    upper95 = as.numeric(fcast$upper[,2]),
    type = "Forecast"
  )
  
  plot_ly() %>%
    add_trace(
      data = historical_df,
      x = ~date,
      y = ~value,
      type = "scatter",
      mode = "lines",
      name = "Historical CFHI",
      line = list(color = "#1e40af", width = 2)
    ) %>%
    add_trace(
      data = forecast_df,
      x = ~date,
      y = ~value,
      type = "scatter",
      mode = "lines",
      name = "Forecast",
      line = list(color = "#ea580c", width = 2, dash = "dash")
    ) %>%
    add_ribbons(
      data = forecast_df,
      x = ~date,
      ymin = ~lower80,
      ymax = ~upper80,
      name = "80% Confidence",
      fillcolor = "rgba(234, 88, 12, 0.2)",
      line = list(width = 0),
      showlegend = TRUE
    ) %>%
    add_ribbons(
      data = forecast_df,
      x = ~date,
      ymin = ~lower95,
      ymax = ~upper95,
      name = "95% Confidence",
      fillcolor = "rgba(234, 88, 12, 0.1)",
      line = list(width = 0),
      showlegend = TRUE
    ) %>%
    layout(
      title = paste("CFHI Forecast -", input$forecast_method),
      xaxis = list(title = "Date"),
      yaxis = list(title = "CFHI Value"),
      hovermode = "x unified"
    )
})

output$forecast_stat_current <- renderUI({
  data <- forecast_data()
  div(
    h4(style = "color:#1e40af;", round(data$latest_value, 2)),
    p(style = "font-size:12px; color:#666;", "Current CFHI"),
    p(style = "font-size:11px; color:#999;", format(data$latest_date, "%b %Y"))
  )
})

output$forecast_stat_predicted <- renderUI({
  model <- forecast_model()
  fcast <- model$forecast
  final_value <- as.numeric(tail(fcast$mean, 1))
  
  div(
    h4(style = "color:#ea580c;", round(final_value, 2)),
    p(style = "font-size:12px; color:#666;", paste(input$forecast_months, "Month Forecast"))
  )
})

output$forecast_stat_change <- renderUI({
  data <- forecast_data()
  model <- forecast_model()
  fcast <- model$forecast
  
  current <- data$latest_value
  predicted <- as.numeric(tail(fcast$mean, 1))
  change <- predicted - current
  change_pct <- (change / current) * 100
  
  color <- if (change > 0) "#16a34a" else "#dc2626"
  arrow <- if (change > 0) "↑" else "↓"
  
  div(
    h4(style = paste0("color:", color, ";"), paste0(arrow, " ", round(abs(change), 2))),
    p(style = "font-size:12px; color:#666;", "Expected Change"),
    p(style = paste0("font-size:11px; color:", color, ";"), paste0(round(change_pct, 1), "%"))
  )
})

output$forecast_metrics <- renderPrint({
  model <- forecast_model()
  
  cat("Model:", input$forecast_method, "\n")
  cat("Forecast Horizon:", input$forecast_months, "months\n\n")
  
  if (input$scenario_savings != 0 || input$scenario_wage != 0 || 
      input$scenario_inflation != 0 || input$scenario_borrow != 0) {
    cat("Scenario Adjustments Applied:\n")
    if (input$scenario_savings != 0) cat("  Savings Rate:", input$scenario_savings, "%\n")
    if (input$scenario_wage != 0) cat("  Wage Growth:", input$scenario_wage, "%\n")
    if (input$scenario_inflation != 0) cat("  Inflation:", input$scenario_inflation, "%\n")
    if (input$scenario_borrow != 0) cat("  Borrow Rate:", input$scenario_borrow, "%\n")
    cat("\n")
  }
  
  cat("Model Summary:\n")
  print(model$fit)
})
