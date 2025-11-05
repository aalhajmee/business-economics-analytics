tabItem(tabName = "guide",
        
        # --- PAGE TITLE ---
        h2("Savings Guide",
           style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:700;
              font-size:34px;"),
        br(),
        
        # --- INTRODUCTION BLOCK ---
        box(width = 12, status = "primary", solidHeader = TRUE,
            title = tagList(icon("piggy-bank"), "Understanding the 50/30/20 Rule"),
            p("The 50/30/20 rule is a simple yet powerful budgeting framework that helps you manage 
         your income wisely. It divides your after-tax income into three main categories:"),
            tags$ul(
              tags$li(tags$b("50% Needs:"), " essentials like rent, bills, and insurance."),
              tags$li(tags$b("30% Wants:"), " discretionary spending like dining out, travel, or hobbies."),
              tags$li(tags$b("20% Savings:"), " future goals such as emergency funds, investments, or debt repayment.")
            ),
            p("This guide helps you understand where your money goes and how your current spending 
         compares to the recommended balance. Adjust inputs below to see how small changes can 
         impact your financial stability."),
            style = "font-size:16px; background-color:#f9fbfd;"
        ),
        
        br(),
        img(src = "savingchart.png", height = "auto", width = "800px",
            style = "display:block; margin-left:auto; margin-right:auto; border-radius:8px; box-shadow:0 4px 10px rgba(0,0,0,0.1);"),
        
        br(),
        p("Enter your information and learn how to improve your financial health step-by-step.",
          style="text-align:center; font-size:16px;"),
        p("Make sure to consistently use monthly or yearly values.",
          style="text-align:center; color:#555; font-style:italic;"),
        
        br(),
        
        # --- INPUTS SECTION ---
        fluidRow(
          column(6, wellPanel(
            h4(icon("home"), "Essential Expenses (Needs)"),
            numericInput("inNumber", "Income (after tax):",
                         min = 0, max = 1000000000, value = 50000, step = 1000),
            numericInput("inNumber2", "Rent or Mortgage Payments:",
                         min = 0, max = 1000000000, value = 15000, step = 100),
            numericInput("inNumber3", "Utility Bills:",
                         min = 0, max = 1000000000, value = 1000, step = 100),
            numericInput("inNumber4", "Healthcare:",
                         min = 0, max = 1000000000, value = 1000, step = 100),
            numericInput("inNumber5", "Insurance Payments:",
                         min = 0, max = 1000000000, value = 1000, step = 100),
            numericInput("inNumber6", "Other Needs*:",
                         min = 0, max = 1000000000, value = 0, step = 100),
            p("*If you can honestly say 'I can’t live without it,' it belongs here. Gas, 
         required loan payments, and groceries also count as needs.",
              style="font-size:13px; color:#555;")
          )),
          
          column(6, wellPanel(
            h4(icon("heart"), "Lifestyle & Discretionary (Wants)"),
            numericInput("inNumber7", "Subscriptions:",
                         min = 0, max = 1000000000, value = 100, step = 10),
            numericInput("inNumber8", "Dining Out:",
                         min = 0, max = 1000000000, value = 100, step = 100),
            numericInput("inNumber9", "Entertainment:",
                         min = 0, max = 1000000000, value = 500, step = 100),
            numericInput("inNumber10", "Shopping:",
                         min = 0, max = 1000000000, value = 500, step = 100),
            numericInput("inNumber11", "Travel:",
                         min = 0, max = 1000000000, value = 1000, step = 100)
          ))
        ),
        
        br(),
        
        # --- CURRENT SPENDING SECTION ---
        h3("Your Current Spending (Based on Your Inputs)",
           style="font-family:'Trebuchet MS',sans-serif; font-weight:600; text-align:center;"),
        p("These values summarize how you currently divide your income across needs, wants, and savings.",
          style="text-align:center; color:#555;"),
        
        fluidRow(
          column(4, uiOutput("needsBox")),
          column(4, uiOutput("wantsBox")),
          column(4, uiOutput("savingsBox"))
        ),
        
        br(),
        
        # --- RECOMMENDED BUDGET SECTION ---
        # --- RECOMMENDED BUDGET SECTION ---
        h3("Your Recommended Budget",
           style="font-family:'Trebuchet MS',sans-serif; font-weight:600; text-align:center;"),
        p("Here’s how much you should ideally allocate under the 50/30/20 framework.",
          style="text-align:center; color:#555;"),
        
        fluidRow(
          column(4, uiOutput("recNeedsBox")),
          column(4, uiOutput("recWantsBox")),
          column(4, uiOutput("recSavingsBox"))
        ),

        
        br(), br()
)
