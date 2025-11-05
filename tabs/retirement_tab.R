library(shiny)
library(shinydashboard)

# ------------------------------------------------------------------------------
# Function: renderInputs()
# Reusable UI input panel for a given scenario (A or B)
# ------------------------------------------------------------------------------

renderInputs <- function(prefix) {
  div(
    style = "
      border: 2px solid #1e2a38;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
      background-color: #f9f9f9;
      margin-bottom: 15px;
    ",
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
        icon("random"),
        style = "
          background-color: #3c8dbc;
          color: white;
          border: none;
          padding: 8px 20px;
          border-radius: 4px;
          font-weight: 600;
        "
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
             ".recalculating {opacity: 1.0;}"
  ),
  
  # Page title - centered with matching font
  h2("Retirement Planning: Monte Carlo Simulation",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  
  # === Scenario A Box ===
  shinydashboard::box(
    title = "Scenario A — Monte Carlo Retirement Simulation",
    width = 12, status = "primary", solidHeader = TRUE,
    
    # Input panel
    renderInputs("case_a_for_retirement"),
    
    # Results
    div(
      style = "
        border: 2px solid #1e2a38;
        border-radius: 8px;
        padding: 15px;
        box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
        background-color: #ffffff;
        margin-bottom: 15px;
      ",
      h4("Scenario A Results", style = "margin-top: 0; color: #495057;"),
      verbatimTextOutput("a_summary")
    ),
    
    # Plot
    div(
      style = "
        border: 2px solid #1e2a38;
        border-radius: 8px;
        padding: 15px;
        box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
        background-color: #ffffff;
      ",
      plotOutput("a_distPlot", height = "500px")
    )
  ),
  
  # === Scenario B Box ===
  shinydashboard::box(
    title = "Scenario B — Monte Carlo Retirement Simulation",
    width = 12, status = "primary", solidHeader = TRUE,
    
    # Input panel
    renderInputs("case_b_for_retirement"),
    
    # Results
    div(
      style = "
        border: 2px solid #1e2a38;
        border-radius: 8px;
        padding: 15px;
        box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
        background-color: #ffffff;
        margin-bottom: 15px;
      ",
      h4("Scenario B Results", style = "margin-top: 0; color: #495057;"),
      verbatimTextOutput("b_summary")
    ),
    
    # Plot
    div(
      style = "
        border: 2px solid #1e2a38;
        border-radius: 8px;
        padding: 15px;
        box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
        background-color: #ffffff;
      ",
      plotOutput("b_distPlot", height = "500px")
    )
  ),
  
  # === Explanatory text box ===
  shinydashboard::box(
    title = "How to Read the Charts",
    width = 12, status = "warning", solidHeader = TRUE,
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
  ),
  
  p(".")
)