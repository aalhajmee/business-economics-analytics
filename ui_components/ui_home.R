# Home Page UI
home_ui <- function() {
  fluidRow(
    # Hero Section
    column(
      12,
      card(
        card_header(tags$span(bs_icon("graph-up-arrow"), " Financial Insight")),
        div(
          class = "p-4",
          h2("Explore. Plan. Simulate.", class = "display-6 fw-bold"),
          p(
            class = "lead text-muted",
            "Your integrated platform for global economic analysis and personal financial planning."
          ),
          hr(),
          p(
            style = "font-size: 1.1rem;",
            "This dashboard connects the macro to the micro. Understand how global economic forces shape the world, ",
            "then apply financial principles to build your own secure future."
          )
        )
      )
    ),

    # Module Cards - Streamlined
    column(
      4,
      card(
        card_header(tags$span(bs_icon("globe"), " Macro Economy")),
        div(
          style = "min-height: 180px;",
          p("Analyze global trends across 200+ countries with advanced statistical methods."),
          tags$ul(
            class = "list-unstyled",
            tags$li(bs_icon("check-circle"), " Time Series & Correlations"),
            tags$li(bs_icon("check-circle"), " Statistical Analysis (ANOVA, Regression, Chi-Square)"),
            tags$li(bs_icon("check-circle"), " Interactive Maps & Regional Trends"),
            tags$li(bs_icon("check-circle"), " Commodity Price Comparisons")
          ),
          actionButton("btn_goto_macro", "Explore Macro Data",
            icon = icon("arrow-right"),
            class = "btn-primary w-100 mt-3"
          )
        )
      )
    ),
    column(
      4,
      card(
        card_header(tags$span(bs_icon("wallet2"), " Personal Finance")),
        div(
          style = "min-height: 180px;",
          p("Tools to manage your wealth today."),
          tags$ul(
            class = "list-unstyled",
            tags$li(bs_icon("check-circle"), " Savings Growth Projector"),
            tags$li(bs_icon("check-circle"), " Loan Amortization"),
            tags$li(bs_icon("check-circle"), " Financial Health Guide")
          ),
          actionButton("btn_goto_finance", "Plan Your Finances",
            icon = icon("arrow-right"),
            class = "btn-primary w-100 mt-3"
          )
        )
      )
    ),
    column(
      4,
      card(
        card_header(tags$span(bs_icon("piggy-bank"), " Retirement")),
        div(
          style = "min-height: 180px;",
          p("Simulate your long-term financial future."),
          tags$ul(
            class = "list-unstyled",
            tags$li(bs_icon("check-circle"), " Monte Carlo Simulations"),
            tags$li(bs_icon("check-circle"), " Risk Scenario Analysis"),
            tags$li(bs_icon("check-circle"), " Portfolio Probability")
          ),
          actionButton("btn_goto_retirement", "Run Simulations",
            icon = icon("arrow-right"),
            class = "btn-primary w-100 mt-3"
          )
        )
      )
    )
  )
}
