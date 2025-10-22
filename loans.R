# Loan_Approval_Calculator.R
# This script defines the UI and server logic for the loan approval calculator tab

library(glmnet)
library(tidyverse)
library(readxl)

# Load and prepare data once when script is sourced
loan_approval <- read_excel("Financial_Calculator_datasets/loan_approval.xlsx")

# Prepare training data
x <- model.matrix(loan_approved ~ income + credit_score + loan_amount + years_employed, 
                  data = loan_approval)[, -1]
y <- loan_approval$loan_approved

# Fit regularized logistic regression (ridge regression)
cv_model <- cv.glmnet(x, y, family = "binomial")

# Define UI for this tab
loan <- tabPanel(
  "Loan Approval",
  
  sidebarLayout(
    sidebarPanel(
      h4("Enter Applicant Information"),
      
      numericInput("loan_income", 
                   "Annual Income ($):", 
                   value = 00000, 
                   min = 0,
                   step = 1000),
      
      numericInput("loan_credit_score", 
                   "Credit Score:", 
                   value = 300, 
                   min = 300, 
                   max = 850,
                   step = 10),
      
      numericInput("loan_amount", 
                   "Requested Loan Amount ($):", 
                   value = 00000, 
                   min = 0,
                   step = 1000),
      
      numericInput("loan_years_employed", 
                   "Years Employed:", 
                   value = 0, 
                   min = 0,
                   step = 1),
      
      br(),
      
      actionButton("loan_calculate", 
                   "Calculate Approval Odds", 
                   class = "btn-primary btn-lg",
                   style = "width: 100%;")
    ),
    
    mainPanel(
      h3("Loan Approval Prediction"),
      
      uiOutput("loan_result_box"),
      
      br(),
      
      plotOutput("loan_probability_plot", height = "250px"),
      
      br(),
      
      h5("Model Information"),
      p("This prediction is based on a regularized logistic regression model 
        trained on historical loan approval data.")
    )
  )
)

# Define server logic for this tab
# This function will be called from your main server function
loan_server <- function(input, output, session) {
  
  # Calculate loan approval probability
  calculate_probability <- eventReactive(input$loan_calculate, {
    
    # Create new applicant data frame
    new_applicant <- data.frame(
      income = input$loan_income,
      credit_score = input$loan_credit_score,
      loan_amount = input$loan_amount,
      years_employed = input$loan_years_employed
    )
    
    # Convert to model matrix
    new_x <- model.matrix(~ income + credit_score + loan_amount + years_employed, 
                          data = new_applicant)[, -1]
    
    # Predict probability of approval
    prob <- predict(cv_model, new_x, type = "response", s = "lambda.min")
    
    return(as.numeric(prob) * 100)
  })
  
  # Display result with color coding
  output$loan_result_box <- renderUI({
    prob <- calculate_probability()
    
    # Determine color based on probability
    color <- if (prob >= 70) {
      "success"
    } else if (prob >= 40) {
      "warning"
    } else {
      "danger"
    }
    
    # Determine message
    message <- if (prob >= 70) {
      "Strong likelihood of approval"
    } else if (prob >= 40) {
      "Moderate chance of approval"
    } else {
      "Low likelihood of approval"
    }
    
    div(
      class = paste0("alert alert-", color),
      style = "font-size: 20px; text-align: center; padding: 25px;",
      h2(paste0(round(prob, 2), "%"), style = "margin: 10px 0;"),
      p(strong("Predicted Probability of Loan Approval")),
      hr(),
      p(message, style = "font-size: 16px;")
    )
  })
  
  # Visualization
  output$loan_probability_plot <- renderPlot({
    prob <- calculate_probability()
    
    # Create a simple bar chart
    par(mar = c(4, 6, 3, 2))
    barplot(c(prob, 100 - prob), 
            horiz = TRUE,
            col = c("#5cb85c", "#d9534f"),
            xlim = c(0, 100),
            names.arg = c("Approval\nProbability", "Rejection\nProbability"),
            las = 1,
            main = "Approval vs. Rejection Probability",
            xlab = "Percentage (%)",
            cex.names = 1.1,
            cex.axis = 1.1)
    
    # Add percentage labels on bars
    text(x = c(prob/2, prob + (100-prob)/2), 
         y = c(0.7, 1.9), 
         labels = paste0(round(c(prob, 100-prob), 1), "%"),
         cex = 1.3,
         col = "white",
         font = 2)
  })
}