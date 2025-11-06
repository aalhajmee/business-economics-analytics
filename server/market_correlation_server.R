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
    # Load raw CFHI component data
    cfhi_raw <- read_csv("data/cfhi/cfhi_master_2000_onward.csv", show_col_types = FALSE) %>%
      mutate(date = floor_date(as.Date(date), "month")) %>%
      select(date, savings_rate, wage_yoy, inflation_yoy, borrow_rate) %>%
      distinct(date, .keep_all = TRUE) %>%
      arrange(date) %>%
      filter(!is.na(savings_rate), !is.na(wage_yoy), !is.na(inflation_yoy), !is.na(borrow_rate))
    
    # Calculate min/max for each component using FULL dataset (Apr 2006 to Aug 2025)
    # This ensures normalization is consistent regardless of date range selection
    savings_min <- min(cfhi_raw$savings_rate, na.rm = TRUE)
    savings_max <- max(cfhi_raw$savings_rate, na.rm = TRUE)
    wage_min <- min(cfhi_raw$wage_yoy, na.rm = TRUE)
    wage_max <- max(cfhi_raw$wage_yoy, na.rm = TRUE)
    inflation_min <- min(cfhi_raw$inflation_yoy, na.rm = TRUE)
    inflation_max <- max(cfhi_raw$inflation_yoy, na.rm = TRUE)
    borrow_min <- min(cfhi_raw$borrow_rate, na.rm = TRUE)
    borrow_max <- max(cfhi_raw$borrow_rate, na.rm = TRUE)
    
    # Calculate CFHI components with fixed normalization
    cfhi <- cfhi_raw %>%
      mutate(
        S_star = 100 * scale01(savings_rate, savings_min, savings_max),
        W_star = 100 * scale01(wage_yoy, wage_min, wage_max),
        I_star = 100 - 100 * scale01(inflation_yoy, inflation_min, inflation_max),
        R_star = 100 - 100 * scale01(borrow_rate, borrow_min, borrow_max),
        CFHI_raw = (S_star + W_star + I_star + R_star) / 4
      ) %>%
      mutate(CFHI = CFHI_raw) %>%
      select(date, CFHI)
    
    # Rebase to October 2006 = 100
    base_date <- as.Date("2006-10-01")
    base_value <- cfhi %>%
      filter(date == base_date) %>%
      pull(CFHI) %>%
      first()
    
    if (!is.na(base_value) && base_value != 0) {
      cfhi <- cfhi %>%
        mutate(CFHI = (CFHI / base_value) * 100)
    }
    
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
    
    # Index S&P 500 to October 2006 = 100 (same baseline as CFHI)
    sp500_baseline <- merged %>%
      filter(date == base_date) %>%
      pull(sp500_price) %>%
      first()
    
    if (!is.na(sp500_baseline) && sp500_baseline != 0) {
      merged <- merged %>%
        mutate(sp500_indexed = (sp500_price / sp500_baseline) * 100)
    } else {
      merged <- merged %>%
        mutate(sp500_indexed = sp500_price)
    }
    
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

