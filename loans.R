tabItem(tabName = "loans",
        h2("Loan Calculator"),
        br(),
        p("Enter your information and calculate the likelihood of being accepted for a loan."),
        p("Please answer in dollars and years."),
        
        fluidRow(
          column(5, wellPanel(
            numericInput("inNumber", "Income (after tax):",
                         min = 0, max = 1000000000, value = 50000, step = 1000),
            numericInput("inNumber2", "Credit Score:",
                         min = 300, max = 850, value = 650, step = 10),
            numericInput("inNumber3", "Loan Amount:",
                         min = 0, max = 1000000000, value = 10000, step = 1000),
            numericInput("inNumber4", "Years Employed:",
                         min = 0, max = 100, value = 10, step = 1),
          ))),
        
        br(),
        #Current budget
        h3("Your Likelihood of Getting Approved"),
        fluidRow(
          column(4, uiOutput("approvalBox")),  # Changed from "needsBox" to "approvalBox"
          column(4, uiOutput("probabilityBox")),  # Additional box for probability percentage
          column(4, uiOutput("statusBox"))  # Additional box for approval status
        )
)
          