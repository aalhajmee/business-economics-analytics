# Loans.R
# This script defines the UI and server logic for the loan approval calculator tab
library(shinydashboard)
library(readxl)
library(glmnet)

# ---- UI SECTION ----
loan_ui <- tabItem(
  tabName = "loan",
  h2("Loan Approval Calculator"),
  br(),
  p("Enter your information and calculate your likelihood of getting approved for a loan."),
  p("Our model uses machine learning trained on real loan approval data to predict your chances."),
  
  fluidRow(
    column(5, wellPanel(
      h4("Applicant Information"),
      numericInput("loan_income", "Annual Income (after tax) ($):",
                   min = 0, max = 10000000, value = 50000, step = 5000),
      numericInput("loan_credit_score", "Credit Score:",
                   min = 300, max = 800, value = 700, step = 10),
      numericInput("loan_amount", "Requested Loan Amount ($):",
                   min = 0, max = 1000000, value = 20000, step = 1000),
      numericInput("loan_years_employed", "Years Employed:",
                   min = 0, max = 50, value = 5, step = 1),
      p(style = "color: #666; font-size: 12px;", 
        "*All fields are required for accurate prediction")
    ))
  ),
  
  br(),
  
  # Main Results Section
  h3("Loan Approval Prediction"),
  fluidRow(
    column(12, uiOutput("loan_result_box"))
  ),
  
  br(),
  
  # Additional Metrics
  h3("Financial Health Metrics"),
  fluidRow(
    column(4, uiOutput("dti_box")),
    column(4, uiOutput("income_ratio_box")),
    column(4, uiOutput("credit_status_box"))
  ),
  
  br(),
  
  # Recommendations Section
  fluidRow(
    column(12, wellPanel(
      h4(icon("lightbulb"), " Personalized Recommendations"),
      uiOutput("recommendations")
    ))
  ),
  
  br(),
  
  # Budget Planning Section (50/30/20 Rule)
  h3("Suggested Budget Based on Your Income"),
  p("Following the 50/30/20 rule can help you manage loan payments alongside your other financial goals."),
  fluidRow(
    column(4, uiOutput("needsBox")),
    column(4, uiOutput("wantsBox")),
    column(4, uiOutput("savingsBox"))
  )
)

# ---- SERVER LOGIC SECTION ----
loan_server <- function(input, output, session, loan_approval) {
  
  # Fit the model (reactive, updates if data changes)
  loan_model <- reactive({
    req(loan_approval)
    
    # Prepare training data without 'points'
    x <- model.matrix(loan_approved ~ income + credit_score + loan_amount + years_employed, 
                      data = loan_approval)[, -1]
    y <- loan_approval$loan_approved
    
    # Fit regularized logistic regression (ridge regression)
    cv_model <- cv.glmnet(x, y, family = "binomial")
    
    return(cv_model)
  })
  
  # Calculate loan approval probability
  loan_probability <- reactive({
    req(input$loan_income, input$loan_credit_score, 
        input$loan_amount, input$loan_years_employed)
    
    # New applicant data (without points)
    new_applicant <- data.frame(
      income = input$loan_income,
      credit_score = input$loan_credit_score,
      loan_amount = input$loan_amount,
      years_employed = input$loan_years_employed
    )
    
    # Convert new applicant to model matrix
    new_x <- model.matrix(~ income + credit_score + loan_amount + years_employed, 
                          data = new_applicant)[, -1]
    
    # Predict probability of approval
    prob <- predict(loan_model(), new_x, type = "response", s = "lambda.min")
    
    return(as.numeric(prob))
  })
  
  # Render the approval probability output
  output$loan_approval_probability <- renderText({
    prob <- loan_probability()
    paste0("Predicted probability of loan approval: ", round(prob * 100, 2), "%")
  })
  
  # Render color-coded result box
  output$loan_result_box <- renderUI({
    prob <- loan_probability()
    
    # Determine status based on probability
    status <- if (prob >= 0.7) {
      "success"  # Green for high approval chance
    } else if (prob >= 0.4) {
      "warning"  # Yellow for moderate chance
    } else {
      "danger"   # Red for low chance
    }
    
    # Determine message
    message <- if (prob >= 0.7) {
      "Strong likelihood of approval!"
    } else if (prob >= 0.4) {
      "Moderate chance - consider improving your profile"
    } else {
      "Low approval probability - work on your credit/income"
    }
    
    box(
      title = "Loan Approval Prediction",
      status = status,
      solidHeader = TRUE,
      width = NULL,
      h3(paste0(round(prob * 100, 1), "%")),
      p(message),
      hr(),
      p(style = "font-size: 13px; color: #666;",
        "Based on income, credit score, loan amount, and employment history")
    )
  })
  
  # Additional outputs can be added here for dti_box, income_ratio_box, 
  # credit_status_box, recommendations, needsBox, wantsBox, savingsBox
}