# Calculate correlation statistics with hypothesis testing
correlation_stats <- reactive({
  data <- market_data()
  
  if (nrow(data) < 3) {
    return(list(
      correlation = NA,
      p_value = NA,
      r_squared = NA,
      n = nrow(data),
      model = NULL,
      conf_int = c(NA, NA),
      effect_size = NA,
      hypothesis_result = "Insufficient data"
    ))
  }
  
  # Use Pearson correlation method
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
  
  list(
    correlation = cor_test$estimate,
    p_value = cor_test$p.value,
    r_squared = r_squared,
    n = nrow(data),
    model = model,
    method = method,
    conf_int = conf_int,
    effect_size = effect_size,
    hypothesis_result = hypothesis_result,
    cor_test = cor_test
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

# Data verification display - proves values are stable
output$data_verification_display <- renderUI({
  data <- market_data()
  
  if (nrow(data) == 0) {
    return(tags$p(style="color:#dc2626; margin-top:8px;", "No data available for verification."))
  }
  
  # Test specific dates that should always have the same values
  test_dates <- c(
    as.Date("2006-10-01"),  # Baseline (should always be 100)
    as.Date("2020-01-01"),  # Pre-pandemic
    as.Date("2024-01-01")   # Recent data
  )
  
  verification_rows <- lapply(test_dates, function(test_date) {
    row_data <- data %>% filter(date == test_date)
    
    if (nrow(row_data) > 0) {
      cfhi_val <- round(row_data$CFHI, 2)
      sp500_val <- round(row_data$sp500_indexed, 2)
      date_str <- format(test_date, "%B %Y")
      
      tags$tr(
        tags$td(style="padding:4px 12px; border-bottom:1px solid #e5e7eb;", date_str),
        tags$td(style="padding:4px 12px; border-bottom:1px solid #e5e7eb; text-align:right; font-family:monospace;", 
                tags$b(cfhi_val)),
        tags$td(style="padding:4px 12px; border-bottom:1px solid #e5e7eb; text-align:right; font-family:monospace;", 
                tags$b(sp500_val))
      )
    } else {
      NULL
    }
  })
  
  tags$div(
    style = "margin-top:8px;",
    tags$p(style="font-size:12px; color:#475569; margin-bottom:6px;",
      "Verification: These index values remain constant across all date range selections:"),
    tags$table(
      style = "width:100%; font-size:12px; background:white; border-radius:4px;",
      tags$thead(
        tags$tr(style="background:#f8fafc;",
          tags$th(style="padding:6px 12px; text-align:left; border-bottom:2px solid #cbd5e1;", "Date"),
          tags$th(style="padding:6px 12px; text-align:right; border-bottom:2px solid #cbd5e1;", "CFHI Index"),
          tags$th(style="padding:6px 12px; text-align:right; border-bottom:2px solid #cbd5e1;", "S&P 500 Index")
        )
      ),
      tags$tbody(verification_rows)
    )
  )
})

# Dual-axis time series plot
output$dual_axis_plot <- renderPlotly({
  data <- market_data()
  
  if (nrow(data) == 0) {
    return(plotly_empty())
  }
  
  # Data already has CFHI and sp500_indexed both indexed to Oct 2006 = 100
  plot_ly(data) %>%
    add_trace(
      x = ~date,
      y = ~CFHI,
      type = "scatter",
      mode = "lines",
      name = "CFHI (Oct 2006 = 100)",
      line = list(color = "#1e40af", width = 2.5),
      yaxis = "y1",
      hovertemplate = "Date: %{x}<br>CFHI: %{y:.2f}<extra></extra>"
    ) %>%
    add_trace(
      x = ~date,
      y = ~sp500_indexed,
      type = "scatter",
      mode = "lines",
      name = "S&P 500 (Oct 2006 = 100)",
      line = list(color = "#16a34a", width = 2.5),
      yaxis = "y1",
      hovertemplate = "Date: %{x}<br>S&P 500 Index: %{y:.2f}<extra></extra>"
    ) %>%
    layout(
      title = list(
        text = "<b>CFHI vs S&P 500 Over Time</b> (Both Indexed to October 2006 = 100)",
        font = list(size = 16)
      ),
      xaxis = list(
        title = "Date",
        showgrid = TRUE,
        gridcolor = "#e5e5e5"
      ),
      yaxis = list(
        title = "Index Value (Oct 2006 = 100)",
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
  
  insights_html <- paste0(
    "<div style='padding: 15px; line-height: 1.8;'>",
    
    # Summary Statement
    "<div style='background: #f0fdf4; border-left: 4px solid #16a34a; padding: 15px; margin-bottom: 15px; border-radius: 4px;'>",
    "<h4 style='margin-top: 0; color: #166534;'><i class='fa fa-check-circle'></i> Summary Finding</h4>",
    "<p style='margin: 0; color: #166534; font-size: 15px; font-weight: 500;'>", simple_summary, "</p>",
    "</div>",
    
    # Hypothesis Testing Section
    "<div style='background: #f0f9ff; border-left: 4px solid #0284c7; padding: 12px; margin-bottom: 15px; border-radius: 4px;'>",
    "<h4 style='margin-top: 0; color: #0c4a6e;'><i class='fa fa-flask'></i> Formal Hypothesis Test</h4>",
    "<p style='margin: 5px 0; color: #0c4a6e; font-size: 13px;'><b>H₀ (Null Hypothesis):</b> There is no correlation between CFHI and S&P 500 (ρ = 0)</p>",
    "<p style='margin: 5px 0; color: #0c4a6e; font-size: 13px;'><b>Hₐ (Alternative Hypothesis):</b> There is a correlation between CFHI and S&P 500 (ρ ≠ 0)</p>",
    "<p style='margin: 5px 0; color: #0c4a6e; font-size: 13px;'><b>Significance Level:</b> α = 0.05</p>",
    "<p style='margin: 10px 0 5px 0; color: #0c4a6e; font-size: 14px; font-weight: 600;'><b>Result:</b> ", stats$hypothesis_result, "</p>",
    "</div>",
    
    # Statistical Summary
    "<h4 style='margin-top: 0; color: #1e293b;'>Statistical Summary</h4>",
    "<ul style='color: #475569; font-size: 14px;'>",
    "<li><b>Correlation Coefficient:</b> r = ", round(cor_val, 3), " (", cor_strength, " ", cor_direction, ")</li>",
    "<li><b>95% Confidence Interval:</b> ", ci_text, "</li>",
    "<li><b>Effect Size (Cohen's d):</b> ", stats$effect_size, "</li>",
    "<li><b>P-value:</b> ", if (p_val < 0.001) "< 0.001" else round(p_val, 4), 
    " → ", sig_text, "</li>",
    "<li><b>R² (Variance Explained):</b> ", variance_pct, "%</li>",
    "<li><b>Sample Size:</b> n = ", stats$n, " months</li>",
    "</ul>",
    
    # Key Findings
    "<h4 style='margin-top: 15px; color: #1e293b;'>Key Findings</h4>",
    "<ul style='color: #475569; font-size: 14px;'>",
    "<li><b>Overall Period:</b> ", cor_strength, " ", cor_direction, " correlation (r = ", round(cor_val, 3), ") ",
    "between CFHI and S&P 500, explaining ", variance_pct, "% of CFHI variance.</li>",
    "<li><b>Recent Trend (12 months):</b> The correlation has <b>", recent_change, "</b> (r = ", round(recent_cor, 3), ")",
    if (direction_changed) {
      paste0(", indicating a <b style='color:#dc2626;'>fundamental shift in the relationship</b>. ",
             "The ", if (cor_val < 0) "inverse" else "positive", " relationship observed historically has ",
             if (recent_cor > 0) "become positive" else "become inverse", " in recent data.")
    } else if (recent_change != "remained stable") {
      paste0(", though the direction (", if (cor_val > 0) "positive" else "negative", ") remains consistent.")
    } else {
      "."
    },
    "</li>",
    "<li><b>Practical Significance:</b> S&P 500 movements explain only ", variance_pct, "% of household financial health variation, ",
    "suggesting other factors (wages, inflation, savings rates) play dominant roles.</li>",
    "</ul>",
    
    # Interpretation
    "<h4 style='color: #1e293b; margin-bottom: 10px;'>Analysis Interpretation</h4>",
    "<p style='color: #475569; font-size: 14px; margin-bottom: 10px;'>",
    if (direction_changed) {
      paste0("<b style='color:#dc2626;'>Direction Reversal Detected:</b> The relationship between S&P 500 and CFHI has fundamentally changed. ",
             "The overall ", if (cor_val < 0) "negative" else "positive", " correlation (r = ", round(cor_val, 3), ") is driven by historical data, ",
             "while recent months show a ", if (recent_cor > 0) "positive" else "negative", " correlation (r = ", round(recent_cor, 3), "). ",
             if (cor_val < 0 && recent_cor > 0) {
               "This shift from inverse to positive relationship may reflect increased 401(k) participation, broader equity ownership, or recent economic conditions where market gains and household finances both benefited from the same macroeconomic tailwinds (e.g., employment growth, wage increases)."
             } else if (cor_val > 0 && recent_cor < 0) {
               "This shift from positive to inverse relationship may indicate changing economic dynamics where recent market gains have not translated to household benefit, potentially due to inflation concerns, rising costs, or concentrated wealth effects."
             } else {
               "This temporal instability suggests the relationship is highly dependent on prevailing economic conditions and policy environments."
             })
    } else if (abs(cor_val) >= 0.5) {
      if (cor_val > 0) {
        paste0("The strong positive correlation suggests that S&P 500 performance and household financial health move in the same direction. ",
               "This may be attributed to wealth effects (retirement accounts and investments), consumer confidence, and broader economic conditions that affect both markets and households.")
      } else {
        paste0("The strong negative correlation indicates an inverse relationship where S&P 500 gains coincide with declining household financial health. ",
               "This counterintuitive pattern may reflect periods where market growth was concentrated among high-wealth individuals while median households faced wage stagnation or rising costs.")
      }
    } else if (abs(cor_val) >= 0.3) {
      if (cor_val > 0) {
        paste0("The moderate positive correlation indicates that market performance and household finances are somewhat linked, but other factors play substantial roles. ",
               "Variables such as wage growth, employment rates, and inflation independently influence household financial health beyond market effects.")
      } else {
        paste0("The moderate negative correlation suggests that market gains may not benefit median households proportionally. ",
               "This could reflect income inequality dynamics where equity ownership is concentrated, or periods where market optimism diverged from household economic realities.")
      }
    } else {
      if (cor_val != 0) {
        paste0("The weak correlation (r = ", round(cor_val, 3), ") indicates that S&P 500 movements have minimal direct association with household financial health. ",
               "This finding emphasizes that household well-being depends primarily on factors like wage growth, savings rates, inflation control, and borrowing costs rather than equity market performance.")
      } else {
        "No meaningful correlation was detected, suggesting that S&P 500 performance and household financial health operate independently during this period."
      }
    },
    "</p>",
    
    # Important Note
    "<div style='background: #fef3c7; border-left: 4px solid #f59e0b; padding: 10px; margin-top: 15px; border-radius: 4px;'>",
    "<p style='margin: 0; color: #78350f; font-size: 13px;'><b><i class='fa fa-exclamation-triangle'></i> Important:</b> ",
    "Correlation does not imply causation. While we observe a ", cor_strength, " ", cor_direction, 
    " relationship, this could be due to: (1) S&P 500 influencing CFHI, (2) CFHI influencing S&P 500, ",
    "(3) a third variable influencing both (e.g., Federal Reserve policy), or (4) coincidental patterns. ",
    "Further analysis would be needed to establish causal mechanisms.</p>",
    "</div>",
    
    "</div>"
  )
  
  HTML(insights_html)
})
