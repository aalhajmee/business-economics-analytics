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
  scenario_adj <- switch(scenario,
    "baseline" = 0,
    "growth" = 2,      # +2 points (wages up, savings stable)
    "decline" = -2,    # -2 points (wages down, costs up)
    "inflation" = -1.5, # -1.5 points (purchasing power down)
    0
  )
  
  base_forecast$mean <- base_forecast$mean + scenario_adj
  base_forecast$lower <- base_forecast$lower + scenario_adj
  base_forecast$upper <- base_forecast$upper + scenario_adj
  
  base_forecast
}, ignoreNULL = FALSE)

output$forecast_plot <- renderPlotly({
  data <- forecast_data()
  fcast <- forecast_model()
  
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
  
  # Create plot
  plot_ly() %>%
    add_trace(
      data = historical_df,
      x = ~date,
      y = ~value,
      type = "scatter",
      mode = "lines",
      name = "Historical",
      line = list(color = "#1e40af", width = 2)
    ) %>%
    add_ribbons(
      data = forecast_df,
      x = ~date,
      ymin = ~lower95,
      ymax = ~upper95,
      name = "95% Confidence",
      fillcolor = "rgba(251, 146, 60, 0.15)",
      line = list(width = 0),
      showlegend = TRUE
    ) %>%
    add_ribbons(
      data = forecast_df,
      x = ~date,
      ymin = ~lower80,
      ymax = ~upper80,
      name = "80% Confidence",
      fillcolor = "rgba(251, 146, 60, 0.25)",
      line = list(width = 0),
      showlegend = TRUE
    ) %>%
    add_trace(
      data = forecast_df,
      x = ~date,
      y = ~value,
      type = "scatter",
      mode = "lines",
      name = "Forecast",
      line = list(color = "#fb923c", width = 3, dash = "dash")
    ) %>%
    layout(
      title = list(
        text = paste0("<b>CFHI Forecast: ", input$scenario_preset, " scenario</b>"),
        font = list(size = 18)
      ),
      xaxis = list(
        title = "Date",
        showgrid = TRUE,
        gridcolor = "#f0f0f0"
      ),
      yaxis = list(
        title = "CFHI Value",
        showgrid = TRUE,
        gridcolor = "#f0f0f0"
      ),
      hovermode = "x unified",
      plot_bgcolor = "#ffffff",
      paper_bgcolor = "#ffffff",
      legend = list(
        orientation = "h",
        x = 0.5,
        xanchor = "center",
        y = -0.2
      )
    )
})
