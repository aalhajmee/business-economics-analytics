# ===============================================================================
# MARKET CORRELATION SERVER LOGIC
# ===============================================================================

# Min-max scaling function with fixed range
scale01 <- function(x, min_val = NULL, max_val = NULL) {
  if (is.null(min_val) || is.null(max_val)) {
    rng <- range(x, na.rm = TRUE)
    min_val <- rng[1]
    max_val <- rng[2]
  }
  if (!is.finite(min_val) || !is.finite(max_val)) return(rep(NA_real_, length(x)))
  if (max_val - min_val == 0) return(rep(0.5, length(x)))
  (x - min_val) / (max_val - min_val)
}

# Load and merge data with consistent CFHI calculation
market_data <- reactive({
  req(input$market_date_range)
  
  tryCatch({
    # Load CFHI data directly from pre-processed CSV
    # CSV already contains correct CFHI calculation: (S* + W* + I* + R*) / 4
    # where each component is normalized 0-100 using full dataset
    cfhi <- read_csv("data/cfhi/cfhi_master_2000_onward.csv", show_col_types = FALSE) %>%
      mutate(date = floor_date(as.Date(date), "month")) %>%
      select(date, CFHI) %>%
      distinct(date, .keep_all = TRUE) %>%
      arrange(date) %>%
      filter(!is.na(CFHI))
    
    # Load S&P 500 data
    sp500 <- read_excel("data/market/SP500_PriceHistory_Monthly_042006_082025_FactSet.xlsx", sheet = 1) %>%
      select(Date, Price, `% Change`) %>%
      rename(date = Date, sp500_price = Price, sp500_change = `% Change`) %>%
      mutate(date = floor_date(as.Date(date), "month"))
    
    # Merge datasets
    merged <- inner_join(cfhi, sp500, by = "date") %>%
      arrange(date) %>%
      filter(!is.na(CFHI), !is.na(sp500_price)) %>%
      distinct(date, .keep_all = TRUE)
    
    # Apply date range filter AFTER calculating CFHI with full dataset normalization
    date_range <- input$market_date_range
    
    if (date_range == "custom") {
      merged <- merged %>%
        filter(date >= as.Date(input$market_start_date), date <= as.Date(input$market_end_date))
    } else if (date_range != "full") {
      years_back <- as.numeric(gsub("yr", "", date_range))
      cutoff_date <- max(merged$date) - lubridate::years(years_back)
      merged <- merged %>%
        filter(date >= cutoff_date)
    }
    
    merged
  }, error = function(e) {
    data.frame(date = as.Date(character()), CFHI = numeric(), sp500_price = numeric(), sp500_change = numeric())
  })
})

# Load FULL dataset for correlation (not filtered by date range)
full_market_data <- reactive({
  tryCatch({
    # Load CFHI data directly from pre-processed CSV
    # CSV already contains correct CFHI calculation and all components
    cfhi <- read_csv("data/cfhi/cfhi_master_2000_onward.csv", show_col_types = FALSE) %>%
      mutate(date = floor_date(as.Date(date), "month")) %>%
      select(date, CFHI, savings_rate, wage_yoy, inflation_yoy, borrow_rate) %>%
      distinct(date, .keep_all = TRUE) %>%
      arrange(date) %>%
      filter(!is.na(CFHI))
    
    # Load S&P 500 data
    sp500 <- read_excel("data/market/SP500_PriceHistory_Monthly_042006_082025_FactSet.xlsx", sheet = 1) %>%
      select(Date, Price, `% Change`) %>%
      rename(date = Date, sp500_price = Price, sp500_change = `% Change`) %>%
      mutate(date = floor_date(as.Date(date), "month"))
    
    # Merge datasets - NO DATE FILTERING for full correlation
    # Keep CFHI components and Fed Funds Rate for advanced analysis
    merged <- inner_join(cfhi, sp500, by = "date") %>%
      arrange(date) %>%
      filter(!is.na(CFHI), !is.na(sp500_price)) %>%
      distinct(date, .keep_all = TRUE)
    
    merged
  }, error = function(e) {
    data.frame(date = as.Date(character()), CFHI = numeric(), sp500_price = numeric(), 
               sp500_change = numeric(), borrow_rate = numeric())
  })
})

