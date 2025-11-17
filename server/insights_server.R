# === LOAD CREDIT SCORE DATASET ===
credit_data <- read.csv("data/personal/credit_score.csv")
library(ggplot2)
library(scales)
# for gaugeOutput

# === Variable Name Mapping (Readable Labels) ===
# === Complete Human Readable Labels for ALL 85 Variables ===

pretty_labels <- list(
  
  # Core Financial Metrics
  CUST_ID = "Customer ID",
  INCOME = "Annual Income",
  SAVINGS = "Annual Savings",
  DEBT = "Total Debt",
  R_SAVINGS_INCOME = "Savings-to-Income Ratio",
  R_DEBT_INCOME = "Debt-to-Income Ratio",
  R_DEBT_SAVINGS = "Debt-to-Savings Ratio",
  
  # --- CLOTHING ---
  T_CLOTHING_12 = "Clothing Spending (12 Months)",
  T_CLOTHING_6  = "Clothing Spending (6 Months)",
  R_CLOTHING = "Clothing Spending Ratio (6m/12m)",
  R_CLOTHING_INCOME = "Clothing-to-Income Ratio",
  R_CLOTHING_SAVINGS = "Clothing-to-Savings Ratio",
  R_CLOTHING_DEBT = "Clothing-to-Debt Ratio",
  
  # --- EDUCATION ---
  T_EDUCATION_12 = "Education Spending (12 Months)",
  T_EDUCATION_6  = "Education Spending (6 Months)",
  R_EDUCATION = "Education Spending Ratio (6m/12m)",
  R_EDUCATION_INCOME = "Education-to-Income Ratio",
  R_EDUCATION_SAVINGS = "Education-to-Savings Ratio",
  R_EDUCATION_DEBT = "Education-to-Debt Ratio",
  
  # --- ENTERTAINMENT ---
  T_ENTERTAINMENT_12 = "Entertainment Spending (12 Months)",
  T_ENTERTAINMENT_6  = "Entertainment Spending (6 Months)",
  R_ENTERTAINMENT = "Entertainment Spending Ratio (6m/12m)",
  R_ENTERTAINMENT_INCOME = "Entertainment-to-Income Ratio",
  R_ENTERTAINMENT_SAVINGS = "Entertainment-to-Savings Ratio",
  R_ENTERTAINMENT_DEBT = "Entertainment-to-Debt Ratio",
  
  # --- FINES ---
  T_FINES_12 = "Fines (12 Months)",
  T_FINES_6 = "Fines (6 Months)",
  R_FINES = "Fines Ratio (6m/12m)",
  R_FINES_INCOME = "Fines-to-Income Ratio",
  R_FINES_SAVINGS = "Fines-to-Savings Ratio",
  R_FINES_DEBT = "Fines-to-Debt Ratio",
  
  # --- GAMBLING ---
  T_GAMBLING_12 = "Gambling Spending (12 Months)",
  T_GAMBLING_6 = "Gambling Spending (6 Months)",
  R_GAMBLING = "Gambling Ratio (6m/12m)",
  R_GAMBLING_INCOME = "Gambling-to-Income Ratio",
  R_GAMBLING_SAVINGS = "Gambling-to-Savings Ratio",
  R_GAMBLING_DEBT = "Gambling-to-Debt Ratio",
  
  # --- GROCERIES ---
  T_GROCERIES_12 = "Groceries Spending (12 Months)",
  T_GROCERIES_6 = "Groceries Spending (6 Months)",
  R_GROCERIES = "Groceries Ratio (6m/12m)",
  R_GROCERIES_INCOME = "Groceries-to-Income Ratio",
  R_GROCERIES_SAVINGS = "Groceries-to-Savings Ratio",
  R_GROCERIES_DEBT = "Groceries-to-Debt Ratio",
  
  # --- HEALTH ---
  T_HEALTH_12 = "Health Spending (12 Months)",
  T_HEALTH_6 = "Health Spending (6 Months)",
  R_HEALTH = "Health Ratio (6m/12m)",
  R_HEALTH_INCOME = "Health-to-Income Ratio",
  R_HEALTH_SAVINGS = "Health-to-Savings Ratio",
  R_HEALTH_DEBT = "Health-to-Debt Ratio",
  
  # --- HOUSING ---
  T_HOUSING_12 = "Housing Spending (12 Months)",
  T_HOUSING_6 = "Housing Spending (6 Months)",
  R_HOUSING = "Housing Ratio (6m/12m)",
  R_HOUSING_INCOME = "Housing-to-Income Ratio",
  R_HOUSING_SAVINGS = "Housing-to-Savings Ratio",
  R_HOUSING_DEBT = "Housing-to-Debt Ratio",
  
  # --- TAX ---
  T_TAX_12 = "Tax Payments (12 Months)",
  T_TAX_6 = "Tax Payments (6 Months)",
  R_TAX = "Tax Ratio (6m/12m)",
  R_TAX_INCOME = "Tax-to-Income Ratio",
  R_TAX_SAVINGS = "Tax-to-Savings Ratio",
  R_TAX_DEBT = "Tax-to-Debt Ratio",
  
  # --- TRAVEL ---
  T_TRAVEL_12 = "Travel Spending (12 Months)",
  T_TRAVEL_6 = "Travel Spending (6 Months)",
  R_TRAVEL = "Travel Ratio (6m/12m)",
  R_TRAVEL_INCOME = "Travel-to-Income Ratio",
  R_TRAVEL_SAVINGS = "Travel-to-Savings Ratio",
  R_TRAVEL_DEBT = "Travel-to-Debt Ratio",
  
  # --- UTILITIES ---
  T_UTILITIES_12 = "Utilities Spending (12 Months)",
  T_UTILITIES_6 = "Utilities Spending (6 Months)",
  R_UTILITIES = "Utilities Ratio (6m/12m)",
  R_UTILITIES_INCOME = "Utilities-to-Income Ratio",
  R_UTILITIES_SAVINGS = "Utilities-to-Savings Ratio",
  R_UTILITIES_DEBT = "Utilities-to-Debt Ratio",
  
  # --- TOTAL EXPENDITURE ---
  T_EXPENDITURE_12 = "Total Expenditure (12 Months)",
  T_EXPENDITURE_6 = "Total Expenditure (6 Months)",
  R_EXPENDITURE = "Expenditure Ratio (6m/12m)",
  R_EXPENDITURE_INCOME = "Expenditure-to-Income Ratio",
  R_EXPENDITURE_SAVINGS = "Expenditure-to-Savings Ratio",
  R_EXPENDITURE_DEBT = "Expenditure-to-Debt Ratio",
  
  # Categorical Flags
  CAT_GAMBLING = "Gambling Category",
  CAT_DEBT = "Has Debt",
  CAT_CREDIT_CARD = "Has Credit Card",
  CAT_MORTGAGE = "Has Mortgage",
  CAT_SAVINGS_ACCOUNT = "Has Savings Account",
  CAT_DEPENDENTS = "Has Dependents",
  
  # Targets
  CREDIT_SCORE = "Credit Score",
  DEFAULT = "Default Status"
)

