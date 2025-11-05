forecast_data <- reactive({
  df <- read_csv("data/cfhi/cfhi_master_2000_onward.csv", show_col_types = FALSE)
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
  
  # Set seed for reproducible bootstrap confidence intervals
  set.seed(54321)
  
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
  
  # Apply scenario adjustments as a TREND (not constant)
  scenario <- input$scenario_preset
  
  if (scenario == "custom") {
    # Custom scenario: use user inputs
    monthly_change <- (
      input$custom_savings * 0.25 +
      input$custom_wage * 0.25 +
      input$custom_inflation * -0.25 +
      input$custom_borrow * -0.25
    ) / 12  # Convert to monthly rate of change
  } else {
    # Preset scenarios - monthly change rate
    monthly_change <- switch(scenario,
      "baseline" = 0,
      "growth" = 2 / 12,      # +2 points over 12 months
      "decline" = -2 / 12,    # -2 points over 12 months
      "inflation" = -1.5 / 12, # -1.5 points over 12 months
      0
    )
  }
  
  # Apply cumulative trend adjustment
  if (monthly_change != 0) {
    trend_adjustment <- seq(monthly_change, monthly_change * horizon, by = monthly_change)
    base_forecast$mean <- base_forecast$mean + trend_adjustment
    base_forecast$lower <- base_forecast$lower + trend_adjustment
    base_forecast$upper <- base_forecast$upper + trend_adjustment
  }
  
  list(
    forecast = base_forecast,
    scenario = scenario,
    adjustment = monthly_change * horizon,  # Total adjustment over forecast period
    fit1 = fit1,  # ARIMA model
    fit2 = fit2,  # ETS model
    f1 = f1,      # ARIMA forecast
    f2 = f2       # ETS forecast
  )
}, ignoreNULL = FALSE)

# Model diagnostics and validation
model_diagnostics <- reactive({
  model <- forecast_model()
  data <- forecast_data()
  
  # Extract models
  arima_model <- model$fit1
  ets_model <- model$fit2
  
  # Model fit statistics
  arima_accuracy <- accuracy(arima_model)
  ets_accuracy <- accuracy(ets_model)
  
  # AIC/BIC comparison
  model_comparison <- data.frame(
    Model = c("ARIMA", "ETS"),
    AIC = c(AIC(arima_model), AIC(ets_model)),
    BIC = c(BIC(arima_model), BIC(ets_model)),
    RMSE = c(arima_accuracy[,"RMSE"], ets_accuracy[,"RMSE"]),
    MAE = c(arima_accuracy[,"MAE"], ets_accuracy[,"MAE"]),
    MAPE = c(arima_accuracy[,"MAPE"], ets_accuracy[,"MAPE"])
  )
  
  # Residual statistics
  arima_resid <- residuals(arima_model)
  ets_resid <- residuals(ets_model)
  
  list(
    comparison = model_comparison,
    arima_model = arima_model,
    ets_model = ets_model,
    arima_resid = arima_resid,
    ets_resid = ets_resid
  )
})

# Backtesting validation
backtest_results <- reactive({
  data <- forecast_data()
  full_ts <- data$ts
  
  # Use last 12 months as test set
  test_length <- 12
  train_length <- length(full_ts) - test_length
  
  train_ts <- window(full_ts, end = time(full_ts)[train_length])
  test_ts <- window(full_ts, start = time(full_ts)[train_length + 1])
  
  # Set seed for reproducibility
  set.seed(54321)
  
  # Fit models on training data
  arima_train <- auto.arima(train_ts)
  ets_train <- ets(train_ts)
  
  # Forecast test period
  arima_forecast <- forecast(arima_train, h = test_length)
  ets_forecast <- forecast(ets_train, h = test_length)
  ensemble_forecast <- (arima_forecast$mean + ets_forecast$mean) / 2
  
  # Calculate errors
  arima_errors <- as.numeric(test_ts) - as.numeric(arima_forecast$mean)
  ets_errors <- as.numeric(test_ts) - as.numeric(ets_forecast$mean)
  ensemble_errors <- as.numeric(test_ts) - as.numeric(ensemble_forecast)
  
  # Accuracy metrics
  accuracy_df <- data.frame(
    Model = c("ARIMA", "ETS", "Ensemble"),
    RMSE = c(
      sqrt(mean(arima_errors^2)),
      sqrt(mean(ets_errors^2)),
      sqrt(mean(ensemble_errors^2))
    ),
    MAE = c(
      mean(abs(arima_errors)),
      mean(abs(ets_errors)),
      mean(abs(ensemble_errors))
    ),
    MAPE = c(
      mean(abs(arima_errors / as.numeric(test_ts))) * 100,
      mean(abs(ets_errors / as.numeric(test_ts))) * 100,
      mean(abs(ensemble_errors / as.numeric(test_ts))) * 100
    )
  )
  
  list(
    accuracy = accuracy_df,
    actual = as.numeric(test_ts),
    arima_pred = as.numeric(arima_forecast$mean),
    ets_pred = as.numeric(ets_forecast$mean),
    ensemble_pred = as.numeric(ensemble_forecast),
    test_dates = time(test_ts)
  )
})

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
  
  # Show only last 5 years of historical data for better forecast visibility
  lookback_date <- data$latest_date - years(5)
  
  # Historical data (limited to last 5 years)
  historical_df <- data$df %>%
    filter(date >= lookback_date) %>%
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

