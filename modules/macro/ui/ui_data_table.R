# ============================================================================
# Data Table - UI Component
# ============================================================================

data_table_ui <- function() {
  fluidRow(
    column(
      12,
      card(
        card_header("Data Explorer"),
        div(
          class = "d-flex justify-content-between align-items-center mb-3",
          p("Browse, search, and download the complete economic dataset.", class = "mb-0"),
          downloadButton("download_csv", "Download Full CSV", class = "btn-primary btn-sm")
        ),
        hr(),
        div(
          class = "alert alert-light border",
          h6(bs_icon("database"), " Data Source", class = "mb-2"),
          selectizeInput("data_source_selector", "Select Data Source:",
            choices = c(
              "World Bank WDI (Global)" = "wdi",
              "U.S. States" = "states"
            ),
            selected = "wdi",
            options = list(dropdownParent = "body")
          ),
          p(
            class = "mb-1 small mt-2",
            conditionalPanel(
              condition = "input.data_source_selector == 'wdi'",
              strong("World Bank World Development Indicators (WDI)"), tags$br(),
              "All macroeconomic data is sourced directly from the World Bank WDI API via the WDI R package. ",
              "Coverage: 200+ countries, 1960-2023"
            ),
            conditionalPanel(
              condition = "input.data_source_selector == 'states'",
              strong("U.S. State-Level Economic Indicators"), tags$br(),
              "State-level demographic and economic data. Coverage: 50 U.S. states"
            )
          ),
          p(
            class = "mb-0 small text-muted",
            conditionalPanel(
              condition = "input.data_source_selector == 'wdi'",
              tags$a(
                href = "https://datatopics.worldbank.org/world-development-indicators/",
                target = "_blank", "Learn more about WDI"
              )
            )
          )
        )
      )
    ),
    column(
      12,
      card(
        card_header("Raw Data"),
        div(
          style = "overflow-x: auto; max-width: 100%;",
          DTOutput("data_explorer_table")
        )
      )
    )
  )
}
