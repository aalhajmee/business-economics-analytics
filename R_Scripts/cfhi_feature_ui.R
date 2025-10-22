# cfhi_feature_ui.R
# UI module for Consumer Financial Health Index (CFHI)

cfhi_feature_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      style = "display:flex; gap:16px; align-items:stretch; flex-wrap: wrap; margin-bottom:16px;",
      # Current CHFI card
      tags$div(
        style = "flex: 1 1 260px; border:1px solid #e5e7eb; border-radius:12px; padding:16px; background:#f8fafc;",
        tags$div(style="font-size:13px; color:#64748b; text-transform:uppercase; letter-spacing:0.08em;", "Current CHFI"),
        tags$div(id = ns("current_label"), style="font-size:28px; font-weight:700; color:#0f172a; margin-top:6px;", "—"),
        tags$div(id = ns("current_sub"), style="font-size:13px; color:#64748b;", "Latest available month")
      ),
      # Controls card
      tags$div(
        style = "flex: 3 1 480px; border:1px solid #e5e7eb; border-radius:12px; padding:16px;",
        fluidRow(
          column(
            width = 4,
            uiOutput(ns("date_range_ui"))
          ),
          column(
            width = 8,
            checkboxGroupInput(
              ns("show_components"),
              "Select Components to Display:",
              choices = c(
                "Savings Rate ↑" = "savings",
                "Wage Growth ↑" = "wages",
                "Inflation ↓" = "inflation",
                "Borrow Rate ↓" = "borrow"
              ),
              selected = NULL,
              inline = TRUE
            )
          )
        )
      )
    ),
    # Plot
    plotlyOutput(ns("cfhi_plot"), height = "520px"),
    br(),
    # Footnote
    tags$p(
      style = "font-size:12px; color:#64748b;",
      "Consumer Financial Health Index (CFHI): equal-weighted average of normalized components ",
      "(Savings ↑, Wage YoY ↑, Inflation YoY ↓, Borrowing rate ↓). ",
      "Index rebased to Oct 2006 = 100."
    )
  )
}

