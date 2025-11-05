# ===============================================================================
# MARKET CORRELATION SERVER LOGIC
# ===============================================================================

# Load and merge data
market_data <- reactive({
  # Load CFHI data
  cfhi <- read_csv("cfhi_data/cfhi_master_2000_onward.csv", show_col_types = FALSE) %>%
    select(date, CFHI) %>%
    filter(!is.na(CFHI))
  
  # Load S&P 500 data
  sp500 <- read_excel("cfhi_data/SP500_PriceHistory_Monthly_042006_082025_FactSet.xlsx", sheet = 1) %>%
    select(Date, Price, `% Change`) %>%
    rename(date = Date, sp500_price = Price, sp500_change = `% Change`) %>%
    mutate(date = as.Date(date))
  
  # Merge datasets
  merged <- inner_join(cfhi, sp500, by = "date") %>%
    arrange(date) %>%
    filter(!is.na(CFHI), !is.na(sp500_price))
  
  # Apply date range filter
  date_range <- input$market_date_range
  
  if (date_range == "custom") {
    merged <- merged %>%
      filter(date >= input$market_start_date, date <= input$market_end_date)
  } else if (date_range != "full") {
    years_back <- as.numeric(gsub("yr", "", date_range))
    cutoff_date <- max(merged$date) - years(years_back)
    merged <- merged %>%
      filter(date >= cutoff_date)
  }
  
  merged
})

# Calculate correlation statistics
correlation_stats <- reactive({
  data <- market_data()
  
  if (nrow(data) < 3) {
    return(list(
      correlation = NA,
      p_value = NA,
      r_squared = NA,
      n = nrow(data),
      model = NULL
    ))
  }
  
  method <- input$correlation_method
  cor_test <- cor.test(data$CFHI, data$sp500_price, method = method)
  
  # Linear regression model
  model <- lm(CFHI ~ sp500_price, data = data)
  r_squared <- summary(model)$r.squared
  
  list(
    correlation = cor_test$estimate,
    p_value = cor_test$p.value,
    r_squared = r_squared,
    n = nrow(data),
    model = model,
    method = method
  )
})

# Value boxes
output$correlation_coef <- renderValueBox({
  stats <- correlation_stats()
  
  if (is.na(stats$correlation)) {
    valueBox(
      "N/A",
      "Correlation Coefficient",
      icon = icon("chart-line"),
      color = "light-blue"
    )
  } else {
    cor_val <- round(stats$correlation, 3)
    color <- if (abs(cor_val) > 0.7) "green" else if (abs(cor_val) > 0.4) "yellow" else "red"
    
    valueBox(
      cor_val,
      paste(tools::toTitleCase(stats$method), "Correlation"),
      icon = icon("chart-line"),
      color = color
    )
  }
})

output$r_squared <- renderValueBox({
  stats <- correlation_stats()
  
  if (is.na(stats$r_squared)) {
    valueBox(
      "N/A",
      "R-Squared",
      icon = icon("percent"),
      color = "light-blue"
    )
  } else {
    r2_val <- round(stats$r_squared, 3)
    color <- if (r2_val > 0.5) "green" else if (r2_val > 0.25) "yellow" else "orange"
    
    valueBox(
      r2_val,
      "R² (Variance Explained)",
      icon = icon("percent"),
      color = color
    )
  }
})

output$p_value <- renderValueBox({
  stats <- correlation_stats()
  
  if (is.na(stats$p_value)) {
    valueBox(
      "N/A",
      "P-Value",
      icon = icon("calculator"),
      color = "light-blue"
    )
  } else {
    p_val <- stats$p_value
    p_display <- if (p_val < 0.001) "< 0.001" else sprintf("%.4f", p_val)
    color <- if (p_val < 0.05) "green" else "red"
    
    valueBox(
      p_display,
      "Statistical Significance",
      icon = icon("calculator"),
      color = color
    )
  }
})

output$data_points <- renderValueBox({
  stats <- correlation_stats()
  
  valueBox(
    stats$n,
    "Data Points (Months)",
    icon = icon("database"),
    color = "blue"
  )
})

