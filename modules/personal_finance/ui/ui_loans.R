# ============================================================================
# Loan Calculator - UI Component
# ============================================================================

loans_ui <- function() {
  fluidRow(
    column(12,
      card(
        card_header("Loan Calculator"),
        p("Calculate monthly payments, total interest, and loan approval probability using logistic regression analysis.")
      )
    ),
    column(4,
      card(
        card_header("Loan Details"),
        numericInput("loan_amount", "Loan Amount ($):", value = 25000, min = 0, step = 1000),
        sliderInput("loan_rate", "Annual Interest Rate (%):", min = 0.1, max = 25, value = 5, step = 0.1),
        sliderInput("loan_term", "Loan Term (Years):", min = 1, max = 30, value = 5, step = 1),
        hr(),
        h6("Borrower Profile (for approval estimate)"),
        numericInput("loan_income", "Income (after tax):", value = 50000, min = 0, step = 1000),
        numericInput("loan_score", "Credit Score:", min = 300, max = 850, value = 650, step = 10),
        numericInput("loan_years_employed", "Years Employed:", min = 0, max = 100, value = 5, step = 1)
      )
    ),
    column(8,
      card(
        card_header("Payment Analysis"),
        htmlOutput("loan_summary"),
        hr(),
        plotlyOutput("loan_plot", height = "400px")
      ),
      card(
        card_header("Amortization Schedule"),
        div(style = "overflow-x: auto; max-width: 100%;",
          DTOutput("loan_amort_table")
        )
      )
    )
  )
}
