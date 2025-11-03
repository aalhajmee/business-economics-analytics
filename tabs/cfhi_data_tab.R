tabItem(
  tabName = "cfhi_data",
  h2("CFHI Data Sources",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  p("View the raw data used to calculate the Consumer Financial Health Index."),
  br(),
  
  fluidRow(
    column(
      width = 12,
      box(
        title = "Select Data Source",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        
        selectInput(
          "data_source_select",
          "Choose a data file:",
          choices = c(
            "Master Dataset (All Data)" = "master",
            "Savings Rate" = "savings",
            "Wage Growth (YoY)" = "wage",
            "Inflation Rate (YoY)" = "inflation",
            "Borrowing Rate" = "borrow"
          ),
          selected = "master"
        ),
        
        hr(),
        
        # Download button
        downloadButton("download_data", "Download CSV", class = "btn-primary"),
        
        br(), br(),
        
        # Data table output
        DT::dataTableOutput("data_table")
      )
    )
  ),
  
  br(),
  
  fluidRow(
    column(
      width = 12,
      box(
        title = "Data Description",
        width = 12,
        status = "info",
        
        uiOutput("data_description")
      )
    )
  ),
  
  br(),
  
  # Personal CFHI Calculation Explanation
  fluidRow(
    column(
      width = 12,
      box(
        title = "How Your Personal CFHI is Calculated",
        width = 12,
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        tags$h3(style = "color:#1e40af; margin-top:0;", "Understanding the Personal Financial Health Index"),
        tags$p(
          style = "font-size:15px;",
          "Your Personal Consumer Financial Health Index (CFHI) is calculated using the same methodology 
          as the national U.S. index, but applied to your individual financial situation. The index produces a score from 0 to 100, where:"
        ),
        tags$ul(
          style = "font-size:14px; line-height:1.8;",
          tags$li(tags$strong("0-30:"), " Poor financial health"),
          tags$li(tags$strong("30-50:"), " Below average financial health"),
          tags$li(tags$strong("50-70:"), " Average financial health"),
          tags$li(tags$strong("70-85:"), " Good financial health"),
          tags$li(tags$strong("85-100:"), " Excellent financial health")
        ),
        
        hr(style = "border-top: 2px solid #ffc107;"),
        
        tags$h3(style = "color:#1e40af;", "Step-by-Step Calculation Process"),
        
        # STEP 1
        tags$div(
          style = "background:linear-gradient(to right, #fff8e1, #ffffff); border-left:5px solid #ffc107; padding:20px; margin:15px 0; border-radius:5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
          tags$h4(style = "color:#f57c00; margin-top:0;", "STEP 1: Calculate Your Personal Financial Metrics"),
          tags$p(
            style = "font-size:14px;",
            "Four fundamental metrics are derived from the information you provide in the personal calculator:"
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:10px 0; border-radius:5px; border:1px solid #e0e0e0;",
            tags$h5(style = "color:#2e7d32; margin-top:0;", "1.1 Savings Rate (S)"),
            tags$p(tags$strong("What it measures:"), " The percentage of your monthly income that you save rather than spend."),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#f5f5f5; padding:12px; margin:10px 0; border-left:3px solid #2e7d32; font-size:14px;",
              tags$strong("Formula:"), " S = (Monthly Savings ÷ Monthly Income) × 100"
            ),
            tags$p(
              tags$strong("Example:"), " If you earn $5,000/month and save $750/month:", tags$br(),
              "S = ($750 ÷ $5,000) × 100 = ", tags$strong(style = "color:#2e7d32;", "15%")
            ),
            tags$p(
              style = "color:#555; font-size:13px;",
              tags$strong("Why it matters: "), "Measures your ability to build wealth, create emergency funds, 
              and achieve long-term financial goals."
            )
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:10px 0; border-radius:5px; border:1px solid #e0e0e0;",
            tags$h5(style = "color:#0277bd; margin-top:0;", "1.2 Wage Growth Rate (W)"),
            tags$p(tags$strong("What it measures:"), " The year-over-year percentage change in your income."),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#f5f5f5; padding:12px; margin:10px 0; border-left:3px solid #0277bd; font-size:14px;",
              tags$strong("Formula:"), " W = Income Growth Rate (as you entered it)"
            ),
            tags$p(
              tags$strong("Example:"), " If your income grew 3% compared to last year:", tags$br(),
              "W = ", tags$strong(style = "color:#0277bd;", "3%")
            ),
            tags$p(
              style = "color:#555; font-size:13px;",
              tags$strong("Why it matters: "), "Indicates whether your earning power is improving over time 
              and keeping up with inflation."
            )
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:10px 0; border-radius:5px; border:1px solid #e0e0e0;",
            tags$h5(style = "color:#d84315; margin-top:0;", "1.3 Inflation Rate (I)"),
            tags$p(tags$strong("What it measures:"), " The current U.S. inflation rate (same for everyone)."),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#f5f5f5; padding:12px; margin:10px 0; border-left:3px solid #d84315; font-size:14px;",
              tags$strong("Source:"), " I = Current U.S. Year-over-Year CPI Inflation Rate"
            ),
            tags$p(
              tags$strong("Example:"), " If current U.S. inflation is 3.2%:", tags$br(),
              "I = ", tags$strong(style = "color:#d84315;", "3.2%")
            ),
            tags$p(
              style = "color:#555; font-size:13px;",
              tags$strong("Why it matters: "), "Inflation affects everyone equally by eroding purchasing power. 
              We use the national rate because consumers cannot control or avoid inflation."
            )
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:10px 0; border-radius:5px; border:1px solid #e0e0e0;",
            tags$h5(style = "color:#7b1fa2; margin-top:0;", "1.4 Borrowing Cost Rate (R)"),
            tags$p(tags$strong("What it measures:"), " Your average interest rate on outstanding debt."),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#f5f5f5; padding:12px; margin:10px 0; border-left:3px solid #7b1fa2; font-size:14px;",
              tags$strong("Formula:"), " R = Your Average Interest Rate (or 0% if no debt)"
            ),
            tags$p(
              tags$strong("Example:"), " If you have $10,000 in debt at 15% APR:", tags$br(),
              "R = ", tags$strong(style = "color:#7b1fa2;", "15%"), tags$br(), tags$br(),
              tags$strong("Or:"), " If you have no debt:", tags$br(),
              "R = ", tags$strong(style = "color:#2e7d32;", "0%"), " (best case scenario)"
            ),
            tags$p(
              style = "color:#555; font-size:13px;",
              tags$strong("Why it matters: "), "High borrowing costs reduce your ability to save and invest, 
              while being debt-free improves financial flexibility."
            )
          )
        ),
        
        # STEP 2
        tags$div(
          style = "background:linear-gradient(to right, #e3f2fd, #ffffff); border-left:5px solid #2196f3; padding:20px; margin:15px 0; border-radius:5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
          tags$h4(style = "color:#1976d2; margin-top:0;", "STEP 2: Normalize Each Component to 0-100 Scale"),
          tags$p(
            style = "font-size:14px;",
            "Each metric operates on different scales, making them impossible to compare directly. Normalization transforms 
            all metrics to a common 0-100 scale using historical U.S. data from October 2006 to present."
          ),
          
          tags$h5(style = "color:#0d47a1;", "Normalization Process:"),
          tags$p(
            style = "font-size:14px;",
            "For each component, we use a min-max normalization formula that maps the historical range to 0-100:"
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:15px 0; border-radius:5px; border:2px solid #2196f3;",
            tags$h5(style = "color:#2e7d32; margin-top:0;", "2.1 Normalized Savings Score (S*)"),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#e8f5e9; padding:15px; margin:10px 0; border-left:4px solid #2e7d32; font-size:15px;",
              tags$strong("S* = 100 × (Your Savings Rate - Historical Min) ÷ (Historical Max - Historical Min)")
            ),
            tags$p(tags$strong("Historical Range:"), " U.S. savings rates from 2006-2025 ranged from approximately 2% to 33.8%"),
            tags$p(
              tags$strong("Detailed Example:"), tags$br(),
              "• Your savings rate: 15%", tags$br(),
              "• Historical minimum: 2.1% (May 2005)", tags$br(),
              "• Historical maximum: 33.8% (April 2020, pandemic peak)", tags$br(),
              "• Calculation: S* = 100 × (15 - 2.1) ÷ (33.8 - 2.1) = 100 × 12.9 ÷ 31.7 = ", 
              tags$strong(style = "color:#2e7d32; font-size:16px;", "40.7 points")
            ),
            tags$p(
              style = "color:#555; font-size:13px; margin-top:10px;",
              tags$strong("Interpretation: "), "A score of 40.7 means your 15% savings rate is better than Americans saved 
              during boom times (2-5%) but below pandemic-era peaks."
            )
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:15px 0; border-radius:5px; border:2px solid #2196f3;",
            tags$h5(style = "color:#0277bd; margin-top:0;", "2.2 Normalized Wage Growth Score (W*)"),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#e1f5fe; padding:15px; margin:10px 0; border-left:4px solid #0277bd; font-size:15px;",
              tags$strong("W* = 100 × (Your Wage Growth - Historical Min) ÷ (Historical Max - Historical Min)")
            ),
            tags$p(tags$strong("Historical Range:"), " U.S. wage growth from 2006-2025 ranged from approximately -5% to +8%"),
            tags$p(
              tags$strong("Detailed Example:"), tags$br(),
              "• Your wage growth: 3%", tags$br(),
              "• Historical minimum: -4.8% (2009 recession, severe pay cuts)", tags$br(),
              "• Historical maximum: 7.9% (2022, post-pandemic labor shortage)", tags$br(),
              "• Calculation: W* = 100 × (3 - (-4.8)) ÷ (7.9 - (-4.8)) = 100 × 7.8 ÷ 12.7 = ", 
              tags$strong(style = "color:#0277bd; font-size:16px;", "61.4 points")
            ),
            tags$p(
              style = "color:#555; font-size:13px; margin-top:10px;",
              tags$strong("Interpretation: "), "A score of 61.4 means your 3% income growth is above average, 
              avoiding recession-era pay cuts."
            )
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:15px 0; border-radius:5px; border:2px solid #d84315;",
            tags$h5(style = "color:#d84315; margin-top:0;", "2.3 Normalized Inflation Score (I*) - INVERTED METRIC"),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#fbe9e7; padding:15px; margin:10px 0; border-left:4px solid #d84315; font-size:15px;",
              tags$strong("I* = 100 - [100 × (Current Inflation - Historical Min) ÷ (Historical Max - Historical Min)]")
            ),
            tags$div(
              style = "background:#fff3e0; padding:10px; margin:10px 0; border:1px solid #ff9800; border-radius:5px;",
              tags$strong(style = "color:#e65100;", "IMPORTANT: "), 
              "This metric is inverted because lower inflation is better for consumers. The formula subtracts from 100 
              so that 0% inflation = 100 points and 9% inflation = 0 points."
            ),
            tags$p(tags$strong("Historical Range:"), " U.S. inflation from 2006-2025 ranged from approximately -2% to +9%"),
            tags$p(
              tags$strong("Detailed Example:"), tags$br(),
              "• Current U.S. inflation: 3.2%", tags$br(),
              "• Historical minimum: -2.1% (2009, deflation during recession)", tags$br(),
              "• Historical maximum: 9.1% (June 2022, 40-year high)", tags$br(),
              "• Calculation: I* = 100 - [100 × (3.2 - (-2.1)) ÷ (9.1 - (-2.1))] = 100 - [100 × 5.3 ÷ 11.2] = 100 - 47.3 = ", 
              tags$strong(style = "color:#d84315; font-size:16px;", "52.7 points")
            ),
            tags$p(
              style = "color:#555; font-size:13px; margin-top:10px;",
              tags$strong("Interpretation: "), "A score of 52.7 means current 3.2% inflation is moderate - 
              higher than the Fed's 2% target but lower than the 2022 crisis level of 9%."
            )
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:15px 0; border-radius:5px; border:2px solid #7b1fa2;",
            tags$h5(style = "color:#7b1fa2; margin-top:0;", "2.4 Normalized Borrowing Cost Score (R*) - INVERTED METRIC"),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#f3e5f5; padding:15px; margin:10px 0; border-left:4px solid #7b1fa2; font-size:15px;",
              tags$strong("R* = 100 - [100 × (Your Borrow Rate - Historical Min) ÷ (Historical Max - Historical Min)]")
            ),
            tags$div(
              style = "background:#fce4ec; padding:10px; margin:10px 0; border:1px solid #e91e63; border-radius:5px;",
              tags$strong(style = "color:#880e4f;", "IMPORTANT: "), 
              "This metric is also inverted because lower borrowing costs are better for consumers. The formula subtracts from 100 
              so that 0% rate (no debt) = 100 points and 25% rate = 0 points."
            ),
            tags$p(tags$strong("Historical Range:"), " For consumers, borrowing rates typically range from 0% to 25%+ (credit cards)"),
            tags$p(
              tags$strong("Detailed Example (With Debt):"), tags$br(),
              "• Your average interest rate: 15% (typical credit card)", tags$br(),
              "• Historical minimum: 0% (no debt or 0% promotional rates)", tags$br(),
              "• Historical maximum: 25% (high credit card APR)", tags$br(),
              "• Calculation: R* = 100 - [100 × (15 - 0) ÷ (25 - 0)] = 100 - [100 × 0.6] = 100 - 60 = ", 
              tags$strong(style = "color:#7b1fa2; font-size:16px;", "40 points")
            ),
            tags$p(
              tags$strong("Detailed Example (No Debt):"), tags$br(),
              "• Your average interest rate: 0% (debt-free!)", tags$br(),
              "• Calculation: R* = 100 - [100 × (0 - 0) ÷ (25 - 0)] = 100 - 0 = ", 
              tags$strong(style = "color:#2e7d32; font-size:16px;", "100 points (perfect score!)")
            ),
            tags$p(
              style = "color:#555; font-size:13px; margin-top:10px;",
              tags$strong("Interpretation: "), "With credit card debt at 15% APR, you score 40 points. 
              Paying off debt or being debt-free would achieve the maximum 100 points."
            )
          ),
          
          tags$div(
            style = "background:#fff9c4; padding:15px; margin:15px 0; border-radius:5px; border:2px solid #f57f17;",
            tags$h5(style = "color:#f57f17; margin-top:0;", "Clamping to 0-100 Range"),
            tags$p(
              style = "font-size:14px;",
              "After normalization, each component score is clamped to ensure it stays within 0-100:"
            ),
            tags$ul(
              style = "font-size:13px;",
              tags$li("If your calculated score exceeds 100 (you're doing better than the best historical period), we cap it at 100"),
              tags$li("If your calculated score falls below 0 (you're doing worse than the worst historical period), we floor it at 0"),
              tags$li("This prevents outliers from skewing the final index and keeps all scores comparable")
            )
          )
        ),
        
        # STEP 3
        tags$div(
          style = "background:linear-gradient(to right, #e8f5e9, #ffffff); border-left:5px solid #4caf50; padding:20px; margin:15px 0; border-radius:5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
          tags$h4(style = "color:#2e7d32; margin-top:0;", "STEP 3: Calculate Your Personal CFHI"),
          tags$p(
            style = "font-size:14px;",
            "With all four components on the same 0-100 scale, we calculate your Personal CFHI using a simple 
            arithmetic mean (equal-weighted average):"
          ),
          tags$div(
            style = "font-family:'Courier New', monospace; background:#ffffff; padding:20px; border:3px solid #4caf50; margin:15px 0; text-align:center; font-size:18px; border-radius:8px; box-shadow: 0 3px 6px rgba(0,0,0,0.15);",
            tags$div(
              style = "color:#2e7d32; font-weight:bold; font-size:20px; margin-bottom:10px;",
              "Personal CFHI = (S* + W* + I* + R*) ÷ 4"
            ),
            tags$div(
              style = "color:#666; font-size:14px; font-style:italic;",
              "Equal-Weighted Average of Four Normalized Components"
            )
          ),
          
          tags$h5(style = "color:#2e7d32;", "Worked Example:"),
          tags$div(
            style = "background:#ffffff; padding:20px; margin:10px 0; border-radius:8px; border:2px solid #81c784;",
            tags$p(
              style = "font-size:14px; margin-bottom:15px;",
              tags$strong("Using the individual scores we calculated above:")
            ),
            tags$ul(
              style = "font-size:15px; line-height:2;",
              tags$li(tags$strong(style = "color:#2e7d32;", "S* = 40.7"), " (Savings Score)"),
              tags$li(tags$strong(style = "color:#0277bd;", "W* = 61.4"), " (Wage Growth Score)"),
              tags$li(tags$strong(style = "color:#d84315;", "I* = 52.7"), " (Inflation Score)"),
              tags$li(tags$strong(style = "color:#7b1fa2;", "R* = 40.0"), " (Borrowing Cost Score - assumed 15% APR)")
            ),
            
            tags$div(
              style = "background:#f1f8e9; padding:15px; margin:15px 0; border-left:4px solid #689f38;",
              tags$p(
                style = "font-size:16px; margin:0;",
                tags$strong("Calculation:"), tags$br(),
                "Personal CFHI = (40.7 + 61.4 + 52.7 + 40.0) ÷ 4", tags$br(),
                "Personal CFHI = 194.8 ÷ 4", tags$br(),
                tags$strong(style = "color:#2e7d32; font-size:20px;", "Personal CFHI = 48.7 points")
              )
            ),
            
            tags$div(
              style = "background:#fff3e0; padding:15px; margin:10px 0; border-radius:5px; border-left:4px solid #ff6f00;",
              tags$h5(style = "color:#e65100; margin-top:0;", "Interpreting Your Score of 48.7:"),
              tags$ul(
                style = "font-size:14px;",
                tags$li(tags$strong("Category:"), " Below Average (30-50 range)"),
                tags$li(tags$strong("Strengths:"), " Solid wage growth (61.4)"),
                tags$li(tags$strong("Weaknesses:"), " Low savings rate (40.7) and high borrowing costs (40.0)"),
                tags$li(tags$strong("Impact of Debt:"), " Paying off that 15% APR debt would raise R* from 40 to 100, 
                increasing your CFHI from 48.7 to 63.7"),
                tags$li(tags$strong("Action Items:"), " Focus on debt reduction and increasing savings rate")
              )
            )
          ),
          
          tags$div(
            style = "background:#e3f2fd; padding:15px; margin:15px 0; border-radius:5px; border:1px solid #2196f3;",
            tags$h5(style = "color:#1976d2; margin-top:0;", "Final Step: Capping at 100"),
            tags$p(
              style = "font-size:14px;",
              "The Personal CFHI is designed to operate on a 0-100 scale. If your calculated score exceeds 100, it is capped:"
            ),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#ffffff; padding:12px; margin:10px 0; border-left:3px solid #1976d2; font-size:14px;",
              tags$strong("Personal CFHI (Final) = min(100, Personal CFHI (Calculated))")
            ),
            tags$p(
              style = "color:#555; font-size:13px;",
              tags$strong("Example: "), "If your calculated score exceeds 100, it is capped at 100. 
              If it falls below 0, it is set to 0."
            )
          )
        ),
        
        # STEP 4
        tags$div(
          style = "background:linear-gradient(to right, #f3e5f5, #ffffff); border-left:5px solid #9c27b0; padding:20px; margin:15px 0; border-radius:5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
          tags$h4(style = "color:#7b1fa2; margin-top:0;", "STEP 4: Compare to U.S. Average CFHI"),
          tags$p(
            style = "font-size:14px;",
            "Your Personal CFHI score is compared to the 2025 U.S. average CFHI to provide context:"
          ),
          
          tags$div(
            style = "background:#ffffff; padding:15px; margin:15px 0; border-radius:5px; border:2px solid #9c27b0;",
            tags$h5(style = "color:#7b1fa2; margin-top:0;", "Comparison Calculation:"),
            tags$div(
              style = "font-family:'Courier New', monospace; background:#f5f5f5; padding:15px; margin:10px 0; font-size:14px;",
              tags$strong("Difference = Your Personal CFHI - 2025 U.S. Average CFHI"), tags$br(),
              tags$strong("Percentage Difference = (Difference ÷ U.S. Average) × 100%")
            ),
            
            tags$p(
              tags$strong("Example:"), tags$br(),
              "• Your Personal CFHI: 48.7", tags$br(),
              "• 2025 U.S. Average CFHI: 52.3 (hypothetical)", tags$br(),
              "• Difference: 48.7 - 52.3 = ", tags$strong(style = "color:#d84315;", "-3.6 points"), tags$br(),
              "• Percentage: (-3.6 ÷ 52.3) × 100 = ", tags$strong(style = "color:#d84315;", "-6.9%")
            )
          ),
          
          tags$h5(style = "color:#7b1fa2;", "Interpretation Bands:"),
          tags$div(
            style = "background:#ffffff; padding:15px; margin:10px 0; border-radius:5px;",
            tags$div(
              style = "background:#c8e6c9; padding:12px; margin:8px 0; border-left:5px solid #2e7d32; border-radius:3px;",
              tags$strong(style = "color:#1b5e20; font-size:15px;", "Much Better (+10 points or more)"), tags$br(),
              tags$span(style = "color:#2e7d32;", 
                "You're significantly outperforming the average American. Your financial health is exceptional compared to national trends.")
            ),
            tags$div(
              style = "background:#dcedc8; padding:12px; margin:8px 0; border-left:5px solid #689f38; border-radius:3px;",
              tags$strong(style = "color:#33691e; font-size:15px;", "Better (+2 to +10 points)"), tags$br(),
              tags$span(style = "color:#558b2f;", 
                "You're doing better than the typical American household, with clear financial strengths in one or more areas.")
            ),
            tags$div(
              style = "background:#fff9c4; padding:12px; margin:8px 0; border-left:5px solid #f9a825; border-radius:3px;",
              tags$strong(style = "color:#f57f17; font-size:15px;", "Similar (-2 to +2 points)"), tags$br(),
              tags$span(style = "color:#f57f17;", 
                "You're on par with the average American, with similar challenges and successes as most households.")
            ),
            tags$div(
              style = "background:#ffe0b2; padding:12px; margin:8px 0; border-left:5px solid #f57c00; border-radius:3px;",
              tags$strong(style = "color:#e65100; font-size:15px;", "Below Average (-10 to -2 points)"), tags$br(),
              tags$span(style = "color:#e65100;", 
                "You're facing more financial challenges than the typical American. Focus on the lowest-scoring components to identify where to improve.")
            ),
            tags$div(
              style = "background:#ffcdd2; padding:12px; margin:8px 0; border-left:5px solid #d32f2f; border-radius:3px;",
              tags$strong(style = "color:#b71c1c; font-size:15px;", "Much Below (more than -10 points)"), tags$br(),
              tags$span(style = "color:#c62828;", 
                "You're facing significant financial challenges. Consider seeking guidance from a financial counselor to develop an improvement plan.")
            )
          ),
          
          tags$div(
            style = "background:#e1f5fe; padding:15px; margin:15px 0; border-radius:5px; border:1px solid #0277bd;",
            tags$p(
              style = "font-size:13px; margin:0;",
              tags$strong(style = "color:#01579b;", "Note: "), 
              "The comparison uses the 2025 average CFHI, not just the most recent month. This provides a more 
              stable benchmark that isn't affected by monthly volatility."
            )
          )
        ),
        
        hr(style = "border-top: 2px solid #ffc107; margin: 25px 0;"),
        
        # WHY THESE COMPONENTS
        tags$h3(style = "color:#1e40af;", "Why These Four Components?"),
        tags$p(
          style = "font-size:14px;",
          "The CFHI uses exactly four components because they comprehensively cover the key dimensions of consumer financial health. 
          Together, they create a holistic picture:"
        ),
        tags$div(
          style = "background:#fff3cd; padding:20px; margin:15px 0; border-radius:8px; border:2px solid #ffc107;",
          tags$div(
            style = "margin-bottom:15px;",
            tags$h5(style = "color:#2e7d32; margin-top:0;", "Savings Rate - Financial Resilience"),
            tags$p(
              style = "font-size:14px; margin:0;",
              "Measures your ability to build wealth and create safety nets."
            )
          ),
          tags$div(
            style = "margin-bottom:15px;",
            tags$h5(style = "color:#0277bd; margin-top:0;", "Wage Growth - Income Trajectory"),
            tags$p(
              style = "font-size:14px; margin:0;",
              "Indicates whether your earning power is improving over time and keeping up with inflation."
            )
          ),
          tags$div(
            style = "margin-bottom:15px;",
            tags$h5(style = "color:#d84315; margin-top:0;", "Inflation - Purchasing Power"),
            tags$p(
              style = "font-size:14px; margin:0;",
              "Affects everyone equally by determining how far your dollars stretch. Inverted because high inflation hurts consumers."
            )
          ),
          tags$div(
            tags$h5(style = "color:#7b1fa2; margin-top:0;", "Borrowing Costs - Debt Burden"),
            tags$p(
              style = "font-size:14px; margin:0;",
              "Reflects how much of your income goes to interest payments. Inverted because high rates create financial strain."
            )
          )
        ),
        
        tags$h5(style = "color:#1e40af;", "Balance of All Four:"),
        tags$p(
          style = "font-size:14px;",
          "By combining these four metrics equally, the CFHI captures whether you're building wealth, growing income, 
          maintaining purchasing power, and minimizing financial drag."
        ),
        
        hr(style = "border-top: 1px solid #ccc; margin: 20px 0;"),
        
        tags$div(
          style = "background:#f5f5f5; padding:15px; border-left:4px solid #757575; border-radius:5px;",
          tags$p(
            style = "color:#424242; font-size:13px; font-style:italic; margin:0;",
            tags$strong("Disclaimer: "), 
            "This index is designed to provide a snapshot of your financial health relative to historical U.S. economic trends. 
            It should be used as an educational tool and general guide, not as personalized financial advice. Individual circumstances vary, 
            and a single number cannot capture every aspect of your financial situation. For personalized financial planning, tax advice, 
            or investment recommendations, please consult with a certified financial planner, CPA, or other qualified professional."
          )
        )
      )
    )
  ),
  
  br(),
  
  # U.S. National CFHI Calculation
  fluidRow(
    column(
      width = 12,
      box(
        title = "How the U.S. National CFHI is Calculated",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        collapsed = TRUE,
        
        tags$h3(style = "color:#1e40af; margin-top:0;", "National Index Methodology"),
        tags$p(
          style = "font-size:15px;",
          "The U.S. National Consumer Financial Health Index (CFHI) uses the same fundamental methodology as the personal calculator, 
          but with aggregate national economic data from government sources. However, there is one critical difference: the national 
          index is rebased to October 2006 = 100, allowing it to exceed 100 and show improvement relative to the baseline month."
        ),
        
        hr(style = "border-top: 2px solid #2196f3;"),
        
        tags$h4(style = "color:#0d47a1;", "Data Sources for National Index:"),
        tags$div(
          style = "background:#e3f2fd; padding:15px; margin:15px 0; border-radius:5px;",
          tags$ul(
            style = "font-size:14px; line-height:1.8;",
            tags$li(
              tags$strong(style = "color:#2e7d32;", "Savings Rate: "), 
              "Personal Saving Rate from U.S. Bureau of Economic Analysis (BEA), Table 2.1. 
              This is calculated as (Personal Saving ÷ Disposable Personal Income) × 100 for all Americans combined."
            ),
            tags$li(
              tags$strong(style = "color:#0277bd;", "Wage Growth: "), 
              "Year-over-year percentage change in Average Hourly Earnings of All Employees from U.S. Bureau of Labor Statistics (BLS) 
              Current Employment Statistics survey. Measures national wage trends across all private sector industries."
            ),
            tags$li(
              tags$strong(style = "color:#d84315;", "Inflation: "), 
              "Year-over-year percentage change in Consumer Price Index for All Urban Consumers (CPI-U) from BLS. 
              Tracks price changes for a basket of ~80,000 goods and services across 75 urban areas."
            ),
            tags$li(
              tags$strong(style = "color:#7b1fa2;", "Borrowing Rate: "), 
              "Federal Funds Effective Rate from Federal Reserve Economic Data (FRED). 
              This is the overnight interbank lending rate that influences all consumer borrowing costs."
            )
          )
        ),
        
        tags$h4(style = "color:#0d47a1;", "National Index Calculation Steps:"),
        
        tags$div(
          style = "background:#ffffff; padding:15px; margin:15px 0; border-radius:5px; border-left:4px solid #2196f3;",
          tags$h5(style = "color:#1976d2;", "Step 1: Normalize Each Component (Same as Personal)"),
          tags$p(
            style = "font-size:14px;",
            "Each of the four national indicators is normalized to a 0-100 scale using the exact same formulas as the personal calculator:"
          ),
          tags$div(
            style = "font-family:'Courier New', monospace; background:#f5f5f5; padding:12px; margin:10px 0; font-size:13px;",
            "S* = 100 × (Savings Rate - Min) ÷ (Max - Min)", tags$br(),
            "W* = 100 × (Wage Growth YoY - Min) ÷ (Max - Min)", tags$br(),
            "I* = 100 - [100 × (Inflation YoY - Min) ÷ (Max - Min)]  [inverted]", tags$br(),
            "R* = 100 - [100 × (Federal Funds Rate - Min) ÷ (Max - Min)]  [inverted]"
          ),
          tags$p(
            style = "color:#555; font-size:13px;",
            "The min/max values are determined from the entire historical dataset (October 2006 to present). 
            As new data arrives each month, these ranges can expand, which is why historical CFHI values may be recalculated."
          )
        ),
        
        tags$div(
          style = "background:#ffffff; padding:15px; margin:15px 0; border-radius:5px; border-left:4px solid #2196f3;",
          tags$h5(style = "color:#1976d2;", "Step 2: Calculate Raw CFHI (Equal-Weighted Average)"),
          tags$div(
            style = "font-family:'Courier New', monospace; background:#f5f5f5; padding:15px; margin:10px 0; text-align:center; font-size:16px; border:2px solid #2196f3; border-radius:5px;",
            tags$strong("CFHI (raw) = (S* + W* + I* + R*) ÷ 4")
          ),
          tags$p(
            style = "font-size:14px;",
            "This produces a 0-100 score for each month representing the aggregate financial health of American consumers. 
            However, for the national index, we take one additional step..."
          )
        ),
        
        tags$div(
          style = "background:#fff9c4; padding:20px; margin:15px 0; border-radius:5px; border:3px solid #f57f17;",
          tags$h5(style = "color:#e65100; margin-top:0;", "Step 3: Rebase to October 2006 = 100"),
          tags$p(
            style = "font-size:14px;",
            "To make the national index more interpretable and track long-term trends, we rebase it so that 
            October 2006 = 100. This was chosen as the baseline because it represents the peak of the 
            pre-financial crisis economy."
          ),
          tags$div(
            style = "font-family:'Courier New', monospace; background:#ffffff; padding:15px; margin:15px 0; border-left:4px solid #f57f17; font-size:15px;",
            tags$strong("CFHI (rebased) = (CFHI (raw) ÷ CFHI (Oct 2006)) × 100")
          ),
          tags$p(tags$strong("Example:")),
          tags$ul(
            style = "font-size:14px;",
            tags$li("October 2006 raw CFHI: 58.3"),
            tags$li("January 2025 raw CFHI: 52.1"),
            tags$li("Rebased: (52.1 ÷ 58.3) × 100 = ", tags$strong(style = "color:#d84315;", "89.4"))
          ),
            tags$p(
              style = "font-size:14px; color:#555;",
              tags$strong("Interpretation: "), 
              "A rebased score of 89.4 means Americans' financial health in January 2025 is about 89% of what it was in October 2006 - 
              a 10.6% decline from the baseline."
            ),          tags$div(
            style = "background:#e3f2fd; padding:15px; margin:10px 0; border-radius:5px; border:1px solid #0277bd;",
            tags$h5(style = "color:#01579b; margin-top:0;", "Why Rebasing Matters:"),
            tags$ul(
              style = "font-size:13px;",
              tags$li(tags$strong("Easier Interpretation: "), "100 = baseline financial health, >100 = better than 2006, <100 = worse than 2006"),
              tags$li(tags$strong("Trend Visibility: "), "You can immediately see whether conditions have improved or deteriorated over two decades"),
              tags$li(tags$strong("Historical Anchor: "), "October 2006 provides a fixed reference point (pre-crisis normalcy)"),
              tags$li(tags$strong("Can Exceed 100: "), "Unlike the personal index capped at 100, the national index can theoretically go above 100 
              if conditions surpass 2006 levels")
            )
          ),
          
          tags$div(
            style = "background:#ffebee; padding:15px; margin:10px 0; border-radius:5px; border:1px solid #c62828;",
            tags$h5(style = "color:#b71c1c; margin-top:0;", "⚠️ Why Personal CFHI Doesn't Use Rebasing:"),
            tags$p(
              style = "font-size:13px; margin:0;",
              "Your personal calculator does NOT use rebasing because:", tags$br(),
              "1. Your personal financial data doesn't exist for October 2006 (we can't rebase to your historical self)", tags$br(),
              "2. A 0-100 scale is more intuitive for individuals (100 = perfect, 0 = worst possible)", tags$br(),
              "3. Rebasing would create confusion and make comparisons to the national average harder", tags$br(),
              "4. Capping at 100 prevents unrealistic scores and keeps the scale meaningful"
            )
          )
        ),
        
        hr(style = "border-top: 2px solid #2196f3; margin: 25px 0;"),
        
        tags$h4(style = "color:#0d47a1;", "Complete National Index Example:"),
        tags$div(
          style = "background:#e8f5e9; padding:20px; margin:15px 0; border-radius:8px; border:2px solid #4caf50;",
          tags$p(tags$strong("Data for January 2025 (hypothetical):")),
          tags$ul(
            style = "font-size:14px;",
            tags$li("National Savings Rate: 3.8%"),
            tags$li("National Wage Growth YoY: 4.1%"),
            tags$li("National Inflation YoY: 3.2%"),
            tags$li("Federal Funds Rate: 4.5%")
          ),
          
          tags$p(tags$strong("Step 1: Normalize (using historical ranges 2006-2025):")),
          tags$ul(
            style = "font-size:14px;",
            tags$li("S* = 100 × (3.8 - 2.1) / (33.8 - 2.1) = 100 × 1.7 / 31.7 = ", tags$strong(style = "color:#2e7d32;", "5.4")),
            tags$li("W* = 100 × (4.1 - (-4.8)) / (7.9 - (-4.8)) = 100 × 8.9 / 12.7 = ", tags$strong(style = "color:#0277bd;", "70.1")),
            tags$li("I* = 100 - [100 × (3.2 - (-2.1)) / (9.1 - (-2.1))] = 100 - 47.3 = ", tags$strong(style = "color:#d84315;", "52.7")),
            tags$li("R* = 100 - [100 × (4.5 - 0) / (6.0 - 0)] = 100 - 75.0 = ", tags$strong(style = "color:#7b1fa2;", "25.0"))
          ),
          
          tags$p(tags$strong("Step 2: Calculate Raw CFHI:")),
          tags$div(
            style = "font-family:'Courier New', monospace; background:#ffffff; padding:12px; margin:10px 0; font-size:14px;",
            "Raw CFHI = (5.4 + 70.1 + 52.7 + 25.0) ÷ 4 = 153.2 ÷ 4 = ", tags$strong(style = "color:#1976d2;", "38.3")
          ),
          
          tags$p(tags$strong("Step 3: Rebase to October 2006:")),
          tags$p("October 2006 raw CFHI: 58.3 (calculated from actual Oct 2006 data)"),
          tags$div(
            style = "font-family:'Courier New', monospace; background:#ffffff; padding:15px; margin:10px 0; font-size:16px; border:2px solid #4caf50; border-radius:5px;",
            "Rebased CFHI = (38.3 ÷ 58.3) × 100 = ", tags$strong(style = "color:#2e7d32; font-size:18px;", "65.7")
          ),
          
          tags$p(
            style = "font-size:14px; margin-top:15px;",
            tags$strong("Interpretation: "), 
            "A score of 65.7 means American consumers' financial health in January 2025 is about 66% of what it was in October 2006 - 
            reflecting low savings rates (barely above historic lows) and elevated borrowing costs, partially offset by decent wage growth."
          )
        ),
        
        hr(style = "border-top: 1px solid #ccc;"),
        
        tags$div(
          style = "background:#f5f5f5; padding:15px; border-left:4px solid #757575; border-radius:5px;",
          tags$p(
            style = "color:#424242; font-size:13px; margin:0;",
            tags$strong("Data Updates: "), 
            "The national CFHI is calculated monthly using the latest available government data. Savings rate data from BEA typically lags by 1 month, 
            while wage, inflation, and interest rate data from BLS and FRED are more current. Historical values may be revised as agencies update their estimates."
          )
        )
      )
    )
  )
)
