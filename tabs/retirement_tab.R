library(shiny)
library(shinydashboard)

# ------------------------------------------------------------------------------
# Function: renderInputs()
# Reusable UI input panel for a given scenario (A or B)
# ------------------------------------------------------------------------------

renderInputs <- function(prefix) {
  wellPanel(
    fluidRow(
      # Column 1: Investment parameters
      column(
        6,
        sliderInput(
          paste0(prefix, "_years"),
          "Number of Years:",
          min = 5, max = 40, value = 20, step = 1
        ),
        sliderInput(
          paste0(prefix, "_startAmount"),
          "Starting Amount:",
          min = 100000, max = 10000000, value = 2000000,
          step = 50000, pre = "$", sep = ","
        ),
        sliderInput(
          paste0(prefix, "_growthRate"),
          "Annual Investment Return (%):",
          min = 0.0, max = 30.0, value = 5.0, step = 0.5
        ),
        sliderInput(
          paste0(prefix, "_standardDev"),
          "Investment Volatility (%):",
          min = 0.0, max = 30.0, value = 7.0, step = 0.5
        )
      ),
      
      # Column 2: Inflation and withdrawals
      column(
        6,
        sliderInput(
          paste0(prefix, "_inflation"),
          "Annual Inflation (%):",
          min = 0, max = 20, value = 2.5, step = 0.1
        ),
        sliderInput(
          paste0(prefix, "_infStandardDev"),
          "Inflation Volatility (%):",
          min = 0.0, max = 5.0, value = 1.5, step = 0.1
        ),
        sliderInput(
          paste0(prefix, "_withdrawals"),
          "Monthly Withdrawals:",
          min = 1000, max = 100000, value = 10000,
          step = 1000, pre = "$", sep = ","
        )
      )
    ),
    
    # Action button to re-run simulation
    p(
      actionButton(
        paste0(prefix, "_recalculate"),
        "Re-run Simulation",
        icon("random")
      )
    )
  )
}

# ------------------------------------------------------------------------------
# Main tab layout for "Retirement"
# ------------------------------------------------------------------------------

tabItem(
  tabName = "retirement",
  
  # Inline CSS styling for cleaner visuals
  tags$style(type = "text/css",
             "label {font-size: 12px;}",
             ".recalculating {opacity: 1.0;}"
  ),
  
  # Page title and description
  h2("Retirement: Simulating Wealth with Monte Carlo"),
  
  hr(),
  
  # Scenario labels
  fluidRow(
    column(6, h3("Scenario A")),
    column(6, h3("Scenario B"))
  ),
  
  # Input panels
  fluidRow(
    column(6, renderInputs("case_a_for_retirement")),
    column(6, renderInputs("case_b_for_retirement"))
  ),
  
  # Summary text boxes for each scenario
  fluidRow(
    column(
      6,
      wellPanel(
        h4("Scenario A Results"),
        verbatimTextOutput("a_summary")
      )
    ),
    column(
      6,
      wellPanel(
        h4("Scenario B Results"),
        verbatimTextOutput("b_summary")
      )
    )
  ),
  
  # Plots (one per scenario)
  fluidRow(
    column(6, plotOutput("a_distPlot", height = "600px")),
    column(6, plotOutput("b_distPlot", height = "600px"))
  ),
  
  hr(),
  
  # Explanatory text
  fluidRow(
    column(
      12,
      h4("How to Read the Charts"),
      p(strong("Left plot:"), "Shows 200 possible paths for your portfolio value over time."),
      p(strong("Right plot:"), "Shows what percentage of simulations still have money remaining."),
      p(strong("Success Rate:"), "The percentage shown in the results above indicates how often your money lasted the full time period. A rate above 75% is generally considered safe.")
    )
  )
)