# === INTERACTIVE CREDIT SCORE ANALYTICS TAB ===
tabItem(
  tabName = "data_insights",
  
  h2("Explore Credit Score & Financial Relationships",
     style = "text-align:center; font-family:'Trebuchet MS'; font-weight:600;"),
  p("Use this dashboard to explore how income, savings, debt, and spending patterns relate to credit score and default risk.",
    style = "text-align:center; font-size:16px; color:#555;"),
  br(),
  
  # --- Filters and Variable Selectors ---
  fluidRow(
    column(4,
           selectInput("default_filter", "Filter by Default Status:",
                       choices = c("All", "Defaulted", "Not Defaulted"),
                       selected = "All")
    ),
    column(4,
           selectInput("x_var", "Select X-Axis Variable:",
                       choices = c(
                         "Income" = "INCOME",
                         "Savings" = "SAVINGS",
                         "Debt" = "DEBT",
                         "Savings-to-Income Ratio" = "R_SAVINGS_INCOME",
                         "Debt-to-Income Ratio" = "R_DEBT_INCOME",
                         "Debt-to-Savings Ratio" = "R_DEBT_SAVINGS",
                         "Credit Score" = "CREDIT_SCORE"
                       ),
                       selected = "INCOME")
    ),
    column(4,
           selectInput("y_var", "Select Y-Axis Variable:",
                       choices = c(
                         "Income" = "INCOME",
                         "Savings" = "SAVINGS",
                         "Debt" = "DEBT",
                         "Savings-to-Income Ratio" = "R_SAVINGS_INCOME",
                         "Debt-to-Income Ratio" = "R_DEBT_INCOME",
                         "Debt-to-Savings Ratio" = "R_DEBT_SAVINGS",
                         "Credit Score" = "CREDIT_SCORE"
                       ),
                       selected = "CREDIT_SCORE")
    )
  ),
  
  br(),
  
  # --- Main Scatter Plot ---
  fluidRow(
    box(
      title = "Credit Score & Financial Correlation Explorer",
      width = 12, solidHeader = TRUE, status = "info",
      plotOutput("score_scatter_plot", height = "450px"),
    )
  ),
  # === ADDITIONAL ANALYTICS PANELS ===
  
  # ---- Correlation Heatmap ----
  fluidRow(
    box(
      title = "Correlation Heatmap",
      width = 12, solidHeader = TRUE, status = "primary",
      
      # --- Description Text ---
      p("This heatmap visualizes how strongly each financial variable is related to the others. 
       Each cell represents the correlation coefficient between two features, ranging from -1 (strong negative relationship) 
       to +1 (strong positive relationship). Darker colors indicate stronger relationships, while lighter colors indicate weaker ones. 
       Use this chart to identify patterns, interactions, and key relationships across income, savings, debt, spending, and risk ratios.",
        style = "font-size:15px; color:#444; margin-bottom:15px;"),
      
      plotOutput("corr_heatmap", height = "550px")
    )
  ),
  
  # ---- Feature Importance ----
  fluidRow(
    box(
      title = "Feature Importance (Random Forest)",
      width = 12, solidHeader = TRUE, status = "warning",
      
      # --- Description Text ---
      p("This chart ranks financial variables based on how strongly they influence credit score predictions in a Random Forest model. 
       Variables at the top contribute the most to reducing model error, making them the most important predictors. 
       This visualization helps identify which financial behaviors—such as debt levels, income, savings, or specific spending categories—
       matter most in shaping a customer’s credit score.",
        style = "font-size:15px; color:#444; margin-bottom:15px;"),
      
      plotOutput("feature_importance", height = "550px")
    )
  ),
  
  fluidRow(
    downloadButton("download_credit_data", "Download Dataset",
                   class = "btn btn-primary",
                   style = "color:white; background-color:#0073e6; border:none; font-weight:400;")
  )
  
  )
  
