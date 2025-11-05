library(shiny)
library(shinydashboard)

# ------------------------------------------------------------------------------
# Function: renderInputs()
# Reusable UI input panel for a given scenario (A or B)
# ------------------------------------------------------------------------------

renderInputs <- function(prefix) {
  wellPanel(
    style = "background-color: #ffffff; border: 1px solid #dee2e6; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);",
    fluidRow(
      # Column 1: Investment parameters
      column(
        6,
        div(style = "margin-bottom: 15px;",
            sliderInput(
              paste0(prefix, "_years"),
              "Number of Years:",
              min = 5, max = 40, value = 20, step = 1
            )
        ),
        div(style = "margin-bottom: 15px;",
            sliderInput(
              paste0(prefix, "_startAmount"),
              "Starting Amount:",
              min = 100000, max = 10000000, value = 2000000,
              step = 50000, pre = "$", sep = ","
            )
        ),
        div(style = "margin-bottom: 15px;",
            sliderInput(
              paste0(prefix, "_growthRate"),
              "Annual Investment Return (%):",
              min = 0.0, max = 30.0, value = 5.0, step = 0.5
            )
        ),
        div(style = "margin-bottom: 15px;",
            sliderInput(
              paste0(prefix, "_standardDev"),
              "Investment Volatility (%):",
              min = 0.0, max = 30.0, value = 7.0, step = 0.5
            )
        )
      ),
      
      # Column 2: Inflation and withdrawals
      column(
        6,
        div(style = "margin-bottom: 15px;",
            sliderInput(
              paste0(prefix, "_inflation"),
              "Annual Inflation (%):",
              min = 0, max = 20, value = 2.5, step = 0.1
            )
        ),
        div(style = "margin-bottom: 15px;",
            sliderInput(
              paste0(prefix, "_infStandardDev"),
              "Inflation Volatility (%):",
              min = 0.0, max = 5.0, value = 1.5, step = 0.1
            )
        ),
        div(style = "margin-bottom: 15px;",
            sliderInput(
              paste0(prefix, "_withdrawals"),
              "Monthly Withdrawals:",
              min = 1000, max = 100000, value = 10000,
              step = 1000, pre = "$", sep = ","
            )
        )
      )
    ),
    
    # Action button to re-run simulation
    div(
      style = "text-align: center; margin-top: 20px;",
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
             "label {font-size: 13px; font-weight: 500;}",
             ".recalculating {opacity: 1.0;}",
             ".retirement-scenario-header {
               background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
               color: white;
               padding: 15px;
               border-radius: 8px;
               margin-bottom: 20px;
               text-align: center;
             }",
             ".retirement-results {
               background-color: #f8f9fa;
               border: 2px solid #e9ecef;
               border-radius: 8px;
               padding: 20px;
               margin-bottom: 20px;
             }",
             ".retirement-results h4 {
               color: #495057;
               margin-top: 0;
               margin-bottom: 15px;
               font-weight: 600;
             }",
             ".retirement-results pre {
               background-color: white;
               border: 1px solid #dee2e6;
               border-radius: 6px;
               padding: 15px;
               font-size: 14px;
               line-height: 1.8;
             }",
             ".retirement-plot-container {
               background-color: white;
               border: 1px solid #dee2e6;
               border-radius: 8px;
               padding: 15px;
               margin-top: 10px;
             }",
             "#case_a_for_retirement_recalculate, #case_b_for_retirement_recalculate {
               background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
               color: white !important;
               border: none !important;
               padding: 10px 25px !important;
               font-size: 14px !important;
               font-weight: 600 !important;
               border-radius: 6px !important;
               box-shadow: 0 2px 4px rgba(0,0,0,0.1) !important;
               transition: all 0.3s ease !important;
               margin-top: 10px !important;
             }",
             "#case_a_for_retirement_recalculate:hover, #case_b_for_retirement_recalculate:hover {
               transform: translateY(-2px) !important;
               box-shadow: 0 4px 8px rgba(0,0,0,0.2) !important;
             }",
             "#case_a_for_retirement_recalculate i, #case_b_for_retirement_recalculate i {
               color: white !important;
             }"
  ),
  
  # Page title and description
  div(
    style = "margin-bottom: 30px;",
    h2("Retirement Planning: Monte Carlo Simulation", 
       style = "color: #2c3e50; font-weight: 600; margin-bottom: 10px;"),
    p("Compare two retirement scenarios by adjusting investment parameters and withdrawal rates. Each simulation runs 200 possible outcomes.",
      style = "color: #6c757d; font-size: 15px;")
  ),
  
  hr(style = "border-top: 2px solid #e9ecef; margin-bottom: 30px;"),
  
  # Scenario labels
  fluidRow(
    column(
      6,
      div(class = "retirement-scenario-header",
          h3("Scenario A", style = "margin: 0; font-weight: 600;")
      )
    ),
    column(
      6,
      div(class = "retirement-scenario-header",
          h3("Scenario B", style = "margin: 0; font-weight: 600;")
      )
    )
  ),
  
  # Input panels with improved styling
  fluidRow(
    column(6, 
           div(style = "padding-right: 10px;",
               renderInputs("case_a_for_retirement"))
    ),
    column(6, 
           div(style = "padding-left: 10px;",
               renderInputs("case_b_for_retirement"))
    )
  ),
  
  # Summary text boxes for each scenario
  fluidRow(
    column(
      6,
      div(class = "retirement-results",
          h4("Scenario A Results"),
          verbatimTextOutput("a_summary")
      )
    ),
    column(
      6,
      div(class = "retirement-results",
          h4("Scenario B Results"),
          verbatimTextOutput("b_summary")
      )
    )
  ),
  
  # Plots (one per scenario) with improved containers
  fluidRow(
    column(
      6,
      div(class = "retirement-plot-container",
          h4("Scenario A Simulation", style = "color: #495057; margin-top: 0; margin-bottom: 15px;"),
          plotOutput("a_distPlot", height = "550px")
      )
    ),
    column(
      6,
      div(class = "retirement-plot-container",
          h4("Scenario B Simulation", style = "color: #495057; margin-top: 0; margin-bottom: 15px;"),
          plotOutput("b_distPlot", height = "550px")
      )
    )
  ),
  
  hr(style = "border-top: 2px solid #e9ecef; margin-top: 30px; margin-bottom: 30px;"),
  
  # Explanatory text with better styling
  fluidRow(
    column(
      12,
      div(
        style = "background-color: #f8f9fa; border-left: 4px solid #667eea; padding: 20px; border-radius: 6px;",
        h4("How to Read the Charts", style = "color: #495057; margin-top: 0; margin-bottom: 15px;"),
        div(style = "color: #6c757d; font-size: 14px; line-height: 1.8;",
            p(strong("Left Plot:"), "Displays 200 possible portfolio value trajectories over time. Each line represents one simulation outcome based on random market returns and inflation."),
            p(strong("Right Plot:"), "Shows the success rate over time - the percentage of simulations where money is still available at each point."),
            p(strong("Success Rate Interpretation:"), 
              tags$ul(
                tags$li(strong("Above 75%:"), " Generally considered safe for retirement planning"),
                tags$li(strong("50-75%:"), " Moderate risk - consider adjusting parameters"),
                tags$li(strong("Below 50%:"), " High risk of running out of money")
              )
            )
        )
      )
    )
  )
)