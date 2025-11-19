# ============================================================================
# Correlations - UI Component
# ============================================================================

correlations_ui <- function() {
  fluidRow(
    column(12,
      card(
        card_header("Correlation Matrix"),
        p("Explore correlations between different economic indicators. Select specific countries to see how their economic variables interact over time.")
      )
    ),
    column(4,
      card(
        card_header("Filters"),
        # Container will expand when opened
        selectizeInput("corr_countries", "Filter by Country:", choices = NULL, multiple = TRUE, 
                      options = list(placeholder = "All Countries (Global Analysis)")),
        
        sliderInput("corr_year_range", "Year Range:", min = 1960, max = 2023, value = c(2000, 2023), sep = "")
      )
    ),
    column(8,
      card(
        card_header("Heatmap"),
        plotOutput("corr_plot", height = "600px")
      )
    )
  )
}