# === Auto-format function for labels ===
format_label <- function(x) {
  if (x %in% names(pretty_labels)) {
    return(pretty_labels[[x]])
  }
  # fallback: title-case and spacing
  x <- gsub("_", " ", x)
  return(tools::toTitleCase(tolower(x)))
}


# Convert categorical variables to factors
credit_data$CAT_GAMBLING <- as.factor(credit_data$CAT_GAMBLING)
credit_data$CAT_DEBT <- as.factor(credit_data$CAT_DEBT)
credit_data$CAT_CREDIT_CARD <- as.factor(credit_data$CAT_CREDIT_CARD)
credit_data$CAT_MORTGAGE <- as.factor(credit_data$CAT_MORTGAGE)
credit_data$CAT_SAVINGS_ACCOUNT <- as.factor(credit_data$CAT_SAVINGS_ACCOUNT)
credit_data$CAT_DEPENDENTS <- as.factor(credit_data$CAT_DEPENDENTS)




# === Reactive Filter ===
filtered_credit <- reactive({
  data <- credit_data
  
  # Default filter
  if (input$default_filter == "Defaulted") {
    data <- subset(data, DEFAULT == 1)
  } else if (input$default_filter == "Not Defaulted") {
    data <- subset(data, DEFAULT == 0)
  }
  
  data
})

