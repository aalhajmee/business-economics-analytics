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
    normalized <- (features - model$means) / model$stds
    
    # Calculate probability using trained weights
    z <- model$weights[1] + sum(normalized * model$weights[2:5])
    probability <- 1 / (1 + exp(-z))  # Sigmoid function
    
    return(probability)
  }
  
  # Train the model once (could be cached, but training is fast)
  trained_model <- train_model(loan_clean)
  
  # Reactive loan calculation - Auto-updates on input change
  loan_data <- reactive({
    req(input$loan_amount, input$loan_rate, input$loan_term, input$loan_income, input$loan_score, input$loan_years_employed)
    
    P <- input$loan_amount
    r <- (input$loan_rate / 100) / 12
    n <- input$loan_term * 12
    
    # Monthly Payment Formula: M = P [ i(1 + i)^n ] / [ (1 + i)^n – 1]
    if (r > 0) {
      monthly_payment <- P * (r * (1 + r)^n) / ((1 + r)^n - 1)
    } else {
      monthly_payment <- P / n
    }
    
    total_cost <- monthly_payment * n
    total_interest <- total_cost - P
    
    # Calculate Debt-to-Income Ratio (DTI)
    monthly_income <- input$loan_income / 12
    dti <- if(monthly_income > 0) (monthly_payment / monthly_income) * 100 else 100
    
    # Predict approval probability using trained gradient descent model
    prob <- predict_approval(
      trained_model,
      input$loan_income,
      input$loan_score,
      P,
      input$loan_years_employed
    )
    
    # Generate amortization schedule
    balance <- P
    amort_list <- list()
    
    for(i in 1:min(n, 360)) {  # Limit to 30 years for display
      interest_payment <- balance * r
      principal_payment <- monthly_payment - interest_payment
      balance <- max(0, balance - principal_payment)
      
      amort_list[[i]] <- data.frame(
        Month = i,
        Payment = monthly_payment,
        Principal = principal_payment,
        Interest = interest_payment,
        Balance = balance
      )
    }
    
    amort_schedule <- do.call(rbind, amort_list)
    
    list(
      monthly = monthly_payment,
      total = total_cost,
      interest = total_interest,
      prob = prob,
      dti = dti,
      amort = amort_schedule
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
    
    dti_color <- if(res$dti <= 30) "#10b981" else if(res$dti <= 40) "#f59e0b" else "#ef4444"
    dti_status <- if(res$dti <= 30) "Excellent" else if(res$dti <= 40) "Good" else "High"
    
    tagList(
      div(class = "alert alert-info",
        h5("Payment Details"),
        tags$ul(
          tags$li(strong("Monthly Payment:"), " ", scales::dollar(res$monthly)),
          tags$li(strong("Total Interest:"), " ", scales::dollar(res$interest)),
          tags$li(strong("Total Cost:"), " ", scales::dollar(res$total)),
          tags$li(strong("Debt-to-Income Ratio:"), " ", paste0(round(res$dti, 1), "%"))
        )
      ),
      div(class = paste0("alert alert-", color),
        h5(bs_icon(icon_name), " ", paste0(prob_pct, "% Approval Probability")),
        p(class = "mb-0", approval_text)
      ),
      div(class = "alert alert-secondary",
        h5("Debt-to-Income Ratio"),
        p(class = "mb-1",
          strong("Current DTI: "),
          span(paste0(round(res$dti, 1), "%"), style = paste0("color: ", dti_color, "; font-size: 1.2em;")),
          " - ", dti_status
        ),
        p(class = "mb-0 small", "Lenders typically prefer a DTI below 40%. Lower is better!")
      ),
      uiOutput("loan_recommendations")
    )
  })
  
  output$loan_recommendations <- renderUI({
    res <- loan_data()
    recommendations <- character(0)
    
    if(input$loan_score < 700) {
      recommendations <- c(recommendations, 
                           "Improve your credit score by paying bills on time and reducing credit card balances")
    }
    
    if(res$dti > 40) {
      recommendations <- c(recommendations,
                           "Consider requesting a smaller loan amount to reduce your debt-to-income ratio")
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
  
  # Amortization Plot
  output$loan_plot <- renderPlotly({
    res <- loan_data()
    
    # Sample every 12th month for cleaner plot
    plot_data <- res$amort[seq(1, nrow(res$amort), by = 12), ]
    
    p <- plot_ly(plot_data, x = ~Month / 12) %>%
      add_trace(y = ~Balance, name = 'Remaining Balance', type = 'scatter', mode = 'lines',
                line = list(color = '#2563eb', width = 3), fill = 'tozeroy', fillcolor = 'rgba(37, 99, 235, 0.1)') %>%
      layout(
        title = list(text = "Loan Balance Over Time", font = list(color = "#1e293b", size = 18)),
        xaxis = list(title = "Years"),
        yaxis = list(title = "Balance ($)", tickformat = "$,"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      )
    
    p
  })
  
  # Amortization Schedule Table
  output$loan_amort_table <- renderDT({
    res <- loan_data()
    req(res, nrow(res$amort) > 0)
    
    # Show first 12 months and last 12 months (if loan is longer than 24 months)
    n <- nrow(res$amort)
    if (n > 24) {
      display_data <- rbind(
        res$amort[1:12, ],
        data.frame(Month = "...", Payment = NA, Principal = NA, Interest = NA, Balance = NA),
        res$amort[(n-11):n, ]
      )
    } else {
      display_data <- res$amort
    }
    
    display_data %>%
      mutate(
        Payment = ifelse(is.na(Payment), "...", scales::dollar(Payment)),
        Principal = ifelse(is.na(Principal), "...", scales::dollar(Principal)),
        Interest = ifelse(is.na(Interest), "...", scales::dollar(Interest)),
        Balance = ifelse(is.na(Balance), "...", scales::dollar(Balance))
      ) %>%
      datatable(
        options = list(
          pageLength = 12, 
          dom = 't', 
          scrollX = TRUE,
          scrollCollapse = TRUE,
          autoWidth = FALSE,
          columnDefs = list(list(width = '80px', targets = c(0, 1, 2, 3, 4)))
        ),
        rownames = FALSE,
        colnames = c("Month", "Payment", "Principal", "Interest", "Remaining Balance"),
        class = "display nowrap"
      )
  })
}
