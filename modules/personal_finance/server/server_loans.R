# ============================================================================
# Loan Calculator - Server Logic
# ============================================================================

loans_server <- function(input, output, session) {
  
  # Load loan approval training data
  loan_approval_path <- "data/loan/loan_approval.xlsx"
  
  if (!file.exists(loan_approval_path)) {
    stop("Loan approval data not found! Please ensure data/loan/loan_approval.xlsx exists.")
  }
  
  loan_approval <- read_excel(loan_approval_path)
  loan_clean <- loan_approval[, -c(1, 2, 7)]  # Remove name, city, points columns
  loan_clean$loan_approved <- as.numeric(loan_clean$loan_approved)
  
  # Train model function using gradient descent
  train_model <- function(data) {
    # Extract features (X) and labels (y)
    X <- as.matrix(data[, c("income", "credit_score", "loan_amount", "years_employed")])
    y <- data$loan_approved
    
    # Normalize features (important for gradient descent)
    means <- colMeans(X)
    stds <- apply(X, 2, sd)
    X_norm <- scale(X, center = means, scale = stds)
    
    # Gradient descent to find weights
    weights <- rep(0, 5)  # bias + 4 features
    learning_rate <- 0.1
    iterations <- 1000
    
    for (iter in 1:iterations) {
      gradients <- rep(0, 5)
      
      for (i in 1:nrow(X_norm)) {
        features <- c(1, X_norm[i, ])
        z <- sum(features * weights)
        prediction <- 1 / (1 + exp(-z))  # Sigmoid function
        error <- prediction - y[i]
        
        gradients <- gradients + error * features
      }
      
      weights <- weights - (learning_rate / nrow(X_norm)) * gradients
    }
    
    return(list(weights = weights, means = means, stds = stds))
  }
  
  # Predict probability function
  predict_approval <- function(model, income, credit_score, loan_amount, years_employed) {
    # Normalize the input using training data statistics
    features <- c(income, credit_score, loan_amount, years_employed)
    # Handle zero standard deviation (constant features in training)
    normalized <- ifelse(model$stds == 0, 0, (features - model$means) / model$stds)
    
    # Calculate probability using trained weights
    z <- model$weights[1] + sum(normalized * model$weights[2:5])
    probability <- 1 / (1 + exp(-z))  # Sigmoid function
    
    return(probability)
  }
  
  # Train the model once (could be cached, but training is fast)
  trained_model <- train_model(loan_clean)
  
  # Reactive loan calculation - Auto-updates on input change
  loan_data <- reactive({
    req(input$loan_amount, input$loan_income, input$loan_score, input$loan_years_employed)
    
    P <- input$loan_amount
    
    # Predict approval probability using trained gradient descent model
    prob <- predict_approval(
      trained_model,
      input$loan_income,
      input$loan_score,
      P,
      input$loan_years_employed
    )
    
    list(
      prob = prob
    )
  })
  
  output$loan_summary <- renderUI({
    res <- loan_data()
    req(res)
    
    prob_pct <- round(res$prob * 100, 1)
    
    color <- if(prob_pct >= 70) "success" else if(prob_pct >= 40) "warning" else "danger"
    icon_name <- if(prob_pct >= 70) "check-circle" else if(prob_pct >= 40) "exclamation-circle" else "x-circle"
    
    approval_text <- if(prob_pct >= 70) {
      "Strong likelihood of approval! Your financial profile looks good."
    } else if(prob_pct >= 40) {
      "Moderate approval chances. Consider the recommendations below to improve your odds."
    } else {
      "Lower approval probability. Focus on improving key factors before applying."
    }
    
    tagList(
      div(class = paste0("alert alert-", color),
          h5(bs_icon(icon_name), " ", paste0(prob_pct, "% Approval Probability")),
          p(class = "mb-0", approval_text)
      ),
      uiOutput("loan_recommendations")
    )
  })
  
  output$loan_recommendations <- renderUI({
    recommendations <- character(0)
    
    if(input$loan_score < 700) {
      recommendations <- c(recommendations, 
                           "Improve your credit score by paying bills on time and reducing credit card balances")
    }
    
    if(input$loan_years_employed < 2) {
      recommendations <- c(recommendations,
                           "Build more employment history before applying for larger loans")
    }
    
    if(input$loan_amount > input$loan_income * 0.5) {
      recommendations <- c(recommendations,
                           "Your loan amount is high relative to your income. Consider saving for a larger down payment")
    }
    
    if(length(recommendations) == 0) {
      recommendations <- "Your financial profile is strong! You're in good shape to apply."
    }
    
    div(class = "alert alert-info",
        h5("Recommendations"),
        tags$ul(
          lapply(recommendations, function(rec) tags$li(rec))
        )
    )
  })
  
  # Amortization Plot - Removed
  output$loan_plot <- renderPlotly({
    plot_ly() %>%
      layout(
        title = list(text = "Loan analysis visualization", font = list(color = "#1e293b", size = 18)),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
  })
  
  # Amortization Schedule Table - Removed
  output$loan_amort_table <- renderDT({
    datatable(
      data.frame(
        Message = "Amortization schedule requires interest rate and loan term inputs"
      ),
      options = list(dom = 't', pageLength = 1)
    )
  })
  
}