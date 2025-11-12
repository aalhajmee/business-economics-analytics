# === INTERACTIVE FINANCIAL TRENDS TAB ===
tabItem(
  tabName = "data_insights",
  
  h2("Explore Financial Relationships",
     style = "text-align:center; font-family:'Trebuchet MS'; font-weight:600;"),
  p("Choose variables to explore correlations between key financial factors such as income, savings, credit score, and debt.",
    style = "text-align:center; font-size:16px; color:#555;"),
  br(),
  
  # --- Filters and Variable Selectors ---
  fluidRow(
    column(3,
           selectInput("region_filter", "Filter by Region:",
                       choices = c("All", unique(finance_data$region)), selected = "All")
    ),
    column(3,
           selectInput("loan_filter", "Filter by Loan Type:",
                       choices = c("All", unique(finance_data$loan_type)), selected = "All")
    ),
    column(3,
           selectInput("x_var", "Select X-Axis Variable:",
                       choices = c("Monthly Income" = "monthly_income_usd",
                                   "Monthly Expenses" = "monthly_expenses_usd",
                                   "Savings" = "savings_usd",
                                   "Debt-to-Income Ratio" = "debt_to_income_ratio",
                                   "Savings-to-Income Ratio" = "savings_to_income_ratio",
                                   "Loan Amount" = "loan_amount_usd",
                                   "Credit Score" = "credit_score"),
                       selected = "monthly_income_usd")
    ),
    column(3,
           selectInput("y_var", "Select Y-Axis Variable:",
                       choices = c("Monthly Income" = "monthly_income_usd",
                                   "Monthly Expenses" = "monthly_expenses_usd",
                                   "Savings" = "savings_usd",
                                   "Debt-to-Income Ratio" = "debt_to_income_ratio",
                                   "Savings-to-Income Ratio" = "savings_to_income_ratio",
                                   "Loan Amount" = "loan_amount_usd",
                                   "Credit Score" = "credit_score"),
                       selected = "savings_usd")
    )
  ),
  br(),
  
  # --- Main Scatter Plot ---
  fluidRow(
    box(
      title = "Financial Correlation Explorer",
      width = 12, solidHeader = TRUE, status = "info",
      plotOutput("scatter_plot", height = "450px"),
    downloadButton("download_data", "Download Dataset", class = "btn btn-primary",
                       style = "color:white; background-color:#0073e6; border:none; font-weight:400;")
    ))
  )