# Model comparison table
output$model_comparison_table <- renderDT({
  diagnostics <- model_diagnostics()
  
  datatable(
    diagnostics$comparison,
    options = list(
      dom = 't',
      pageLength = 10,
      ordering = FALSE
    ),
    rownames = FALSE
  ) %>%
    formatRound(columns = c('AIC', 'BIC', 'RMSE', 'MAE', 'MAPE'), digits = 2) %>%
    formatStyle(
      'RMSE',
      background = styleColorBar(range(diagnostics$comparison$RMSE), 'lightblue'),
      backgroundSize = '100% 90%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center'
    )
})

# Backtesting accuracy table
output$backtest_accuracy_table <- renderDT({
  backtest <- backtest_results()
  
  datatable(
    backtest$accuracy,
    options = list(
      dom = 't',
      pageLength = 10,
      ordering = FALSE
    ),
    rownames = FALSE
  ) %>%
    formatRound(columns = c('RMSE', 'MAE', 'MAPE'), digits = 2) %>%
    formatStyle(
      'RMSE',
      background = styleColorBar(range(backtest$accuracy$RMSE), 'lightgreen'),
      backgroundSize = '100% 90%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center'
    )
})

# Backtest visualization
output$backtest_plot <- renderPlotly({
  backtest <- backtest_results()
  
  # Convert time index to dates
  test_dates <- as.Date(paste0(floor(backtest$test_dates), "-", 
                                round((backtest$test_dates %% 1) * 12) + 1, "-01"))
  
  plot_ly() %>%
    add_trace(
      x = test_dates,
      y = backtest$actual,
      type = "scatter",
      mode = "lines+markers",
      name = "Actual",
      line = list(color = "#1e40af", width = 2),
      marker = list(size = 6)
    ) %>%
    add_trace(
      x = test_dates,
      y = backtest$arima_pred,
      type = "scatter",
      mode = "lines",
      name = "ARIMA",
      line = list(color = "#dc2626", width = 1.5, dash = "dot")
    ) %>%
    add_trace(
      x = test_dates,
      y = backtest$ets_pred,
      type = "scatter",
      mode = "lines",
      name = "ETS",
      line = list(color = "#16a34a", width = 1.5, dash = "dash")
    ) %>%
    add_trace(
      x = test_dates,
      y = backtest$ensemble_pred,
      type = "scatter",
      mode = "lines",
      name = "Ensemble",
      line = list(color = "#fb923c", width = 2.5)
    ) %>%
    layout(
      title = "Out-of-Sample Forecast Validation (Last 12 Months)",
      xaxis = list(title = "Date"),
      yaxis = list(title = "CFHI"),
      hovermode = "x unified",
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2)
    )
})

# Residual diagnostics plot
output$residual_diagnostics <- renderPlotly({
  diagnostics <- model_diagnostics()
  
  # Combine residuals for comparison
  arima_resid <- as.numeric(diagnostics$arima_resid)
  ets_resid <- as.numeric(diagnostics$ets_resid)
  
  plot_ly() %>%
    add_trace(
      x = arima_resid,
      type = "histogram",
      name = "ARIMA Residuals",
      opacity = 0.6,
      marker = list(color = "#dc2626")
    ) %>%
    add_trace(
      x = ets_resid,
      type = "histogram",
      name = "ETS Residuals",
      opacity = 0.6,
      marker = list(color = "#16a34a")
    ) %>%
    layout(
      title = "Residual Distribution",
      xaxis = list(title = "Residual Value"),
      yaxis = list(title = "Frequency"),
      barmode = "overlay",
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2)
    )
})

# ACF plot for ARIMA residuals
output$arima_acf_plot <- renderPlot({
  diagnostics <- model_diagnostics()
  
  par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))
  
  # ACF
  acf(diagnostics$arima_resid, main = "ACF of ARIMA Residuals", na.action = na.pass)
  
  # PACF
  pacf(diagnostics$arima_resid, main = "PACF of ARIMA Residuals", na.action = na.pass)
})

# Q-Q plot for ARIMA residuals
output$arima_qq_plot <- renderPlot({
  diagnostics <- model_diagnostics()
  
  par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))
  
  # Q-Q plot for ARIMA
  qqnorm(diagnostics$arima_resid, main = "Q-Q Plot: ARIMA Residuals")
  qqline(diagnostics$arima_resid, col = "red", lwd = 2)
  
  # Q-Q plot for ETS
  qqnorm(diagnostics$ets_resid, main = "Q-Q Plot: ETS Residuals")
  qqline(diagnostics$ets_resid, col = "red", lwd = 2)
})

# Download forecast data
output$download_forecast_data <- downloadHandler(
  filename = function() {
    paste0("CFHI_forecast_", format(Sys.Date(), "%Y%m%d"), ".csv")
  },
  content = function(file) {
    data <- forecast_data()
    model <- forecast_model()
    fcast <- model$forecast
    
    horizon <- as.numeric(input$forecast_months)
    future_dates <- seq.Date(
      from = data$latest_date + months(1),
      by = "month",
      length.out = horizon
    )
    
    # Create export dataframe
    export_df <- data.frame(
      date = future_dates,
      forecast_mean = as.numeric(fcast$mean),
      lower_80 = as.numeric(fcast$lower[,1]),
      upper_80 = as.numeric(fcast$upper[,1]),
      lower_95 = as.numeric(fcast$lower[,2]),
      upper_95 = as.numeric(fcast$upper[,2]),
      scenario = model$scenario
    )
    
    write.csv(export_df, file, row.names = FALSE)
  }
)
