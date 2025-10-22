library(glmnet)
library(tidyverse)
library(readxl)
loan_approval <- read_excel("Financial_Calculator_datasets/loan_approval.xlsx")

loans <- loan_approval

# Prepare training data without 'points'
x <- model.matrix(loan_approved ~ income + credit_score + loan_amount + years_employed, data = loans)[, -1]
y <- loans$loan_approved

# Fit regularized logistic regression (ridge regression)
cv_model <- cv.glmnet(x, y, family = "binomial")


# New applicant data (without points)
new_applicant <- data.frame(
  income = input$loan_income,           # Value from "Annual Income" box
  credit_score = input$loan_credit_score, # Value from "Credit Score" box
  loan_amount = input$loan_amount,      # Value from "Requested Loan Amount" box
  years_employed = input$loan_years_employed # Value from "Years Employed" box
)

# Convert new applicant to model matrix
new_x <- model.matrix(~ income + credit_score + loan_amount + years_employed, data = new_applicant)[, -1]

# Predict probability of approval
prob <- predict(cv_model, new_x, type = "response", s = "lambda.min")

# Print the result
cat(paste0("Predicted probability of loan approval: ", round(prob * 100, 2), "%\n"))




