tabItem(
  tabName = "about",
  
  fluidRow(
    column(12,
      h2(style = "font-weight: 600; color: #1e293b; margin-bottom: 20px;", 
         "About Financial Health Analytics Dashboard"),
      p(style = "color: #64748b; font-size: 15px; margin-bottom: 30px;",
        "A comprehensive financial health analytics platform developed for BIOL 185.")
    )
  ),
  
  # Project Overview
  fluidRow(
    box(
      title = "Project Overview",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      
      tags$div(
        style = "padding: 15px; line-height: 1.8;",
        
        tags$p(
          style = "color: #475569; font-size: 15px;",
          "The ", tags$strong("Financial Health Analytics Dashboard"), " provides comprehensive analysis of household financial well-being through the Composite Financial Health Index (CFHI). ",
          "This platform integrates economic time series analysis, statistical forecasting, market correlation studies, state-level comparisons, and personal finance tools. ",
          "Built as a data science visualization project for BIOL 185."
        ),
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Key Capabilities"),
        tags$ul(
          style = "color: #475569; font-size: 15px;",
          tags$li(tags$strong("CFHI Analysis:"), " Track household financial health index from 2000-2025 using four normalized economic indicators"),
          tags$li(tags$strong("Key Findings:"), " Academic analysis of historical patterns including 2007 pre-crisis trough, 2020 pandemic peak, and current affordability pressures"),
          tags$li(tags$strong("Time Series Forecasting:"), " Ensemble ARIMA/ETS models with scenario-based projections"),
          tags$li(tags$strong("Market Correlation:"), " Regression analysis quantifying minimal S&P 500 impact on household finances"),
          tags$li(tags$strong("State Comparisons:"), " Geographic analysis of economic indicators across U.S. states"),
          tags$li(tags$strong("Personal Finance Tools:"), " Loan calculators, retirement planning, and savings guides")
        )
      )
    )
  ),
  
  # Development Team
  fluidRow(
    box(
      title = "Development Team",
      status = "primary",
      solidHeader = TRUE,
      width = 6,
      
      tags$div(
        style = "padding: 15px;",
        tags$p(
          style = "color: #475569; font-size: 15px; margin-bottom: 20px;",
          "This project was developed by:"
        ),
        tags$ul(
          style = "color: #475569; font-size: 15px; line-height: 2;",
          tags$li(tags$strong("Ammar Alhajmee")),
          tags$li(tags$strong("Bemnet Ali")),
          tags$li(tags$strong("Colin Bridges"))
        ),
        tags$p(
          style = "color: #64748b; font-size: 14px; margin-top: 20px;",
          "Course: BIOL 185 - Data Science: Visualizing and Exploring Big Data"
        )
      )
    ),
    
    box(
      title = "Technical Stack",
      status = "primary",
      solidHeader = TRUE,
      width = 6,
      
      tags$div(
        style = "padding: 15px;",
        tags$ul(
          style = "color: #475569; font-size: 15px; line-height: 2;",
          tags$li(tags$strong("Framework:"), " R Shiny with shinydashboard"),
          tags$li(tags$strong("Visualization:"), " plotly, ggplot2"),
          tags$li(tags$strong("Data Processing:"), " tidyverse (dplyr, tidyr, readr)"),
          tags$li(tags$strong("Time Series:"), " forecast package"),
          tags$li(tags$strong("Statistical Modeling:"), " glmnet")
        )
      )
    )
  ),
  
  # Data Sources Section
  fluidRow(
    box(
      title = "Data Sources",
      status = "warning",
      solidHeader = TRUE,
      width = 12,
      
      tags$div(
        style = "padding: 15px; line-height: 1.8;",
        
        tags$h4(style = "color: #1e293b; margin-bottom: 15px;", "CFHI Components"),
        tags$ul(
          style = "color: #475569; font-size: 15px;",
          tags$li(tags$strong("Bureau of Economic Analysis (BEA):"), " Personal savings rate"),
          tags$li(tags$strong("Bureau of Labor Statistics (BLS):"), " Average hourly earnings growth, Consumer Price Index (CPI-U)"),
          tags$li(tags$strong("Federal Reserve Economic Data (FRED):"), " Federal funds effective rate"),
          tags$li(tags$strong("Coverage:"), " January 2000 to August 2025 (233 monthly observations)")
        ),
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Market Data"),
        tags$ul(
          style = "color: #475569; font-size: 15px;",
          tags$li(tags$strong("FactSet Research Systems:"), " S&P 500 price history, total returns, volume data"),
          tags$li(tags$strong("Coverage:"), " April 2006 to August 2025, end-of-month observations")
        ),
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "State Economic Data"),
        tags$ul(
          style = "color: #475569; font-size: 15px;",
          tags$li(tags$strong("U.S. Census Bureau:"), " State median income statistics"),
          tags$li(tags$strong("Bureau of Labor Statistics:"), " State unemployment rates"),
          tags$li(tags$strong("Various Sources:"), " Cost of living indices")
        ),
        
        tags$h4(style = "color: #1e293b; margin-top: 25px; margin-bottom: 15px;", "Loan Data"),
        tags$ul(
          style = "color: #475569; font-size: 15px;",
          tags$li(tags$strong("Note:"), " Synthetic dataset created for educational and demonstration purposes"),
          tags$li(tags$strong("Variables:"), " Credit scores, income levels, debt-to-income ratios, approval outcomes")
        )
      )
    )
  ),
  
  # Methodology
  fluidRow(
    box(
      title = "Methodology Notes",
      status = "info",
      solidHeader = TRUE,
      width = 12,
      
      tags$div(
        style = "padding: 15px;",
        tags$ul(
          style = "color: #475569; font-size: 15px; line-height: 1.8;",
          tags$li(tags$strong("CFHI Calculation:"), " Simple average of four min-max normalized components (0-100 scale), equal weighting"),
          tags$li(tags$strong("Normalization:"), " All components scaled using full historical range (Jan 2000 - Aug 2025)"),
          tags$li(tags$strong("Forecasting Method:"), " Ensemble approach averaging ARIMA and ETS models with scenario adjustments"),
          tags$li(tags$strong("Correlation Analysis:"), " Multiple regression controlling for Fed policy to isolate S&P 500 effect"),
          tags$li(tags$strong("Date Standardization:"), " Monthly observations, first day of month convention")
        )
      )
    )
  ),
  
  # Repository and License
  fluidRow(
    box(
      title = "Repository Information",
      status = "success",
      solidHeader = TRUE,
      width = 12,
      
      tags$div(
        style = "padding: 15px; background-color: #f8fafc; border-radius: 8px;",
        tags$p(
          style = "color: #334155; font-size: 14px; margin: 0;",
          tags$strong("Project Name:"), " Financial Health Analytics Dashboard"
        ),
        tags$p(
          style = "color: #334155; font-size: 14px; margin-top: 10px; margin-bottom: 0;",
          tags$strong("GitHub Repository:"), " ",
          tags$a(
            href = "https://github.com/WL-Biol185-ShinyProjects/Financial-Health-Analytics-Dashboard",
            target = "_blank",
            style = "color: #3b82f6; text-decoration: none;",
            "WL-Biol185-ShinyProjects/Financial-Health-Analytics-Dashboard"
          )
        ),
        tags$p(
          style = "color: #334155; font-size: 14px; margin-top: 10px; margin-bottom: 0;",
          tags$strong("Course:"), " BIOL 185 - Data Science: Visualizing and Exploring Big Data"
        ),
        tags$p(
          style = "color: #64748b; font-size: 13px; margin-top: 10px; margin-bottom: 0;",
          "Last Updated: November 2025"
        )
      )
    )
  )
)
