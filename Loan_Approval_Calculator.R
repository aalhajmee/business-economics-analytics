#loan <- loan_approval
#loan_approval$points <- NULL
#loan_approval$name <- NULL
#loan_approval$city <- NULL
library(readxl)
loan_approval <- read_excel("Financial_Calculator_datasets/loan_approval.xlsx")
View(loan_approval)
loan_clean <- loan_approval[, -c(1, 2, 7)]
loan_clean$loan_approved <- as.numeric(loan_clean$loan_approved)
View(loan_clean)

calc_loan <- reactive({
  income <- input$inNumber
  credit_score <- input$inNumber2
  loan_amount <- input$inNumber3
  years_employed <- input$inNumber4
  
  if (is.null(income) || income <= 0) {
    return(list(probability = 0, approval_percent = "0.0%", approved = "Invalid Input"))
  }
  
  # Step 1: Train the model on your dataset
  train_model <- function(data) {  # Changed parameter name
    # Extract features (X) and labels (y)
    X <- as.matrix(data[, c("income", "credit_score", "loan_amount", "years_employed")])
    y <- data$loan_approved  # Changed from loan_clean$loan_approved
    
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
  
  # Step 2: Predict probability for new customer
  predict_approval <- function(model, income, credit_score, loan_amount, years_employed) {
    # Normalize the input using training data statistics
    features <- c(income, credit_score, loan_amount, years_employed)
    normalized <- (features - model$means) / model$stds
    
    # Calculate probability using trained weights
    z <- model$weights[1] + sum(normalized * model$weights[2:5])
    probability <- 1 / (1 + exp(-z))  # Sigmoid function
    
    return(probability)
  }
  
  # Train the model using loan_clean data
  model <- train_model(loan_clean)
  
  # Predict approval probability for user input
  probability <- predict_approval(model, income, credit_score, loan_amount, years_employed)
  
  # Return results
  return(list(
    probability = probability,
    approval_percent = sprintf("%.1f%%", probability * 100),
    approved = ifelse(probability >= 0.5, "Approved", "Not Approved")
  ))
})

output$approvalBox <- renderUI({
  tryCatch({
    result <- calc_loan()
    valueBox(
      value = result$approval_percent,
      subtitle = "Approval Probability",
      icon = icon("percentage"),
      color = ifelse(result$probability >= 0.5, "green", "red")
    )
  }, error = function(e) {
    valueBox(
      value = "Error",
      subtitle = paste("Error:", e$message),
      icon = icon("exclamation-triangle"),
      color = "red"
    )
  })
})

output$probabilityBox <- renderUI({
  tryCatch({
    result <- calc_loan()
    infoBox(
      title = "Probability Score",
      value = sprintf("%.3f", result$probability),
      subtitle = "Raw probability",
      icon = icon("calculator"),
      color = "blue"
    )
  }, error = function(e) {
    infoBox(
      title = "Error",
      value = "N/A",
      subtitle = paste("Error:", e$message),
      icon = icon("exclamation-triangle"),
      color = "red"
    )
  })
})

output$statusBox <- renderUI({
  tryCatch({
    result <- calc_loan()
    valueBox(
      value = result$approved,
      subtitle = "Loan Status",
      icon = icon(ifelse(result$probability >= 0.5, "check-circle", "times-circle")),
      color = ifelse(result$probability >= 0.5, "green", "red")
    )
  }, error = function(e) {
    valueBox(
      value = "Error",
      subtitle = paste("Error:", e$message),
      icon = icon("exclamation-triangle"),
      color = "red"
    )
  })
})