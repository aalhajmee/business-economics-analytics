# ============================================================================
# Savings Guide (50/30/20 Rule) - UI Component
# ============================================================================

planning_guide_ui <- function() {
  fluidRow(
    column(12,
      card(
        card_header(tags$span(bs_icon("piggy-bank"), " Understanding the 50/30/20 Rule")),
        div(class = "p-3",
          p("The 50/30/20 rule is a simple yet powerful budgeting framework that helps you manage your income wisely. It divides your after-tax income into three main categories:"),
          tags$ul(
            tags$li(tags$b("50% Needs:"), " essentials like rent, bills, and insurance."),
            tags$li(tags$b("30% Wants:"), " discretionary spending like dining out, travel, or hobbies."),
            tags$li(tags$b("20% Savings:"), " future goals such as emergency funds, investments, or debt repayment.")
          ),
          p("This guide helps you understand where your money goes and how your current spending compares to the recommended balance. Adjust inputs below to see how small changes can impact your financial stability.")
        )
      )
    ),
    
    column(12,
      p("Enter your information and learn how to improve your financial health step-by-step.", 
        style = "text-align:center; font-size:16px; margin-top:20px;"),
      p("Make sure to consistently use monthly or yearly values.",
        style = "text-align:center; color:#64748b; font-style:italic;")
    ),
    
    # Inputs Section
    column(6,
      card(
        card_header(tags$span(bs_icon("house"), " Essential Expenses (Needs)")),
        div(class = "p-3",
          numericInput("sav_guide_income", "Income (after tax):",
                      min = 0, max = 1000000000, value = 50000, step = 1000),
          numericInput("sav_guide_rent", "Rent or Mortgage Payments:",
                      min = 0, max = 1000000000, value = 15000, step = 100),
          numericInput("sav_guide_utilities", "Utility Bills:",
                      min = 0, max = 1000000000, value = 1000, step = 100),
          numericInput("sav_guide_healthcare", "Healthcare:",
                      min = 0, max = 1000000000, value = 1000, step = 100),
          numericInput("sav_guide_insurance", "Insurance Payments:",
                      min = 0, max = 1000000000, value = 1000, step = 100),
          numericInput("sav_guide_other_needs", "Other Needs*:",
                      min = 0, max = 1000000000, value = 0, step = 100),
          p("*If you can honestly say 'I can't live without it,' it belongs here. Gas, required loan payments, and groceries also count as needs.",
            style = "font-size:13px; color:#64748b; margin-top:10px;")
        )
      )
    ),
    
    column(6,
      card(
        card_header(tags$span(bs_icon("heart"), " Lifestyle & Discretionary (Wants)")),
        div(class = "p-3",
          numericInput("sav_guide_subscriptions", "Subscriptions:",
                      min = 0, max = 1000000000, value = 100, step = 10),
          numericInput("sav_guide_dining", "Dining Out:",
                      min = 0, max = 1000000000, value = 100, step = 100),
          numericInput("sav_guide_entertainment", "Entertainment:",
                      min = 0, max = 1000000000, value = 500, step = 100),
          numericInput("sav_guide_shopping", "Shopping:",
                      min = 0, max = 1000000000, value = 500, step = 100),
          numericInput("sav_guide_travel", "Travel:",
                      min = 0, max = 1000000000, value = 1000, step = 100)
        )
      )
    ),
    
    # Current Spending Section
    column(12,
      h3("Your Current Spending (Based on Your Inputs)",
         style = "text-align:center; font-weight:600; margin-top:30px;"),
      p("These values summarize how you currently divide your income across needs, wants, and savings.",
        style = "text-align:center; color:#64748b;")
    ),
    
    column(4, uiOutput("sav_guide_needs_box")),
    column(4, uiOutput("sav_guide_wants_box")),
    column(4, uiOutput("sav_guide_savings_box")),
    
    # Recommended Budget Section
    column(12,
      h3("Your Recommended Budget",
         style = "text-align:center; font-weight:600; margin-top:30px;"),
      p("Here's how much you should ideally allocate under the 50/30/20 framework.",
        style = "text-align:center; color:#64748b;")
    ),
    
    column(4, uiOutput("sav_guide_rec_needs_box")),
    column(4, uiOutput("sav_guide_rec_wants_box")),
    column(4, uiOutput("sav_guide_rec_savings_box"))
  )
}
