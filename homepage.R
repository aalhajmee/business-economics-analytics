tabItem(
  tabName = "home",
  
  # Hero section
  tags$div(
    style = "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
             padding: 60px 40px;
             border-radius: 16px;
             margin-bottom: 40px;
             box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
             text-align: center;",
    tags$h1(
      style = "color: white; 
               margin: 0 0 16px 0; 
               font-size: 48px; 
               font-weight: 800;
               text-shadow: 2px 2px 4px rgba(0,0,0,0.2);",
      "💰 Financial Health Dashboard"
    ),
    tags$p(
      style = "color: rgba(255,255,255,0.95); 
               font-size: 20px; 
               margin: 0 0 24px 0;
               font-weight: 400;
               max-width: 800px;
               margin-left: auto;
               margin-right: auto;",
      "Your comprehensive toolkit for analyzing consumer financial health, planning budgets, and making informed financial decisions"
    )
  ),
  
  # Feature cards
  fluidRow(
    column(
      width = 3,
      tags$div(
        style = "background: white;
                 padding: 24px;
                 border-radius: 12px;
                 text-align: center;
                 box-shadow: 0 4px 15px rgba(0,0,0,0.08);
                 border: 2px solid #e5e7eb;
                 height: 100%;
                 transition: transform 0.2s;",
        tags$div(style = "font-size: 48px; margin-bottom: 12px;", "📊"),
        tags$h3(style = "color: #1f2937; font-weight: 600; margin-bottom: 8px;", "CFHI Analysis"),
        tags$p(style = "color: #6b7280; font-size: 14px; margin: 0;", 
               "Track the Consumer Financial Health Index with interactive charts and economic indicators")
      )
    ),
    column(
      width = 3,
      tags$div(
        style = "background: white;
                 padding: 24px;
                 border-radius: 12px;
                 text-align: center;
                 box-shadow: 0 4px 15px rgba(0,0,0,0.08);
                 border: 2px solid #e5e7eb;
                 height: 100%;",
        tags$div(style = "font-size: 48px; margin-bottom: 12px;", "🔍"),
        tags$h3(style = "color: #1f2937; font-weight: 600; margin-bottom: 8px;", "Explore Data"),
        tags$p(style = "color: #6b7280; font-size: 14px; margin: 0;", 
               "Dive deep into economic data with interactive maps and visualizations")
      )
    ),
    column(
      width = 3,
      tags$div(
        style = "background: white;
                 padding: 24px;
                 border-radius: 12px;
                 text-align: center;
                 box-shadow: 0 4px 15px rgba(0,0,0,0.08);
                 border: 2px solid #e5e7eb;
                 height: 100%;",
        tags$div(style = "font-size: 48px; margin-bottom: 12px;", "💡"),
        tags$h3(style = "color: #1f2937; font-weight: 600; margin-bottom: 8px;", "Savings Guide"),
        tags$p(style = "color: #6b7280; font-size: 14px; margin: 0;", 
               "Use the 50/30/20 rule to optimize your budget and improve financial health")
      )
    ),
    column(
      width = 3,
      tags$div(
        style = "background: white;
                 padding: 24px;
                 border-radius: 12px;
                 text-align: center;
                 box-shadow: 0 4px 15px rgba(0,0,0,0.08);
                 border: 2px solid #e5e7eb;
                 height: 100%;",
        tags$div(style = "font-size: 48px; margin-bottom: 12px;", "🏦"),
        tags$h3(style = "color: #1f2937; font-weight: 600; margin-bottom: 8px;", "Loan Calculator"),
        tags$p(style = "color: #6b7280; font-size: 14px; margin: 0;", 
               "Estimate loan approval probability based on your financial profile")
      )
    )
  ),
  
  br(),
  
  # Quick start guide
  tags$div(
    style = "background: #f9fafb;
             padding: 32px;
             border-radius: 12px;
             border-left: 4px solid #3b82f6;
             margin-top: 30px;",
    tags$h3(
      style = "color: #1f2937; 
               font-weight: 600; 
               margin-top: 0;
               margin-bottom: 16px;",
      "🚀 Getting Started"
    ),
    tags$p(
      style = "color: #4b5563; 
               font-size: 15px; 
               line-height: 1.6;
               margin-bottom: 12px;",
      "This dashboard provides comprehensive tools for financial analysis and planning:"
    ),
    tags$ul(
      style = "color: #4b5563; 
               font-size: 15px; 
               line-height: 1.8;
               margin: 0;",
      tags$li(tags$strong("CFHI Tab:"), " Analyze consumer financial health trends from 2000 onwards with interactive visualizations"),
      tags$li(tags$strong("Explore Tab:"), " Discover geographic data patterns and insights"),
      tags$li(tags$strong("Savings Guide:"), " Input your income and expenses to get personalized budget recommendations"),
      tags$li(tags$strong("Loan Calculator:"), " Evaluate your loan approval chances based on key financial metrics")
    )
  )
)

