# ============================================================================
# Statistical Analysis - Server Logic
# ============================================================================

statistical_analysis_server <- function(input, output, session, macro_data, shared_state) {
  
  # Initialize year selector
  observe({
    years <- sort(unique(macro_data$year))
    updateSelectInput(session, "regression_year", choices = years, selected = max(years, na.rm = TRUE))
  })
  
  # ============================================================================
  # 1. ANOVA: Regional Economic Differences
  # ============================================================================
  
  anova_data <- reactive({
    req(input$anova_indicator, input$anova_year)
    
    macro_data %>%
      filter(year == input$anova_year, !is.na(region), !is.na(.data[[input$anova_indicator]])) %>%
      select(region, value = .data[[input$anova_indicator]]) %>%
      filter(!is.na(value))
  })
  
  anova_model <- reactive({
    data <- anova_data()
    req(nrow(data) > 0)
    
    # Perform ANOVA
    model <- aov(value ~ region, data = data)
    model
  })
  
  output$anova_results <- renderUI({
    model <- anova_model()
    req(model)
    
    anova_summary <- summary(model)
    f_stat <- anova_summary[[1]]$`F value`[1]
    p_value <- anova_summary[[1]]$`Pr(>F)`[1]
    df1 <- anova_summary[[1]]$Df[1]
    df2 <- anova_summary[[1]]$Df[2]
    
    # Interpretation
    significant <- p_value < 0.05
    color_class <- if(significant) "success" else "secondary"
    interpretation <- if(significant) 
      "There IS a statistically significant difference between regions." 
    else 
      "There is NO statistically significant difference between regions."
    
    # Calculate region means for interpretation
    data <- anova_data()
    region_means <- data %>%
      group_by(region) %>%
      summarise(mean_value = mean(value, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(mean_value))
    
    highest_region <- region_means$region[1]
    lowest_region <- region_means$region[nrow(region_means)]
    highest_mean <- round(region_means$mean_value[1], 2)
    lowest_mean <- round(region_means$mean_value[nrow(region_means)], 2)
    
    indicator_label <- tools::toTitleCase(gsub("_", " ", input$anova_indicator))
    
    # Build interpretation text
    if(significant) {
      interpretation_text <- paste0('The test found <strong>statistically significant differences</strong> in ', indicator_label, 
                                     ' across regions. This means the differences we see are likely real and not just due to random chance. ',
                                     'The region with the highest average is <strong>', highest_region, '</strong> (', highest_mean, 
                                     '), while the lowest is <strong>', lowest_region, '</strong> (', lowest_mean, ').')
    } else {
      interpretation_text <- paste0('The test found <strong>no statistically significant differences</strong> in ', indicator_label, 
                                     ' across regions. This means any differences we observe could be due to random variation rather than ',
                                     'true regional disparities. All regions appear to have similar values on average.')
    }
    
    HTML(paste0(
      '<div class="alert alert-', color_class, '">',
      '<h5>ANOVA Results</h5>',
      '<p><strong>F-statistic:</strong> ', round(f_stat, 3), '</p>',
      '<p><strong>P-value:</strong> ', format.pval(p_value, digits = 4), '</p>',
      '<p><strong>Degrees of Freedom:</strong> ', df1, ', ', df2, '</p>',
      '<hr>',
      '<p><strong>What This Means:</strong></p>',
      '<p style="font-size: 14px; margin-bottom: 10px;">', interpretation_text, '</p>',
      '<p style="font-size: 12px; margin-top: 10px; color: #64748b;">',
      '<strong>Understanding P-values:</strong> A p-value < 0.05 means there\'s less than a 5% chance the observed ',
      'differences occurred by random chance. This is the standard threshold for statistical significance.',
      '</p>',
      '</div>'
    ))
  })
  
  output$anova_plot <- renderPlotly({
    data <- anova_data()
    req(nrow(data) > 0)
    
    indicator_label <- tools::toTitleCase(gsub("_", " ", input$anova_indicator))
    
    # Create boxplot
    p <- plot_ly(data, x = ~region, y = ~value, type = "box",
                 boxpoints = "outliers", marker = list(color = "#2563eb", size = 4),
                 line = list(color = "#1e293b")) %>%
      layout(
        title = list(text = paste("Distribution of", indicator_label, "by Region (", input$anova_year, ")"),
                    font = list(color = "#1e293b", size = 16)),
        xaxis = list(title = "Region", showgrid = FALSE),
        yaxis = list(title = indicator_label, showgrid = TRUE, gridcolor = "#e2e8f0"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    
    p
  })
  
  # ============================================================================
  # 2. Multiple Linear Regression: Determinants of Life Expectancy
  # ============================================================================
  
  regression_data <- reactive({
    req(input$regression_year, input$regression_predictors)
    
    if (length(input$regression_predictors) == 0) {
      return(data.frame())
    }
    
    macro_data %>%
      filter(year == input$regression_year,
             !is.na(life_expectancy),
             !if_any(all_of(input$regression_predictors), is.na)) %>%
      select(country, life_expectancy, all_of(input$regression_predictors))
  })
  
  regression_model <- reactive({
    data <- regression_data()
    req(nrow(data) > 10, length(input$regression_predictors) > 0)
    
    # Build formula
    formula_str <- paste("life_expectancy ~", paste(input$regression_predictors, collapse = " + "))
    formula_obj <- as.formula(formula_str)
    
    # Fit model
    model <- lm(formula_obj, data = data)
    model
  })
  
  output$regression_summary <- renderUI({
    model <- regression_model()
    req(model)
    
    summary_model <- summary(model)
    r_squared <- summary_model$r.squared
    adj_r_squared <- summary_model$adj.r.squared
    f_stat <- summary_model$fstatistic[1]
    f_pvalue <- pf(f_stat, summary_model$fstatistic[2], summary_model$fstatistic[3], lower.tail = FALSE)
    
    # Coefficients
    coef_table <- summary_model$coefficients
    coef_html <- paste0(
      '<table class="table table-sm" style="font-size: 13px;">',
      '<thead><tr><th>Variable</th><th>Coefficient</th><th>Std. Error</th><th>t-value</th><th>P-value</th></tr></thead>',
      '<tbody>'
    )
    
    for (i in 1:nrow(coef_table)) {
      var_name <- rownames(coef_table)[i]
      var_label <- tools::toTitleCase(gsub("_", " ", var_name))
      coef <- coef_table[i, 1]
      se <- coef_table[i, 2]
      t_val <- coef_table[i, 3]
      p_val <- coef_table[i, 4]
      sig <- if(p_val < 0.001) "***" else if(p_val < 0.01) "**" else if(p_val < 0.05) "*" else ""
      
      coef_html <- paste0(coef_html,
        '<tr>',
        '<td>', var_label, '</td>',
        '<td>', round(coef, 4), sig, '</td>',
        '<td>', round(se, 4), '</td>',
        '<td>', round(t_val, 3), '</td>',
        '<td>', format.pval(p_val, digits = 4), '</td>',
        '</tr>'
      )
    }
    coef_html <- paste0(coef_html, '</tbody></table>')
    
    # Find significant predictors for interpretation
    significant_vars <- rownames(coef_table)[coef_table[, 4] < 0.05 & rownames(coef_table) != "(Intercept)"]
    positive_vars <- rownames(coef_table)[coef_table[, 1] > 0 & rownames(coef_table) != "(Intercept)" & coef_table[, 4] < 0.05]
    negative_vars <- rownames(coef_table)[coef_table[, 1] < 0 & rownames(coef_table) != "(Intercept)" & coef_table[, 4] < 0.05]
    
    interpretation_text <- ""
    if (length(significant_vars) > 0) {
      if (length(positive_vars) > 0) {
        pos_labels <- paste(tools::toTitleCase(gsub("_", " ", positive_vars)), collapse = ", ")
        interpretation_text <- paste0(interpretation_text, 
          '<strong>Positive relationships:</strong> Higher values of ', pos_labels, 
          ' are associated with higher life expectancy. ')
      }
      if (length(negative_vars) > 0) {
        neg_labels <- paste(tools::toTitleCase(gsub("_", " ", negative_vars)), collapse = ", ")
        interpretation_text <- paste0(interpretation_text,
          '<strong>Negative relationships:</strong> Higher values of ', neg_labels,
          ' are associated with lower life expectancy. ')
      }
    } else {
      interpretation_text <- '<strong>No significant predictors:</strong> None of the selected economic indicators show a statistically significant relationship with life expectancy in this model.'
    }
    
    r_sq_interpretation <- if(r_squared < 0.3) "weak" else if(r_squared < 0.7) "moderate" else "strong"
    
    # Build model significance text
    model_sig_text <- if(f_pvalue < 0.05) {
      'The model is <strong>statistically significant</strong>, meaning the economic indicators together do help predict life expectancy.'
    } else {
      'The model is <strong>not statistically significant</strong>, meaning these economic indicators may not be good predictors of life expectancy.'
    }
    
    HTML(paste0(
      '<div class="alert alert-info">',
      '<h5>Regression Model Summary</h5>',
      '<p><strong>R-squared:</strong> ', round(r_squared, 4), ' (', round(r_squared * 100, 2), '% of variance explained)</p>',
      '<p><strong>Adjusted R-squared:</strong> ', round(adj_r_squared, 4), '</p>',
      '<p><strong>F-statistic:</strong> ', round(f_stat, 2), ' (p = ', format.pval(f_pvalue, digits = 4), ')</p>',
      '<hr>',
      '<p><strong>What This Means:</strong></p>',
      '<p style="font-size: 14px; margin-bottom: 10px;">',
      'This model explains <strong>', round(r_squared * 100, 1), '%</strong> of the variation in life expectancy across countries. ',
      'This is a <strong>', r_sq_interpretation, '</strong> explanatory power. ', model_sig_text,
      '</p>',
      '<p style="font-size: 14px;">', interpretation_text, '</p>',
      '<p style="font-size: 12px; margin-top: 10px; color: #64748b;">',
      '<strong>Understanding Coefficients:</strong> A positive coefficient means that variable increases life expectancy. ',
      'A negative coefficient means it decreases life expectancy. The size of the coefficient shows how strong the effect is.',
      '</p>',
      '<p style="font-size: 11px; margin-top: 10px;">Significance codes: *** p<0.001, ** p<0.01, * p<0.05</p>',
      '</div>',
      coef_html
    ))
  })
  
  output$regression_plot <- renderPlotly({
    model <- regression_model()
    data <- regression_data()
    req(model, nrow(data) > 0)
    
    # Predicted vs Actual
    data$predicted <- predict(model)
    
    p <- plot_ly(data, x = ~predicted, y = ~life_expectancy,
                 type = "scatter", mode = "markers",
                 marker = list(color = "#2563eb", size = 6, opacity = 0.6),
                 text = ~paste("Country:", country),
                 hoverinfo = "text") %>%
      add_trace(x = ~predicted, y = ~predicted, type = "scatter", mode = "lines",
                line = list(color = "#e74c3c", width = 2, dash = "dash"),
                name = "Perfect Prediction") %>%
      layout(
        title = list(text = "Predicted vs. Actual Life Expectancy", font = list(color = "#1e293b", size = 16)),
        xaxis = list(title = "Predicted Life Expectancy (years)", showgrid = TRUE, gridcolor = "#e2e8f0"),
        yaxis = list(title = "Actual Life Expectancy (years)", showgrid = TRUE, gridcolor = "#e2e8f0"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    
    p
  })
  
  output$regression_residuals <- renderPlotly({
    model <- regression_model()
    req(model)
    
    # Residuals vs Fitted
    fitted_vals <- fitted(model)
    residuals_vals <- residuals(model)
    
    p <- plot_ly(x = ~fitted_vals, y = ~residuals_vals,
                 type = "scatter", mode = "markers",
                 marker = list(color = "#2563eb", size = 6, opacity = 0.6)) %>%
      add_trace(x = ~fitted_vals, y = 0, type = "scatter", mode = "lines",
                line = list(color = "#e74c3c", width = 2, dash = "dash")) %>%
      layout(
        title = list(text = "Residuals vs. Fitted Values", font = list(color = "#1e293b", size = 14)),
        xaxis = list(title = "Fitted Values", showgrid = TRUE, gridcolor = "#e2e8f0"),
        yaxis = list(title = "Residuals", showgrid = TRUE, gridcolor = "#e2e8f0"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    
    p
  })
  
  # ============================================================================
  # 3. Chi-Square Test of Independence
  # ============================================================================
  
  chisquare_data <- reactive({
    req(input$chisquare_indicator, input$chisquare_year, input$chisquare_categorization)
    
    data <- macro_data %>%
      filter(year == input$chisquare_year,
             !is.na(region),
             !is.na(.data[[input$chisquare_indicator]])) %>%
      select(region, value = .data[[input$chisquare_indicator]]) %>%
      filter(!is.na(value))
    
    if (nrow(data) == 0) return(data.frame())
    
    # Categorize the indicator values
    if (input$chisquare_categorization == "median") {
      median_val <- median(data$value, na.rm = TRUE)
      data$category <- ifelse(data$value >= median_val, "Above Median", "Below Median")
    } else if (input$chisquare_categorization == "tertiles") {
      tertiles <- quantile(data$value, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE)
      data$category <- cut(data$value, breaks = tertiles, 
                          labels = c("Low", "Medium", "High"),
                          include.lowest = TRUE)
    } else if (input$chisquare_categorization == "quartiles") {
      quartiles <- quantile(data$value, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
      data$category <- cut(data$value, breaks = quartiles,
                          labels = c("Q1 (Lowest)", "Q2", "Q3", "Q4 (Highest)"),
                          include.lowest = TRUE)
    }
    
    data
  })
  
  chisquare_result <- reactive({
    data <- chisquare_data()
    req(nrow(data) > 0)
    
    # Create contingency table
    contingency_table <- table(data$region, data$category)
    
    # Check if table has sufficient data (at least 2x2)
    if (nrow(contingency_table) < 2 || ncol(contingency_table) < 2) {
      return(NULL)
    }
    
    # Perform Chi-Square test
    test_result <- tryCatch({
      chisq.test(contingency_table)
    }, error = function(e) {
      cat("Chi-Square test error:", e$message, "\n")
      return(NULL)
    })
    
    if (is.null(test_result)) return(NULL)
    
    list(test = test_result, table = contingency_table, data = data)
  })
  
  output$chisquare_results <- renderUI({
    result <- chisquare_result()
    req(result)
    
    test <- result$test
    contingency_table <- result$table
    
    chi_sq_stat <- round(test$statistic, 4)
    p_value <- test$p.value
    df <- test$parameter
    significant <- p_value < 0.05
    
    indicator_label <- tools::toTitleCase(gsub("_", " ", input$chisquare_indicator))
    
    # Hypothesis
    h0_text <- paste0("H0: Economic indicator categories (", indicator_label, ") are independent of geographic regions.")
    h1_text <- paste0("H1: Economic indicator categories are dependent on geographic regions.")
    
    color_class <- if(significant) "success" else "secondary"
    
    # Build interpretation text
    if (significant) {
      interpretation_text <- paste0('The test found a <strong>statistically significant association</strong> between ', indicator_label, 
                                     ' categories and geographic regions (p < 0.05). This means that certain regions are more likely to have ',
                                     'specific economic performance levels. The distribution of economic categories is not random across regions, ',
                                     'indicating geographic patterns in economic development.')
    } else {
      interpretation_text <- paste0('The test found <strong>no statistically significant association</strong> between ', indicator_label, 
                                   ' categories and geographic regions (p ≥ 0.05). This means that economic performance levels appear to be ',
                                   'distributed independently across regions, suggesting no strong geographic pattern in this indicator.')
    }
    
    HTML(paste0(
      '<div class="alert alert-', color_class, '">',
      '<h5>Chi-Square Test of Independence</h5>',
      '<p><strong>Hypothesis:</strong></p>',
      '<p style="font-size: 13px; margin-bottom: 5px;">', h0_text, '</p>',
      '<p style="font-size: 13px; margin-bottom: 15px;">', h1_text, '</p>',
      '<hr>',
      '<p><strong>Test Results:</strong></p>',
      '<ul>',
      '<li><strong>Chi-Square Statistic:</strong> ', chi_sq_stat, '</li>',
      '<li><strong>Degrees of Freedom:</strong> ', df, '</li>',
      '<li><strong>P-value:</strong> ', format.pval(p_value, digits = 4), '</li>',
      '<li><strong>Result:</strong> ', if(significant) "REJECT H0 (p < 0.05)" else "FAIL TO REJECT H0 (p ≥ 0.05)", '</li>',
      '</ul>',
      '<hr>',
      '<p><strong>What This Means:</strong></p>',
      '<p style="font-size: 14px; margin-bottom: 10px;">', interpretation_text, '</p>',
      '<p style="font-size: 12px; margin-top: 10px; color: #64748b;">',
      '<strong>Understanding the Test:</strong> The Chi-Square test compares the observed distribution of countries across economic categories ',
      'and regions to what we would expect if they were independent. A significant result indicates that the observed pattern is unlikely ',
      'to have occurred by chance alone.',
      '</p>',
      '</div>'
    ))
  })
  
  output$chisquare_plot <- renderPlotly({
    result <- chisquare_result()
    req(result)
    
    contingency_table <- result$table
    
    # Convert to data frame for plotting
    plot_data <- as.data.frame(contingency_table)
    names(plot_data) <- c("Region", "Category", "Count")
    
    indicator_label <- tools::toTitleCase(gsub("_", " ", input$chisquare_indicator))
    
    p <- plot_ly(plot_data, x = ~Region, y = ~Count, color = ~Category,
                 type = "bar",
                 text = ~paste("Region:", Region, "<br>Category:", Category, "<br>Count:", Count),
                 hoverinfo = "text") %>%
      layout(
        title = list(text = paste("Distribution of", indicator_label, "Categories by Region"),
                    font = list(color = "#1e293b", size = 16)),
        xaxis = list(title = "Region", showgrid = FALSE),
        yaxis = list(title = "Number of Countries", showgrid = TRUE, gridcolor = "#e2e8f0"),
        barmode = "group",
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    
    p
  })
  
  output$chisquare_table <- renderDT({
    result <- chisquare_result()
    req(result)
    
    contingency_table <- result$table
    
    # Convert to data frame with proper formatting
    table_df <- as.data.frame.matrix(contingency_table)
    table_df <- cbind(Region = rownames(table_df), table_df)
    rownames(table_df) <- NULL
    
    datatable(table_df, 
              options = list(pageLength = 15, scrollX = TRUE),
              rownames = FALSE,
              caption = paste("Contingency Table:", tools::toTitleCase(gsub("_", " ", input$chisquare_indicator)), "Categories by Region"))
  })
}