# Calculate correlation statistics with hypothesis testing - ALWAYS uses FULL dataset
correlation_stats <- reactive({
  data <- full_market_data()
  
  if (nrow(data) < 3) {
    return(list(
      correlation = NA,
      p_value = NA,
      r_squared = NA,
      n = nrow(data),
      model = NULL,
      conf_int = c(NA, NA),
      effect_size = NA,
      hypothesis_result = "Insufficient data",
      partial_cor = NA,
      partial_p = NA,
      component_cors = list()
    ))
  }
  
  # 1. NAIVE CORRELATION (what we've been doing - wrong!)
  method <- "pearson"
  cor_test <- cor.test(data$CFHI, data$sp500_price, method = method)
  
  # Linear regression model
  model <- lm(CFHI ~ sp500_price, data = data)
  r_squared <- summary(model)$r.squared
  
  # Calculate confidence interval for correlation
  conf_int <- cor_test$conf.int
  
  # Cohen's interpretation of effect size (for Pearson r)
  r_val <- abs(cor_test$estimate)
  effect_size <- if (r_val >= 0.5) {
    "Large"
  } else if (r_val >= 0.3) {
    "Medium"
  } else if (r_val >= 0.1) {
    "Small"
  } else {
    "Negligible"
  }
  
  # Hypothesis test interpretation (α = 0.05)
  alpha <- 0.05
  hypothesis_result <- if (cor_test$p.value < alpha) {
    paste0("REJECT H₀ (p = ", sprintf("%.4f", cor_test$p.value), " < ", alpha, 
           "): Significant correlation exists between CFHI and S&P 500.")
  } else {
    paste0("FAIL TO REJECT H₀ (p = ", sprintf("%.4f", cor_test$p.value), " ≥ ", alpha, 
           "): No significant correlation detected.")
  }
  
  # 2. PARTIAL CORRELATION - Control for Fed Funds Rate (BETTER!)
  partial_cor <- NA
  partial_p <- NA
  partial_test <- tryCatch({
    # Manual partial correlation calculation
    # Residualize both variables by Fed Funds Rate
    cfhi_resid <- residuals(lm(CFHI ~ borrow_rate, data = data))
    sp500_resid <- residuals(lm(sp500_price ~ borrow_rate, data = data))
    cor.test(cfhi_resid, sp500_resid, method = "pearson")
  }, error = function(e) NULL)
  
  if (!is.null(partial_test)) {
    partial_cor <- partial_test$estimate
    partial_p <- partial_test$p.value
  }
  
  # 3. COMPONENT-WISE CORRELATIONS - Which components drive the negative correlation?
  component_cors <- list()
  
  # Test each CFHI component against S&P 500
  tryCatch({
    # Savings rate component (S*) - expect positive
    savings_test <- cor.test(data$S_star, data$sp500_price, method = "pearson")
    component_cors$savings <- list(
      name = "Savings Rate (S*)",
      r = savings_test$estimate,
      p = savings_test$p.value,
      direction = "Non-inverted"
    )
    
    # Wage growth component (W*) - expect positive
    wage_test <- cor.test(data$W_star, data$sp500_price, method = "pearson")
    component_cors$wages <- list(
      name = "Wage Growth (W*)",
      r = wage_test$estimate,
      p = wage_test$p.value,
      direction = "Non-inverted"
    )
    
    # Inflation component (I*) - INVERTED, expect negative (artifact)
    inflation_test <- cor.test(data$I_star, data$sp500_price, method = "pearson")
    component_cors$inflation <- list(
      name = "Inflation (I*)",
      r = inflation_test$estimate,
      p = inflation_test$p.value,
      direction = "Inverted"
    )
    
    # Interest rate component (R*) - INVERTED, expect negative (artifact)
    rate_test <- cor.test(data$R_star, data$sp500_price, method = "pearson")
    component_cors$rates <- list(
      name = "Interest Rates (R*)",
      r = rate_test$estimate,
      p = rate_test$p.value,
      direction = "Inverted"
    )
  }, error = function(e) {
    component_cors <- list()
  })
  
  # 4. BETTER HYPOTHESIS TEST - Multiple regression controlling for Fed policy
  better_model <- tryCatch({
    lm(CFHI ~ sp500_price + borrow_rate, data = data)
  }, error = function(e) NULL)
  
  list(
    # Naive correlation (misleading)
    correlation = cor_test$estimate,
    p_value = cor_test$p.value,
    r_squared = r_squared,
    n = nrow(data),
    model = model,
    method = method,
    conf_int = conf_int,
    effect_size = effect_size,
    hypothesis_result = hypothesis_result,
    test_statistic = cor_test$statistic,
    cor_test = cor_test,
    
    # Advanced analysis (revealing truth)
    partial_cor = partial_cor,
    partial_p = partial_p,
    component_cors = component_cors,
    better_model = better_model
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

# Dual-axis time series plot with REAL VALUES
output$dual_axis_plot <- renderPlotly({
  data <- market_data()
  
  if (nrow(data) == 0) {
    return(plotly_empty())
  }
  
  # Use REAL values (not indexed) to show true magnitude differences
  # This makes the negative correlation visually obvious
  plot_ly() %>%
    # S&P 500 on primary y-axis (left) - Blue
    add_trace(
      x = data$date,
      y = data$sp500_price,
      name = "S&P 500 (Real Values)",
      type = "scatter",
      mode = "lines",
      line = list(color = "#1e40af", width = 2.5),
      yaxis = "y",
      hovertemplate = "<b>S&P 500</b><br>Date: %{x}<br>Price: %{y:.2f}<extra></extra>"
    ) %>%
    # CFHI on secondary y-axis (right) - Red
    add_trace(
      x = data$date,
      y = data$CFHI,
      name = "CFHI (Real Values)",
      type = "scatter",
      mode = "lines",
      line = list(color = "#dc2626", width = 2.5),
      yaxis = "y2",
      hovertemplate = "<b>CFHI</b><br>Date: %{x}<br>Value: %{y:.2f}<extra></extra>"
    ) %>%
    layout(
      title = list(
        text = "<b>S&P 500 vs CFHI: Real Values (Dual Axis)</b><br><sub>Reveals why correlation is negative: divergent movements</sub>",
        font = list(size = 16)
      ),
      xaxis = list(
        title = "Date",
        showgrid = TRUE,
        gridcolor = "#e5e5e5"
      ),
      # Primary y-axis (left) for S&P 500
      yaxis = list(
        title = list(
          text = "<b>S&P 500 Index</b>",
          font = list(color = "#1e40af", size = 14)
        ),
        tickfont = list(color = "#1e40af"),
        showgrid = FALSE,
        side = "left",
        rangemode = "tozero"
      ),
      # Secondary y-axis (right) for CFHI
      yaxis2 = list(
        title = list(
          text = "<b>CFHI Value</b>",
          font = list(color = "#dc2626", size = 14)
        ),
        tickfont = list(color = "#dc2626"),
        overlaying = "y",
        side = "right",
        showgrid = TRUE,
        gridcolor = "#fee2e2",
        rangemode = "tozero"
      ),
      hovermode = "x unified",
      plot_bgcolor = "#ffffff",
      paper_bgcolor = "#ffffff",
      legend = list(
        orientation = "h",
        x = 0.5,
        xanchor = "center",
        y = -0.15,
        bgcolor = "rgba(255, 255, 255, 0.8)"
      ),
      annotations = list(
        list(
          text = "<b>Visual Insight:</b> When blue (S&P 500) climbs during bull markets,<br>red (CFHI) often declines due to Fed rate hikes → negative correlation",
          xref = "paper",
          yref = "paper",
          x = 0.5,
          y = -0.25,
          xanchor = "center",
          yanchor = "top",
          showarrow = FALSE,
          font = list(size = 11, color = "#64748b"),
          bgcolor = "#fef3c7",
          bordercolor = "#f59e0b",
          borderwidth = 1,
          borderpad = 8
        )
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
  
  # Use Pearson correlation method
  method <- "pearson"
  
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

# Key insights with formal hypothesis testing
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
  
  # Check for direction reversal
  direction_changed <- (cor_val > 0 && recent_cor < 0) || (cor_val < 0 && recent_cor > 0)
  
  recent_change <- if (direction_changed) {
    "reversed direction"
  } else if (abs(recent_cor - cor_val) > 0.1) {
    if (abs(recent_cor) > abs(cor_val)) "strengthened" else "weakened"
  } else {
    "remained stable"
  }
  
  # Confidence interval display
  ci_text <- if (!is.na(stats$conf_int[1])) {
    paste0("[", round(stats$conf_int[1], 3), ", ", round(stats$conf_int[2], 3), "]")
  } else {
    "N/A for Spearman"
  }
  
  # Simple summary for non-technical users (fixed logic)
  simple_summary <- if (is_significant) {
    if (cor_val > 0) {
      paste0("A ", cor_strength, " positive correlation (r = ", round(cor_val, 3), ") indicates that ",
             "when S&P 500 increases, CFHI tends to increase as well. ",
             "The relationship explains ", variance_pct, "% of CFHI variation.")
    } else {
      paste0("A ", cor_strength, " negative correlation (r = ", round(cor_val, 3), ") indicates that ",
             "when S&P 500 increases, CFHI tends to decrease. ",
             "This inverse relationship explains ", variance_pct, "% of CFHI variation.")
    }
  } else {
    paste0("No statistically significant correlation was detected (p = ", round(p_val, 4), "). ",
           "S&P 500 and CFHI appear to move independently during this period.")
  }
  
  # Create simple, clean interpretation
  if (!is.null(stats$better_model)) {
    model_summary <- summary(stats$better_model)
    sp500_coef <- coef(model_summary)["sp500_price", ]
    
    insights_html <- paste0(
      "<div style='padding: 15px; line-height: 1.8;'>",
      
      # Summary Finding
      "<div style='background: #f0fdf4; border-left: 4px solid #16a34a; padding: 15px; margin-bottom: 15px; border-radius: 4px;'>",
      "<h4 style='margin-top: 0; color: #166534;'><i class='fa fa-chart-line'></i> Correlation Analysis</h4>",
      "<p style='margin: 0 0 10px 0; color: #166534; font-size: 15px; font-weight: 600;'>",
      "Research Question: Does S&P 500 performance affect household financial health after controlling for Federal Reserve policy?",
      "</p>",
      "<p style='margin: 0; color: #166534; font-size: 14px;'>",
      "Using partial correlation to account for confounding variables (Fed Funds Rate), we isolate the true relationship between stock market performance and household finances.",
      "</p>",
      "</div>",
      
      # Hypothesis Test
      "<div style='background: #f0f9ff; border-left: 4px solid #0284c7; padding: 15px; margin-bottom: 15px; border-radius: 4px;'>",
      "<h4 style='margin-top: 0; color: #0c4a6e;'><i class='fa fa-flask'></i> Hypothesis Test</h4>",
      "<p style='margin: 5px 0; color: #0c4a6e; font-size: 13px;'><b>H₀:</b> S&P 500 has no effect on CFHI (β = 0)</p>",
      "<p style='margin: 5px 0; color: #0c4a6e; font-size: 13px;'><b>Hₐ:</b> S&P 500 affects CFHI (β ≠ 0)</p>",
      "<p style='margin: 5px 0; color: #0c4a6e; font-size: 13px;'><b>Significance Level:</b> α = 0.05</p>",
      "</div>",
      
      # Statistical Results
      "<h4 style='color: #1e293b; margin-bottom: 10px;'>Statistical Results</h4>",
      "<pre style='background: #f8fafc; padding: 15px; border-radius: 5px; border-left: 4px solid #3b82f6; font-family: monospace; font-size: 13px; color: #1e293b; overflow-x: auto;'>",
      "Multiple Regression: CFHI ~ S&P500 + FedFundsRate\n\n",
      "S&P 500 Coefficient:\n",
      "  Estimate: β = ", sprintf("%.6f", sp500_coef["Estimate"]), "\n",
      "  Std Error: ", sprintf("%.6f", sp500_coef["Std. Error"]), "\n",
      "  t-value: ", sprintf("%.3f", sp500_coef["t value"]), "\n",
      "  p-value: ", if (sp500_coef["Pr(>|t|)"] < 0.001) "< 0.001" else sprintf("%.4f", sp500_coef["Pr(>|t|)"]), "\n\n",
      "Model Fit:\n",
      "  R² (adjusted): ", sprintf("%.4f", model_summary$adj.r.squared), "\n",
      "  F-statistic: ", sprintf("%.2f", model_summary$fstatistic[1]), "\n",
      "</pre>",
      
      # Interpretation
      "<h4 style='color: #1e293b; margin-bottom: 10px;'>Interpretation</h4>",
      "<div style='background: #f0fdf4; border-left: 4px solid #16a34a; padding: 15px; border-radius: 4px;'>",
      "<p style='margin: 0 0 10px 0; color: #166534; font-size: 14px;'>",
      "<b>Decision:</b> ",
      if (sp500_coef["Pr(>|t|)"] < 0.05) {
        paste0("<b style='color: #16a34a;'>REJECT H₀</b> (p = ", sprintf("%.4f", sp500_coef["Pr(>|t|)"]), " < 0.05)")
      } else {
        paste0("<b style='color: #dc2626;'>FAIL TO REJECT H₀</b> (p = ", sprintf("%.4f", sp500_coef["Pr(>|t|)"]), " ≥ 0.05)")
      },
      "</p>",
      "<p style='margin: 0; color: #166534; font-size: 14px;'>",
      "<b>Conclusion:</b> ",
      if (sp500_coef["Pr(>|t|)"] < 0.05) {
        # Calculate effect size in meaningful units (per 100-point S&P change)
        effect_per_100 <- sp500_coef["Estimate"] * 100
        
        # Calculate practical significance: how much of CFHI range is explained?
        cfhi_range <- 75.44  # 93.34 - 17.9
        typical_sp500_swing <- 1000  # Typical major market movement
        expected_cfhi_change <- typical_sp500_swing * sp500_coef["Estimate"]
        pct_of_range <- (expected_cfhi_change / cfhi_range) * 100
        
        if (sp500_coef["Estimate"] > 0) {
          paste0("The relationship is <b>statistically significant</b> (p < 0.05) but <b>",
                 if (abs(effect_per_100) < 1.0) "practically weak" else "meaningful",
                 "</b>. ",
                 "For every 100-point S&P 500 increase, CFHI rises by ", sprintf("%.2f", effect_per_100), " points ",
                 "(β = ", sprintf("%.6f", sp500_coef["Estimate"]), "). ",
                 if (abs(effect_per_100) < 1.0) {
                   paste0("<b>Practical Interpretation:</b> Even a 1,000-point S&P 500 swing (e.g., 3,500 → 4,500) ",
                          "would only move CFHI by ~", sprintf("%.1f", expected_cfhi_change), " points, ",
                          "representing just ", sprintf("%.1f%%", pct_of_range), " of the total CFHI range. ",
                          "<b>Conclusion: The stock market has minimal direct impact on typical household financial health.</b> ",
                          "Wages, inflation, and interest rates dominate household finances.")
                 } else {
                   "This represents a meaningful economic relationship showing that stock market gains meaningfully benefit household finances."
                 })
        } else {
          paste0("S&P 500 has a statistically significant <b>negative</b> effect. ",
                 "For every 100-point increase, CFHI decreases by ", sprintf("%.2f", abs(effect_per_100)), " points (β = ", 
                 sprintf("%.6f", sp500_coef["Estimate"]), "). ",
                 if (abs(effect_per_100) < 1.0) {
                   "However, the practical effect size is small."
                 } else {
                   "This suggests stock market gains may correlate with factors that harm household finances."
                 })
        }
      } else {
        paste0("<b>No significant relationship exists</b> between S&P 500 and household financial health after controlling for Fed policy (p = ",
               sprintf("%.4f", sp500_coef["Pr(>|t|)"]), "). ",
               "Stock market movements do not independently predict household finances when interest rates are held constant.")
      },
      "</p>",
      "</div>",
      
      "</div>"
    )
  } else {
    insights_html <- paste0(
      "<div style='padding: 15px;'>",
      "<p style='color: #dc2626;'>Unable to compute correlation statistics. Please check data availability.</p>",
      "</div>"
    )
  }
  
  HTML(insights_html)
})
