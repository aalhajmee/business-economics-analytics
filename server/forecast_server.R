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
  horizon <- as.numeric(input$forecast_months)
  
  # Use ensemble method (average of ARIMA and ETS) for robustness
  fit1 <- auto.arima(data$ts)
  fit2 <- ets(data$ts)
  f1 <- forecast(fit1, h = horizon)
  f2 <- forecast(fit2, h = horizon)
  
  # Average the forecasts
  base_forecast <- f1
  base_forecast$mean <- (f1$mean + f2$mean) / 2
  base_forecast$lower <- (f1$lower + f2$lower) / 2
  base_forecast$upper <- (f1$upper + f2$upper) / 2
  
  # Apply scenario adjustments
  scenario <- input$scenario_preset
  
  if (scenario == "custom") {
    # Custom scenario: use user inputs
    scenario_adj <- (
      input$custom_savings * 0.25 +
      input$custom_wage * 0.25 +
      input$custom_inflation * -0.25 +
      input$custom_borrow * -0.25
    )
  } else {
    # Preset scenarios
    scenario_adj <- switch(scenario,
      "baseline" = 0,
      "growth" = 2,      # +2 points (wages up, savings stable)
      "decline" = -2,    # -2 points (wages down, costs up)
      "inflation" = -1.5, # -1.5 points (purchasing power down)
      0
    )
  }
  
  base_forecast$mean <- base_forecast$mean + scenario_adj
  base_forecast$lower <- base_forecast$lower + scenario_adj
  base_forecast$upper <- base_forecast$upper + scenario_adj
  
  list(
    forecast = base_forecast,
    scenario = scenario,
    adjustment = scenario_adj
  )
}, ignoreNULL = FALSE)

output$forecast_plot <- renderPlotly({
  data <- forecast_data()
  model <- forecast_model()
  fcast <- model$forecast
  
  horizon <- as.numeric(input$forecast_months)
  future_dates <- seq.Date(
    from = data$latest_date + months(1),
    by = "month",
    length.out = horizon
  )
  
  # Historical data
  historical_df <- data$df %>%
    select(date, CFHI) %>%
    rename(value = CFHI)
  
  # Forecast data
  forecast_df <- data.frame(
    date = future_dates,
    value = as.numeric(fcast$mean),
    lower80 = as.numeric(fcast$lower[,1]),
    upper80 = as.numeric(fcast$upper[,1]),
    lower95 = as.numeric(fcast$lower[,2]),
    upper95 = as.numeric(fcast$upper[,2])
  )
  
  # Determine title based on scenario
  scenario_name <- if (model$scenario == "custom") {
    "Custom Scenario"
  } else {
    switch(model$scenario,
      "baseline" = "Current Trends",
      "growth" = "Economic Growth",
      "decline" = "Economic Decline",
      "inflation" = "High Inflation",
      "Current Trends"
    )
  }
  
  # Create plot
  plot_ly() %>%
    add_trace(
      data = historical_df,
      x = ~date,
      y = ~value,
      type = "scatter",
      mode = "lines",
      name = "Historical",
      line = list(color = "#1e40af", width = 2.5),
      hovertemplate = "Date: %{x}<br>CFHI: %{y:.2f}<extra></extra>"
    ) %>%
    add_ribbons(
      data = forecast_df,
      x = ~date,
      ymin = ~lower95,
      ymax = ~upper95,
      name = "95% Confidence",
      fillcolor = "rgba(251, 146, 60, 0.12)",
      line = list(width = 0),
      showlegend = TRUE,
      hoverinfo = "skip"
    ) %>%
    add_ribbons(
      data = forecast_df,
      x = ~date,
      ymin = ~lower80,
      ymax = ~upper80,
      name = "80% Confidence",
      fillcolor = "rgba(251, 146, 60, 0.25)",
      line = list(width = 0),
      showlegend = TRUE,
      hoverinfo = "skip"
    ) %>%
    add_trace(
      data = forecast_df,
      x = ~date,
      y = ~value,
      type = "scatter",
      mode = "lines",
      name = "Forecast",
      line = list(color = "#fb923c", width = 3, dash = "dash"),
      hovertemplate = "Date: %{x}<br>Forecast: %{y:.2f}<extra></extra>"
    ) %>%
    layout(
      title = list(
        text = paste0("<b>", scenario_name, "</b> - ", horizon, " Month Forecast"),
        font = list(size = 16)
      ),
      xaxis = list(
        title = "Date",
        showgrid = TRUE,
        gridcolor = "#e5e5e5"
      ),
      yaxis = list(
        title = "CFHI Value",
        showgrid = TRUE,
        gridcolor = "#e5e5e5"
      ),
      hovermode = "x unified",
      plot_bgcolor = "#ffffff",
      paper_bgcolor = "#ffffff",
      legend = list(
        orientation = "h",
        x = 0.5,
        xanchor = "center",
        y = -0.15
      ),
      margin = list(t = 50, b = 60, l = 60, r = 20)
    )
})
