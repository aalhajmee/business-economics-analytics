# ============================================================================
# Global Map - UI Component
# ============================================================================

global_map_ui <- function() {
  fluidRow(
    column(12,
      card(
        card_header("Global Map"),
        p("Interactive world map showing economic indicators by country.")
      )
    ),
    column(4,
      card(
        card_header("Map Controls"),
        selectInput("map_indicator", "Indicator:", choices = list("GDP per Capita" = "gdp_per_capita", "Inflation Rate" = "inflation", "Unemployment Rate" = "unemployment", "Life Expectancy" = "life_expectancy", "Population Growth" = "pop_growth"), selected = "gdp_per_capita"),
        sliderInput("map_year", "Year:", min = 1960, max = 2023, value = 1960, sep = "", animate = FALSE),
        div(style = "margin-top: 15px;",
          actionButton("map_play_pause", "Play", icon = shiny::icon("play"), class = "btn-primary", style = "width: 100%;"),
          div(style = "margin-top: 10px; font-size: 12px; color: #64748b; text-align: center;",
            textOutput("map_animation_status")
          )
        )
      )
    ),
    column(8,
      card(
        card_header("World Visualization"),
        plotlyOutput("map_plot", height = "600px")
      )
    )
  )
}
