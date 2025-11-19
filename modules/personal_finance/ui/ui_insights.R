# =========================
# CREDIT ANALYTICS UI (NEW)
# =========================

tabPanel(
  title = "Credit Analytics",
  
  # === Header ===
  div(
    style = "padding: 10px 0 25px 0;",
    h3("Interactive Credit Score Analytics",
       style = "font-weight:600; text-align:center;"),
    p("Explore how income, savings, debt, and spending patterns shape credit scores and default risk.",
      style = "text-align:center; font-size:16px; color:#555;")
  ),
  
  fluidRow(
    # =============================
    # LEFT CONTROLS PANEL
    # =============================
    column(
      width = 4,
      div(
        style = "background:white; padding:20px; border-radius:10px; box-shadow:0 2px 6px rgba(0,0,0,0.1);",
        
        h4("Controls", style="margin-bottom:15px; font-weight:600;"),
        
        selectInput(
          "default_filter", "Filter by Default Status:",
          choices = c("All", "Defaulted", "Not Defaulted"),
          selected = "All"
        ),
        
        selectInput(
          "x_var", "Select X-Axis Variable:",
          choices = c(
            "Income" = "INCOME",
            "Savings" = "SAVINGS",
            "Debt" = "DEBT",
            "Savings-to-Income Ratio" = "R_SAVINGS_INCOME",
            "Debt-to-Income Ratio" = "R_DEBT_INCOME",
            "Debt-to-Savings Ratio" = "R_DEBT_SAVINGS",
            "Credit Score" = "CREDIT_SCORE"
          ),
          selected = "INCOME"
        ),
        
        selectInput(
          "y_var", "Select Y-Axis Variable:",
          choices = c(
            "Income" = "INCOME",
            "Savings" = "SAVINGS",
            "Debt" = "DEBT",
            "Savings-to-Income Ratio" = "R_SAVINGS_INCOME",
            "Debt-to-Income Ratio" = "R_DEBT_INCOME",
            "Debt-to-Savings Ratio" = "R_DEBT_SAVINGS",
            "Credit Score" = "CREDIT_SCORE"
          ),
          selected = "CREDIT_SCORE"
        ),
        
        br(),
        downloadButton(
          "download_credit_data",
          "Download Dataset",
          class="btn btn-primary",
          style="color:white; width:100%;"
        )
      )
    ),
    
    # =============================
    # RIGHT VISUAL OUTPUT PANEL
    # =============================
    column(
      width = 8,
      
      # SCATTER PLOT
      div(
        style = "background:white; padding:25px; border-radius:10px; 
                 margin-bottom:25px; box-shadow:0 2px 6px rgba(0,0,0,0.1);",
        h4("Credit Score Relationship Explorer",
           style="font-weight:600; margin-bottom:20px;"),
        plotOutput("score_scatter_plot", height="450px")
      ),
      
      # HEATMAP
      div(
        style = "background:white; padding:25px; border-radius:10px; 
                 margin-bottom:25px; box-shadow:0 2px 6px rgba(0,0,0,0.1);",
        h4("Correlation Heatmap", style="font-weight:600; margin-bottom:20px;"),
        p("Visualize relationships among key financial variables.",
          style="color:#666; margin-bottom:15px;"),
        plotOutput("corr_heatmap", height="550px")
      ),
      
      # FEATURE IMPORTANCE
      div(
        style = "background:white; padding:25px; border-radius:10px; 
                 box-shadow:0 2px 6px rgba(0,0,0,0.1);",
        h4("Feature Importance (Random Forest)",
           style="font-weight:600; margin-bottom:20px;"),
        p("Which financial features matter most in predicting credit score?",
          style="color:#666; margin-bottom:15px;"),
        plotOutput("feature_importance", height="550px")
      )
    )
  )
)
