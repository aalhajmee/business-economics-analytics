# cfhi_feature_ui.R
# UI module for Consumer Financial Health Index (CFHI)

cfhi_feature_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      # LEFT COLUMN - CFHI Visualization
      column(
        width = 8,
        # Current CFHI card
        tags$div(
          style = "border:1px solid #e5e7eb; border-radius:12px; padding:16px; background:#f8fafc; margin-bottom:16px;",
          tags$div(style="font-size:13px; color:#64748b; text-transform:uppercase; letter-spacing:0.08em;", "Current U.S. CFHI"),
          tags$div(id = ns("current_label"), style="font-size:28px; font-weight:700; color:#0f172a; margin-top:6px;", "—"),
          tags$div(id = ns("current_sub"), style="font-size:13px; color:#64748b;", "Latest available month")
        ),
        
        # Controls card
        tags$div(
          style = "border:1px solid #e5e7eb; border-radius:12px; padding:16px; margin-bottom:16px;",
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
        ),
        
        # Plot
        plotlyOutput(ns("cfhi_plot"), height = "480px"),
        
        # Methodology Section (collapsible or compact)
        tags$div(
          style = "border:1px solid #e5e7eb; border-radius:8px; padding:16px; background:#f9fafb; margin-top:16px;",
          tags$h4(
            style = "margin-top:0; margin-bottom:12px; color:#0f172a; font-size:14px; font-weight:600;",
            "Methodology & Data Sources"
          ),
          tags$div(
            style = "font-size:12px; color:#475569; line-height:1.6;",
            tags$p(
              style = "margin:8px 0;",
              tags$strong("Formula:"), " CFHI = (S* + W* + I* + R*) / 4, where components are normalized to 0-100 scale and rebased to Oct 2006 = 100."
            ),
            tags$p(
              style = "margin:8px 0;",
              tags$strong("Sources:"), " Personal Saving Rate (BEA), Average Hourly Earnings YoY (BLS), CPI YoY (BLS), Federal Funds Rate (FRED)."
            )
          )
        )
      ),
      
      # RIGHT COLUMN - Personal Calculator
      column(
        width = 4,
        tags$div(
          style = "border:1px solid #e5e7eb; border-radius:12px; padding:20px; background:#ffffff; position:sticky; top:20px;",
          
          # Header
          tags$h4(
            style = "margin-top:0; margin-bottom:8px; color:#0f172a; font-size:16px; font-weight:600;",
            "Your Personal Financial Health"
          ),
          tags$p(
            style = "font-size:12px; color:#64748b; margin-bottom:16px;",
            "Enter your personal metrics to calculate your individual financial health index"
          ),
          
          # Input fields
          numericInput(
            ns("personal_savings"),
            "Your Savings Rate (%)",
            value = NULL,
            min = 0,
            max = 100,
            step = 0.5
          ),
          tags$p(style = "font-size:11px; color:#64748b; margin-top:-8px;", "% of your income you save"),
          
          numericInput(
            ns("personal_wage_growth"),
            "Your Wage Growth (%)",
            value = NULL,
            min = -20,
            max = 50,
            step = 0.5
          ),
          tags$p(style = "font-size:11px; color:#64748b; margin-top:-8px;", "Year-over-year change in your income"),
          
          numericInput(
            ns("personal_inflation"),
            "Inflation Impact (%)",
            value = NULL,
            min = 0,
            max = 20,
            step = 0.1
          ),
          tags$p(style = "font-size:11px; color:#64748b; margin-top:-8px;", "Current inflation rate (use U.S. rate or local)"),
          
          numericInput(
            ns("personal_borrow_rate"),
            "Your Borrowing Rate (%)",
            value = NULL,
            min = 0,
            max = 30,
            step = 0.25
          ),
          tags$p(style = "font-size:11px; color:#64748b; margin-top:-8px;", "Avg interest rate on your debt (credit cards, loans)"),
          
          # Calculate button
          actionButton(
            ns("calc_personal"),
            "Calculate My Index",
            style = "width:100%; background:#1e40af; color:white; border:none; padding:10px; border-radius:6px; font-weight:600; margin-top:8px;"
          ),
          
          # Results display
          tags$div(
            id = ns("personal_result"),
            style = "margin-top:20px; padding:16px; border-radius:8px; display:none;",
            tags$div(
              style = "font-size:12px; color:#64748b; text-transform:uppercase; letter-spacing:0.08em; margin-bottom:4px;",
              "Your Personal CFHI"
            ),
            tags$div(
              id = ns("personal_score"),
              style = "font-size:32px; font-weight:700; margin-bottom:8px;"
            ),
            tags$hr(style = "margin:12px 0; border:none; border-top:1px solid #e5e7eb;"),
            tags$div(
              style = "font-size:12px; color:#64748b; margin-bottom:4px;",
              "Compared to U.S. Average:"
            ),
            tags$div(
              id = ns("comparison_text"),
              style = "font-size:14px; font-weight:600;"
            )
          )
        )
      )
    )
  )
}

