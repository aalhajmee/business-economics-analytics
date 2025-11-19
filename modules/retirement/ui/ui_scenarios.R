# ============================================================================
# Scenario Analysis - UI Component
# ============================================================================

scenarios_ui <- function() {
  fluidRow(
    column(12,
      card(
        card_header("Scenario Comparison"),
        p("Compare Conservative, Moderate, and Aggressive investment strategies using deterministic projections.")
      )
    ),
    column(4,
      card(
        card_header("Inputs"),
        numericInput("scen_age", "Current Age:", value = 25),
        numericInput("scen_retire_age", "Retirement Age:", value = 65),
        numericInput("scen_savings", "Current Savings ($):", value = 20000),
        numericInput("scen_contrib", "Monthly Contribution ($):", value = 500)
      )
    ),
    column(8,
      card(
        card_header("Growth Trajectories"),
        plotlyOutput("scen_plot", height = "450px"),
        br(),
        DTOutput("scen_table")
      )
    )
  )
}
