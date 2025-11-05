# Loans.R
# This script defines the UI and server logic for the loan approval calculator tab
library(shiny)
library(glmnet)
library(tidyverse)
library(readxl)
library(shinydashboard)

# UI Component
loan_ui <- tabItem(
  tabName = "loans",
  h2("Loan Approval Calculator",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  h3(""),
  p("Enter your information and calculate your likelihood of getting approved for a loan."),
  
  fluidRow(
    column(5, wellPanel(
      numericInput("loan_income", "Income (after tax):",
                   min = 0, max = 1000000000, value = 50000, step = 1000),
      numericInput("loan_credit_score", "Credit Score:",
                   min = 300, max = 850, value = 650, step = 10),
      numericInput("loan_amount_input", "Loan Amount:",
                   min = 1000, max = 1000000000, value = 20000, step = 1000),
      numericInput("loan_years_employed", "Years Employed:",
                   min = 0, max = 100, value = 5, step = 1),
      actionButton("calculateBtn", "Calculate Approval Odds", 
                   class = "btn-primary", width = "100%"),
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
  
  # Calculate loan approval probability
  loan_approval <- reactive({
    req(input$calculateBtn)
    
    income <- input$loan_income
    credit_score <- input$loan_credit_score
    loan_amount <- input$loan_amount_input
    years_employed <- input$loan_years_employed
    
    # Simple scoring model (replace with your glmnet model if you have trained data)
    # This uses a basic heuristic approach
    
    # Credit score component (0-40 points)
    credit_points <- case_when(
      credit_score >= 750 ~ 40,
      credit_score >= 700 ~ 30,
      credit_score >= 650 ~ 20,
      credit_score >= 600 ~ 10,
      TRUE ~ 0
    )
    
    # Debt-to-income ratio component (0-30 points)
    # Assuming monthly payments of ~1% of loan amount
    monthly_payment <- loan_amount * 0.01
    monthly_income <- income / 12
    dti <- if(monthly_income > 0) monthly_payment / monthly_income else 1
    
    dti_points <- case_when(
      dti <= 0.20 ~ 30,
      dti <= 0.30 ~ 20,
      dti <= 0.40 ~ 10,
      TRUE ~ 0
    )
    
    # Employment stability (0-20 points)
    employment_points <- case_when(
      years_employed >= 5 ~ 20,
      years_employed >= 3 ~ 15,
      years_employed >= 1 ~ 10,
      TRUE ~ 5
    )
    
    # Income sufficiency (0-10 points)
    income_points <- if(income >= loan_amount * 0.3) 10 else 5
    
    total_score <- credit_points + dti_points + employment_points + income_points
    probability <- min(total_score / 100, 0.95) # Cap at 95%
    
    list(
      probability = probability,
      dti = dti,
      credit_points = credit_points,
      dti_points = dti_points,
      employment_points = employment_points
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
    income <- input$loan_income
    credit_score <- input$loan_credit_score
    loan_amount <- input$loan_amount_input
    
    recommendations <- list()
    
    if(credit_score < 700) {
      recommendations <- c(recommendations, 
                           "Improve your credit score by paying bills on time and reducing credit card balances")
    }
    
    if(result$dti > 0.40) {
      recommendations <- c(recommendations,
                           "Consider requesting a smaller loan amount to reduce your debt-to-income ratio")
    }
    
    if(input$loan_years_employed < 2) {
      recommendations <- c(recommendations,
                           "Build more employment history before applying for larger loans")
    }
    
    if(loan_amount > income * 0.5) {
      recommendations <- c(recommendations,
                           "Your loan amount is high relative to your income. Consider saving for a larger down payment")
    }
    
    if(length(recommendations) == 0) {
      recommendations <- c("Your financial profile is strong! You're in good shape to apply.")
    }
    
    tags$ul(
      lapply(recommendations, function(rec) tags$li(rec))
    )
  })
}

# Return the UI component for safe_source_tab
loan_ui