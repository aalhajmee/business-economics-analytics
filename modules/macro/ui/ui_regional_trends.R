# ============================================================================
# Regional Trends - UI Component
# ============================================================================

regional_trends_ui <- function() {
  fluidRow(
    column(12,
      card(
        card_header("Regional Trends"),
        p("Compare economic trends across world regions over time (population-weighted averages).")
      )
    ),
    column(4,
      card(
        card_header("Controls"),
        selectInput("reg_indicator", "Indicator:", choices = list("GDP per Capita" = "gdp_per_capita", "Inflation Rate" = "inflation", "Unemployment Rate" = "unemployment", "Life Expectancy" = "life_expectancy", "Population Growth" = "pop_growth"), selected = "gdp_per_capita"),
        sliderInput("reg_year_range", "Year Range:", min = 1960, max = 2023, value = c(2000, 2023), sep = "")
      )
    ),
    column(8,
      card(
        card_header("Regional Comparison"),
        plotlyOutput("regional_plot", height = "500px")
      )
    )
  )
}
