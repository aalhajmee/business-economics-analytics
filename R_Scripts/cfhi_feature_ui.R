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
    
    # Methodology Section
    tags$div(
      style = "border:1px solid #e5e7eb; border-radius:8px; padding:20px; background:#f9fafb; margin-top:16px;",
      
      # Title
      tags$h4(
        style = "margin-top:0; margin-bottom:16px; color:#0f172a; font-size:16px; font-weight:600;",
        "Methodology & Data Sources"
      ),
      
      # Formula Section
      tags$div(
        style = "margin-bottom:16px;",
        tags$h5(
          style = "margin-top:0; margin-bottom:8px; color:#334155; font-size:14px; font-weight:600;",
          "Calculation Formula"
        ),
        tags$p(
          style = "font-size:13px; color:#475569; line-height:1.6; margin-bottom:8px;",
          "The Consumer Financial Health Index (CFHI) is computed as an equal-weighted average of four normalized components:"
        ),
        tags$div(
          style = "background:#ffffff; border-left:3px solid #1e40af; padding:12px; margin:8px 0; font-family:monospace; font-size:13px;",
          tags$strong("CFHI = (S* + W* + I* + R*) / 4"),
          tags$br(),
          tags$br(),
          "Where:",
          tags$br(),
          tags$ul(
            style = "margin:8px 0; padding-left:20px;",
            tags$li(tags$strong("S*"), " = Normalized Savings Rate (0-100 scale, higher is better)"),
            tags$li(tags$strong("W*"), " = Normalized Wage Growth YoY (0-100 scale, higher is better)"),
            tags$li(tags$strong("I*"), " = Inverted Inflation YoY (0-100 scale, lower inflation → higher score)"),
            tags$li(tags$strong("R*"), " = Inverted Borrowing Rate (0-100 scale, lower rate → higher score)")
          )
        ),
        tags$p(
          style = "font-size:13px; color:#475569; line-height:1.6; margin-top:8px;",
          tags$strong("Normalization:"), " Each raw component is scaled to a 0-100 range using min-max normalization: ",
          tags$code("(value - min) / (max - min) × 100"),
          tags$br(),
          tags$strong("Rebasing:"), " The final index is rebased to October 2006 = 100 as the baseline reference point."
        )
      ),
      
      # Data Sources Section
      tags$div(
        tags$h5(
          style = "margin-top:0; margin-bottom:8px; color:#334155; font-size:14px; font-weight:600;",
          "Data Sources"
        ),
        tags$ul(
          style = "font-size:13px; color:#475569; line-height:1.8; margin:0; padding-left:20px;",
          tags$li(tags$strong("Savings Rate:"), " Personal Saving Rate (% of disposable income) - U.S. Bureau of Economic Analysis (BEA)"),
          tags$li(tags$strong("Wage Growth:"), " Average Hourly Earnings Year-over-Year (%) - U.S. Bureau of Labor Statistics (BLS)"),
          tags$li(tags$strong("Inflation Rate:"), " Consumer Price Index Year-over-Year (%) - U.S. Bureau of Labor Statistics (BLS)"),
          tags$li(tags$strong("Borrowing Rate:"), " Federal Funds Effective Rate (%) - Federal Reserve Economic Data (FRED)")
        ),
        tags$p(
          style = "font-size:12px; color:#64748b; margin-top:12px; margin-bottom:0;",
          tags$em("Data Period: October 2006 to present | Update Frequency: Monthly")
        )
      )
    )
  )
}