# === Dynamic Scatter Plot ===
output$score_scatter_plot <- renderPlot({
  data <- filtered_credit()
  xvar <- input$x_var
  yvar <- input$y_var
  
  plot(
    data[[xvar]], data[[yvar]],
    col = "#66003380", pch = 19,
    xlab = gsub("_", " ", xvar),
    ylab = gsub("_", " ", yvar),
    main = paste("Relationship between", gsub("_", " ", xvar), "and", gsub("_", " ", yvar)),
    family = "Trebuchet MS"
  )
  
  grid()
  abline(lm(data[[yvar]] ~ data[[xvar]]), col = "#006699", lwd = 2)
})
#HEATMAP
output$corr_heatmap <- renderPlot({
  
  
  numeric_cols <- credit_data[, sapply(credit_data, is.numeric)]
  corr_matrix <- cor(numeric_cols, use = "pairwise.complete.obs")
  
  # Pick the top 15 variables with greatest variance (informative)
  variances <- apply(numeric_cols, 2, var)
  top_vars <- names(sort(variances, decreasing = TRUE))[1:15]
  
  corr_small <- corr_matrix[top_vars, top_vars]
  
  # Rename for readability
  rownames(corr_small) <- sapply(rownames(corr_small), format_label)
  colnames(corr_small) <- sapply(colnames(corr_small), format_label)
  
  heatmap(
    corr_small,
    Colv = NA, Rowv = NA,
    col = colorRampPalette(c("#313695", "#4575b4", "#91bfdb", "#fee090"))(50),  # colorblind-safe
    scale = "none",
    margins = c(10, 10)
  )
})



#FOREST
library(randomForest)

output$feature_importance <- renderPlot({
  
  # Remove ID + DEFAULT (should not be used to predict CREDIT_SCORE)
  model_data <- credit_data[, !(names(credit_data) %in% c("CUST_ID", "DEFAULT"))]
  
  # Train RF
  rf_model <- randomForest(
    CREDIT_SCORE ~ ., 
    data = model_data,
    importance = TRUE,
    ntree = 300
  )
  
  # Extract importance
  importance_df <- data.frame(
    Feature = rownames(importance(rf_model)),
    IncMSE = importance(rf_model)[, "%IncMSE"]
  )
  
  # Top 15
  importance_df <- importance_df[order(importance_df$IncMSE, decreasing = TRUE), ]
  importance_df <- head(importance_df, 15)
  
  # Apply readable labels
  importance_df$Pretty <- sapply(importance_df$Feature, format_label)
  
  # Plot
  ggplot(importance_df, aes(x = IncMSE, y = reorder(Pretty, IncMSE))) +
    geom_point(color = "#1f77b4", size = 4) +
    theme_minimal(base_size = 13) +
    labs(
      title = "Top 15 Most Important Predictors of Credit Score",
      x = "% Increase in MSE",
      y = "Variable"
    )
})


# === Download Handler ===
output$download_credit_data <- downloadHandler(
  filename = function() {
    paste0("credit_score_data_", Sys.Date(), ".csv")
  },
  content = function(file) {
    write.csv(credit_data, file, row.names = FALSE)
  }
)
