# Loans.R
# This script defines the UI and server logic for the loan approval calculator tab

library(glmnet)
library(tidyverse)
library(readxl)

tabItem(tabName = "guide",
        h2("Savings Guide"),
        br(),
        h3("The 50, 30, 20 Rule"),
        img(src = "savingchart.png", height = "auto", width = "800px"),
        p("Enter your information and learn how to improve your financial health step-by-step."),
        p("Make sure to consistently use monthly or yearly values."),
        
        fluidRow(
          column(5, wellPanel(
            numericInput("inNumber", "Income (after tax):",
                         min = 0, max = 1000000000, value = 0, step = 1000),
            numericInput("inNumber2", "Rent or Mortgage Payments:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            numericInput("inNumber3", "Utility Bills:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            numericInput("inNumber4", "Healthcare:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            numericInput("inNumber5", "Insurance Payments:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            numericInput("inNumber6", "Other Needs*:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            p("*If you can honestly say 'I can’t live without it,' you have identified a need. Minimum required payments on a credit card or a loan also belong in this category")
          )),
          
          column(5, wellPanel(
            numericInput("inNumber7", "Subscriptions:",
                         min = 0, max = 1000000000, value = 0, step = 10),
            numericInput("inNumber8", "Dining Out:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            numericInput("inNumber9", "Entertainment:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            numericInput("inNumber10", "Shopping:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            numericInput("inNumber11", "Travel:",
                         min = 0, max = 1000000000, value = 0, step = 100)
          ))
        ),
        
        br(),
        #Current budget
        h3("Your Current Spending (Based on Your Inputs)"),
        fluidRow(
          column(4, uiOutput("needsBox")),    # instead of static wellPanel
          column(4, uiOutput("wantsBox")),
          column(4, uiOutput("savingsBox"))
        ),
        
        # Recommended Budget Section
        h3("Your Recommended Budget"),
        fluidRow(
          column(4, wellPanel(
            h4("Needs (50%)"),
            textOutput("needs_out")
          )),
          column(4, wellPanel(
            h4("Wants (30%)"),
            textOutput("wants_out")
          )),
          column(4, wellPanel(
            h4("Savings (20%)"),
            textOutput("savings_out")
          ))
        )
)