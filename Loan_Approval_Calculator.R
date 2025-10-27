# Loans.R
# This script defines the UI and server logic for the loan approval calculator tab
# Make sure to source("loan_model.R") before using this module

library(tidyverse)
library(shinydashboard)

# UI Component
loan_ui <- tabItem(
  tabName = "loan",
  h2("Loan Approval Calculator"),
  br(),
  h3(""),
  img(src = "savingchart.png", height = "auto", width = "800px"),
  p("Enter your information and calculate your likelihood of getting approved for a loan."),
  
  fluidRow(
    column(5, wellPanel(
      numericInput("inNumber", "Income (after tax):",
                   min = 0, max = 1000000000, value = 50000, step = 1000),
      numericInput("inNumber2", "Credit Score:",
                   min = 300, max = 850, value = 650, step = 10),
      numericInput("inNumber3", "Loan Amount:",
                   min = 1000, max = 1000000000, value = 20000, step = 1000),
      numericInput("inNumber4", "Years Employed:",
                   min = 0, max = 100, value = 5, step = 1),
      actionButton("calculateBtn", "Calculate Approval Odds", 
                   class = "btn-primary", width = "100%"),
      br(), br(),
      actionButton("view_results", "View Detailed Results →", 
                   class = "btn-success", width = "100%"),
      p("*Enter your information to learn more about how to improve your chances of approval!")
    )),
    
    column(7, wellPanel(
      h4("Loan Approval Prediction"),
      uiOutput("approvalResult"),
      hr(),
      h4("Debt-to-Income Ratio"),
      uiOutput("dtiRatio"),
      hr(),
      h4("Recommendations"),
      uiOutput("recommendations")
    ))
  )
)

# Server Logic
loan_server <- function(input, output, session) {
  
  # Calculate loan approval probability using the trained glmnet model
  loan_approval <- reactive({
    req(input$calculateBtn)
    
    income <- input$inNumber
    credit_score <- input$inNumber2
    loan_amount <- input$inNumber3
    years_employed <- input$inNumber4
    
    # Use the prediction function from loan_model.R
    prob <- predict_loan_approval(income, credit_score, loan_amount, years_employed)
    
    # Calculate DTI for display purposes
    monthly_payment <- loan_amount * 0.01  # Rough estimate
    monthly_income <- income / 12
    dti <- if(monthly_income > 0) monthly_payment / monthly_income else 1
    
    list(
      probability = prob,
      dti = dti
    )
  })
  
  # Approval result display
  output$approvalResult <- renderUI({
    result <- loan_approval()
    prob_pct <- round(result$probability * 100, 1)
    
    color <- if(prob_pct >= 70) "green" else if(prob_pct >= 40) "orange" else "red"
    icon_name <- if(prob_pct >= 70) "check-circle" else if(prob_pct >= 40) "exclamation-circle" else "times-circle"
    
    div(
      tags$h3(
        icon(icon_name),
        paste0(prob_pct, "% Approval Probability"),
        style = paste0("color: ", color, ";")
      ),
      tags$p(
        if(prob_pct >= 70) {
          "Strong likelihood of approval! Your financial profile looks good."
        } else if(prob_pct >= 40) {
          "Moderate approval chances. Consider the recommendations below to improve your odds."
        } else {
          "Lower approval probability. Focus on improving key factors before applying."
        }
      )
    )
  })
  
  # DTI display
  output$dtiRatio <- renderUI({
    result <- loan_approval()
    dti_pct <- round(result$dti * 100, 1)
    
    dti_status <- if(dti_pct <= 30) {
      list(text = "Excellent", color = "green")
    } else if(dti_pct <= 40) {
      list(text = "Good", color = "orange")
    } else {
      list(text = "High", color = "red")
    }
    
    div(
      tags$p(
        strong("Current DTI: "),
        span(paste0(dti_pct, "%"), style = paste0("color: ", dti_status$color, "; font-size: 1.2em;")),
        " - ", dti_status$text
      ),
      tags$p("Lenders typically prefer a DTI below 40%. Lower is better!")
    )
  })
  
  # Recommendations
  output$recommendations <- renderUI({
    result <- loan_approval()
    income <- input$inNumber
    credit_score <- input$inNumber2
    loan_amount <- input$inNumber3
    
    recommendations <- list()
    
    if(credit_score < 700) {
      recommendations <- c(recommendations, 
                           "📊 Improve your credit score by paying bills on time and reducing credit card balances")
    }
    
    if(result$dti > 0.40) {
      recommendations <- c(recommendations,
                           "💰 Consider requesting a smaller loan amount to reduce your debt-to-income ratio")
    }
    
    if(input$inNumber4 < 2) {
      recommendations <- c(recommendations,
                           "💼 Build more employment history before applying for larger loans")
    }
    
    if(loan_amount > income * 0.5) {
      recommendations <- c(recommendations,
                           "🎯 Your loan amount is high relative to your income. Consider saving for a larger down payment")
    }
    
    if(length(recommendations) == 0) {
      recommendations <- c("✅ Your financial profile is strong! You're in good shape to apply.")
    }
    
    tags$ul(
      lapply(recommendations, function(rec) tags$li(rec))
    )
  })
  
}

# Export for use in main app
# In your main server.R, call: loan_server(input, output, session)
# In your main ui.R, include: loan_ui