# Dual-axis time series plot
output$dual_axis_plot <- renderPlotly({
  data <- market_data()
  
  if (nrow(data) == 0) {
    return(plotly_empty())
  }
  
  # Normalize both series to 0-100 scale for better visual comparison
  cfhi_norm <- (data$CFHI - min(data$CFHI)) / (max(data$CFHI) - min(data$CFHI)) * 100
  sp500_norm <- (data$sp500_price - min(data$sp500_price)) / (max(data$sp500_price) - min(data$sp500_price)) * 100
  
  plot_ly(data) %>%
    add_trace(
      x = ~date,
      y = cfhi_norm,
      type = "scatter",
      mode = "lines",
      name = "CFHI (Normalized)",
      line = list(color = "#1e40af", width = 2.5),
      yaxis = "y1",
      hovertemplate = "Date: %{x}<br>CFHI: %{text:.2f}<extra></extra>",
      text = data$CFHI
    ) %>%
    add_trace(
      x = ~date,
      y = sp500_norm,
      type = "scatter",
      mode = "lines",
      name = "S&P 500 (Normalized)",
      line = list(color = "#16a34a", width = 2.5),
      yaxis = "y1",
      hovertemplate = "Date: %{x}<br>S&P 500: %{text:.2f}<extra></extra>",
      text = data$sp500_price
    ) %>%
    layout(
      title = list(
        text = "<b>CFHI vs S&P 500 Over Time</b> (Both Normalized to 0-100)",
        font = list(size = 16)
      ),
      xaxis = list(
        title = "Date",
        showgrid = TRUE,
        gridcolor = "#e5e5e5"
      ),
      yaxis = list(
        title = "Normalized Value (0-100)",
        showgrid = TRUE,
        gridcolor = "#e5e5e5",
        range = c(0, 100)
      ),
      hovermode = "x unified",
      plot_bgcolor = "#ffffff",
      paper_bgcolor = "#ffffff",
      legend = list(
        orientation = "h",
        x = 0.5,
        xanchor = "center",
        y = -0.15
      )
    )
})

