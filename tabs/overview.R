# --- PERSONAL FINANCE TAB ---

tabItem(tabName = "overview",
        h2("Personal Finance Essentials",
           style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
        p("This section provides a foundational overview of key areas of personal finance: 
           credit, savings, debt, and loans to help you build lasting financial health."),
        br(),
        
# ===== Custom Button =====
        tags$style(HTML("
          .btn-flat {
            border: none !important;
            border-radius: 6px !important;
            color: #fff !important;
            font-weight: 500 !important;
            padding: 8px 18px !important;
            box-shadow: none !important;
            transition: all 0.2s ease;
          }

          /* Specific button colors */
          button#go_to_credit_resources.btn-flat    { background-color: #0073b7 !important; }  /* blue */
          button#go_to_savings_guide.btn-flat       { background-color: #00c0ef !important; }  /* green */
          button#go_to_debt_tools.btn-flat          { background-color: #f39c12 !important; }  /* amber */
          button#go_to_loan_calculator.btn-flat     { background-color: #3c8dbc !important; }  /* teal */
          button#go_to_retirement.btn-flat          { background-color: #dd4b39 !important; }  /* teal */
          button#go_to_overview.btn-flat            { background-color: #00a65a !important; }  /* green */

          .btn-flat:hover {
            opacity: 0.9 !important;
            transform: translateY(-1px);
          }
        ")),
        
# ===== CREDIT SECTION =====
        box(
          title = tagList(icon("credit-card"), "Understanding Credit"),
          status = "primary", solidHeader = TRUE, width = 12,
          p("Credit represents your ability to borrow money and repay it responsibly. 
             It plays a critical role in determining your access to financial opportunities such as mortgages, 
             auto loans, and credit cards."),
          tags$ul(
            tags$li(tags$b("Credit Score:"), " A number (typically 300–850) reflecting your reliability as a borrower."),
            tags$li(tags$b("Key Factors:"),
                    " Payment history (35%), credit utilization (30%), length of credit history (15%), 
                      new credit (10%), and credit mix (10%)."),
            tags$li(tags$b("Tips:"),
                    " Pay on time, keep utilization under 30%, and avoid closing old accounts unnecessarily.")
          ),
          br(),
          p("Good credit can save you thousands in interest and open doors to better financial products."),
          div(style = "text-align:right;",
              actionButton("go_to_credit_resources", "Learn More About Credit", 
                           icon = icon("arrow-right"), class = "btn-flat"))
        ),
        
# ===== SAVINGS SECTION =====
        box(
          title = tagList(icon("piggy-bank"), "Building Savings"),
          status = "info", solidHeader = TRUE, width = 12,
          p("Savings provide financial security and flexibility. Having enough set aside protects you 
             from emergencies and allows you to pursue future goals confidently."),
          tags$ul(
            tags$li(tags$b("Emergency Fund:"), 
                    " Aim for 3–6 months of living expenses in an easily accessible account."),
            tags$li(tags$b("Short-Term Savings:"), 
                    " Use high-yield savings accounts or short-term CDs for upcoming expenses."),
            tags$li(tags$b("Long-Term Savings:"), 
                    " Prioritize retirement accounts like IRAs and 401(k)s early to benefit from compound growth.")
          ),
          br(),
          p("Consistency matters more than the amount. Saving regularly builds lifelong habits of financial discipline."),
          div(style = "text-align:right;",
              actionButton("go_to_savings_guide", "Explore the Savings Guide", 
                           icon = icon("arrow-right"), class = "btn-flat"))
        ),
        
# ===== DEBT SECTION =====
        box(
          title = tagList(icon("balance-scale"), "Managing Debt"),
          status = "warning", solidHeader = TRUE, width = 12,
          p("Debt can be a useful financial tool if managed wisely, but excessive debt can limit your 
             financial flexibility and increase stress."),
          tags$ul(
            tags$li(tags$b("Good Debt:"), 
                    " Student loans or mortgages that build long-term value."),
            tags$li(tags$b("Bad Debt:"), 
                    " High-interest consumer or credit card debt with little lasting benefit."),
            tags$li(tags$b("Debt-to-Income Ratio (DTI):"), 
                    " Aim to keep total monthly debt payments below 36% of your income."),
            tags$li(tags$b("Tips:"),
                    " Pay more than the minimum, avoid unnecessary borrowing, and refinance high-interest debt if possible.")
          ),
          br(),
          p("Responsible debt management strengthens credit and ensures financial stability over time."),
          div(style = "text-align:right;",
              actionButton("go_to_debt_tools", "View Debt & Budget Tools", 
                           icon = icon("arrow-right"), class = "btn-flat"))
        ),
        
# ===== LOANS SECTION =====
        box(
          title = tagList(icon("university"), "Understanding Loans"),
          status = "primary", solidHeader = TRUE, width = 12,
          p("Loans allow you to make large purchases or investments that would otherwise be out of reach. 
             Understanding loan types and terms helps you make smarter borrowing decisions."),
          tags$ul(
            tags$li(tags$b("Types of Loans:"), 
                    " Mortgages, student loans, auto loans, and personal loans."),
            tags$li(tags$b("Interest Rates:"), 
                    " Fixed rates remain constant; variable rates can change over time."),
            tags$li(tags$b("Loan Term:"), 
                    " Shorter terms often mean higher monthly payments but lower total interest paid."),
            tags$li(tags$b("Tip:"), 
                    " Compare APRs across lenders, and check if paying a small extra amount each month could 
                      significantly shorten repayment time.")
          ),
          br(),
          p("A well-chosen loan should align with your goals, not limit them."),
          div(style = "text-align:right;",
              actionButton("go_to_loan_calculator", "Go to Loan Calculator", 
                           icon = icon("arrow-right"), class = "btn-flat"))
        ),
        
# ===== RETIREMENT SECTION =====
        br(),
        box(
          status = "danger", solidHeader = TRUE, width = 12,
          title = tagList(icon("umbrella-beach"), "Retirement Planning"),
          div(
            p("Planning for retirement early can significantly improve your long-term financial security. 
       The earlier you begin contributing to retirement accounts like a 401(k), IRA, or Roth IRA, 
       the more time your money has to grow through compound interest."),
            tags$ul(
              tags$li(tags$b("Start early:"), " Even small contributions made consistently can grow substantially over time."),
              tags$li(tags$b("Employer match:"), " Take full advantage of your company's 401(k) match if offered."),
              tags$li(tags$b("Diversify investments:"), " Spread your retirement savings across stocks, bonds, and index funds."),
              tags$li(tags$b("Adjust over time:"), " Revisit your retirement plan regularly as your income, lifestyle, and goals evolve.")
            ),
            p("A good rule of thumb is to save at least 15% of your income for retirement, 
       and to gradually increase your contribution rate as your earnings grow.")
          ),
          
          # Button leading to Retirement tab
          div(style = "text-align:right;",
              actionButton("go_to_retirement", "Go to Retirement Planner", 
                           icon = icon("arrow-right"), class = "btn-flat"))
        ),
        
# ===== GENERAL FINANCIAL WELLNESS SECTION =====
        box(
          title = tagList(icon("chart-line"), "Financial Wellness Habits"),
          status = "success", solidHeader = TRUE, width = 12,
          p("Financial wellness is achieved by making informed, consistent choices that align with your long-term goals."),
          tags$ul(
            tags$li("Create and follow a monthly budget."),
            tags$li("Automate bill payments and savings transfers."),
            tags$li("Review your credit report annually for accuracy."),
            tags$li("Build financial literacy: understanding how interest, inflation, and taxes affect your money."),
            tags$li("Invest in yourself through education and skill-building to increase earning potential.")
          ),
          br(),
          p("Healthy financial habits compound just like savings. The earlier and more consistently you start, the stronger your results."),
          div(style = "text-align:right;",
              actionButton("go_to_overview", "Back to Overview", 
                           icon = icon("arrow-left"), class = "btn-flat"))
        ),
        p("." ,
        style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:1px;")
)
