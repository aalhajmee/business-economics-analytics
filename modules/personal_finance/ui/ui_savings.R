# ============================================================================
# Savings Calculator - UI Component
# ============================================================================

savings_ui <- function() {
  fluidRow(
    column(12,
      card(
        card_header("Savings Calculator"),
        p("Project the growth of your savings over time with compound interest. Get personalized savings rate recommendations based on your income level.")
      )
    ),
    column(4,
      card(
        card_header("Inputs"),
        numericInput("sav_current", "Current Savings ($):", value = 5000, min = 0, step = 100),
        numericInput("sav_monthly", "Monthly Contribution ($):", value = 500, min = 0, step = 50),
        sliderInput("sav_rate", "Annual Interest Rate (%):", min = 0, max = 15, value = 5, step = 0.1),
        sliderInput("sav_years", "Years to Grow:", min = 1, max = 50, value = 10, step = 1)
      )
    ),
    column(8,
      card(
        card_header("Projection"),
        plotlyOutput("sav_plot", height = "400px"),
        hr(),
        htmlOutput("sav_summary")
  )
    )
  )
}