# Scatter plot with regression line
output$scatter_regression_plot <- renderPlotly({
  data <- market_data()
  stats <- correlation_stats()
  
  if (nrow(data) < 3 || is.null(stats$model)) {
    return(plotly_empty())
  }
  
  # Get regression line predictions
  data$predicted <- predict(stats$model, data)
  
  plot_ly(data) %>%
    add_trace(
      x = ~sp500_price,
      y = ~CFHI,
      type = "scatter",
      mode = "markers",
      name = "Observations",
      marker = list(
        color = "#3b82f6",
        size = 6,
        opacity = 0.6
      ),
      hovertemplate = "S&P 500: %{x:.2f}<br>CFHI: %{y:.2f}<extra></extra>"
    ) %>%
    add_trace(
      x = ~sp500_price,
      y = ~predicted,
      type = "scatter",
      mode = "lines",
      name = "Regression Line",
      line = list(color = "#dc2626", width = 3),
      hovertemplate = "Predicted CFHI: %{y:.2f}<extra></extra>"
    ) %>%
    layout(
      title = list(
        text = sprintf("<b>Linear Regression</b> (R² = %.3f)", stats$r_squared),
        font = list(size = 14)
      ),
      xaxis = list(
        title = "S&P 500 Price",
        showgrid = TRUE,
        gridcolor = "#e5e5e5"
      ),
      yaxis = list(
        title = "CFHI Value",
        showgrid = TRUE,
        gridcolor = "#e5e5e5"
      ),
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

# Rolling correlation plot
output$rolling_correlation_plot <- renderPlotly({
  data <- market_data()
  
  if (nrow(data) < 24) {  # Need at least 24 months for 12-month rolling
    return(plotly_empty())
  }
  
  method <- input$correlation_method
  
  # Calculate 12-month rolling correlation
  rolling_cor <- data.frame(
    date = data$date[-(1:11)],
    correlation = sapply(12:nrow(data), function(i) {
      window <- data[(i-11):i, ]
      cor(window$CFHI, window$sp500_price, method = method)
    })
  )
  
  plot_ly(rolling_cor) %>%
    add_trace(
      x = ~date,
      y = ~correlation,
      type = "scatter",
      mode = "lines",
      name = "Rolling Correlation",
      line = list(color = "#8b5cf6", width = 2.5),
      fill = "tozeroy",
      fillcolor = "rgba(139, 92, 246, 0.2)",
      hovertemplate = "Date: %{x}<br>Correlation: %{y:.3f}<extra></extra>"
    ) %>%
    add_trace(
      x = rolling_cor$date,
      y = rep(0, nrow(rolling_cor)),
      type = "scatter",
      mode = "lines",
      name = "Zero Line",
      line = list(color = "#000000", width = 1, dash = "dash"),
      showlegend = FALSE,
      hoverinfo = "skip"
    ) %>%
    layout(
      title = list(
        text = "<b>12-Month Rolling Correlation</b>",
        font = list(size = 14)
      ),
      xaxis = list(
        title = "Date",
        showgrid = TRUE,
        gridcolor = "#e5e5e5"
      ),
      yaxis = list(
        title = paste(tools::toTitleCase(method), "Correlation"),
        showgrid = TRUE,
        gridcolor = "#e5e5e5",
        range = c(-1, 1)
      ),
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

# Regression model summary
output$regression_summary <- renderPrint({
  stats <- correlation_stats()
  
  if (is.null(stats$model)) {
    cat("Insufficient data for regression analysis.\nPlease select a longer date range.")
  } else {
    summary(stats$model)
  }
})

# Key insights
output$correlation_insights <- renderUI({
  stats <- correlation_stats()
  data <- market_data()
  
  if (is.na(stats$correlation)) {
    return(HTML("<p style='color: #64748b;'>Insufficient data for analysis. Please adjust date range.</p>"))
  }
  
  cor_val <- stats$correlation
  p_val <- stats$p_value
  r2_val <- stats$r_squared
  
  # Interpret correlation strength
  cor_strength <- if (abs(cor_val) > 0.7) {
    "strong"
  } else if (abs(cor_val) > 0.4) {
    "moderate"
  } else {
    "weak"
  }
  
  cor_direction <- if (cor_val > 0) "positive" else "negative"
  
  # Statistical significance
  is_significant <- p_val < 0.05
  sig_text <- if (is_significant) {
    "<span style='color: #16a34a; font-weight: 600;'>statistically significant</span>"
  } else {
    "<span style='color: #dc2626; font-weight: 600;'>not statistically significant</span>"
  }
  
  # Calculate percent of variance explained
  variance_pct <- round(r2_val * 100, 1)
  
  # Recent trend (last 12 months)
  recent_data <- tail(data, 12)
  recent_cor <- cor(recent_data$CFHI, recent_data$sp500_price, method = stats$method)
  recent_change <- if (abs(recent_cor - cor_val) > 0.1) {
    if (recent_cor > cor_val) "strengthened" else "weakened"
  } else {
    "remained stable"
  }
  
  insights_html <- paste0(
    "<div style='padding: 15px; line-height: 1.8;'>",
    "<h4 style='margin-top: 0; color: #1e293b;'>Analysis Summary</h4>",
    "<ul style='color: #475569; font-size: 14px;'>",
    "<li>The analysis reveals a <b>", cor_strength, " ", cor_direction, " correlation</b> ",
    "(r = ", round(cor_val, 3), ") between CFHI and S&P 500 over this period.</li>",
    "<li>This relationship is ", sig_text, " (p = ", 
    if (p_val < 0.001) "< 0.001" else round(p_val, 4), ").</li>",
    "<li>The S&P 500 explains approximately <b>", variance_pct, "%</b> of the variance in CFHI values.</li>",
    "<li>Over the past 12 months, the correlation has <b>", recent_change, "</b> ",
    "(recent r = ", round(recent_cor, 3), ").</li>",
    "</ul>",
    "<h4 style='color: #1e293b; margin-bottom: 10px;'>Interpretation</h4>",
    "<p style='color: #475569; font-size: 14px; margin: 0;'>",
    if (cor_val > 0.5) {
      "Strong positive correlation suggests that household financial health tends to improve when stock markets perform well, likely due to wealth effects, retirement account values, and consumer confidence."
    } else if (cor_val > 0) {
      "Moderate positive correlation indicates some linkage between market performance and household finances, though other factors also play significant roles in financial health outcomes."
    } else if (cor_val < -0.3) {
      "Negative correlation suggests an inverse relationship, which may indicate periods where market gains did not translate to broad household financial improvements, possibly due to income inequality or economic conditions."
    } else {
      "Weak correlation suggests that stock market movements have limited direct impact on overall household financial health, highlighting the importance of wage growth, savings rates, and inflation control."
    },
    "</p>",
    "</div>"
  )
  
  HTML(insights_html)
})
