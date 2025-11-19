# tabs/employment_tab.R
tabItem(
  tabName = "employment",
  h2("State Employment Data - Interactive Map",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  
  fluidRow(
    column(12,
           box(
             title = "About This Dataset",
             width = 12,
             status = "primary",
             solidHeader = TRUE,
             
             tags$div(style = "font-size:14px;",
                      tags$p("This dataset provides comprehensive state-level employment statistics from the Bureau of Labor Statistics' Job Openings and Labor Turnover Survey (JOLTS). The data tracks job market dynamics through job openings, hires, and voluntary separations (quits) across all 50 U.S. states."),
                      
                      tags$h4("Data Fields Explanation:"),
                      tags$ul(
                        tags$li(tags$b("Job Opening Rate:"), " Percentage of total employment plus job openings that are unfilled positions. Higher rates indicate more available opportunities relative to workforce size."),
                        tags$li(tags$b("Job Opening Levels:"), " Total number of unfilled job positions (in thousands) available at the end of the month. Represents employer demand for workers."),
                        tags$li(tags$b("Hiring Rate:"), " Monthly hires as a percentage of total employment. Measures the pace at which employers are filling positions."),
                        tags$li(tags$b("Hiring Levels:"), " Total number of workers hired (in thousands) during the month. Includes new and replacement hires."),
                        tags$li(tags$b("Quitting Rate:"), " Voluntary separations as a percentage of total employment. Often viewed as an indicator of worker confidence in finding new jobs."),
                        tags$li(tags$b("Quitting Levels:"), " Total number of workers (in thousands) who voluntarily left their jobs during the month, excluding retirements.")
                      )
             )
           )
    )
  ),
  
  fluidRow(
    column(
      width = 3,
      
      box(
        title = "Map Settings",
        width = NULL,
        status = "primary",
        solidHeader = TRUE,
        
        selectInput(
          "map_metric_employment",
          "Select Metric:",
          choices = c(
            "Job Opening Rate" = "job_open_rate",
            "Job Openings (Levels)" = "job_open_level",
            "Hiring Rate" = "hiring_rate",
            "Hires (Levels)" = "hiring_level",
            "Quitting Rate" = "quitting_rate",
            "Quits (Levels)" = "quitting_level"
          ),
          selected = "job_open_rate"
        ),
        
        selectInput(
          "time_period_employment",
          "Select Time Period:",
          choices = c(
            "July 2025" = "july_2025",
            "June 2025" = "june_2025",
            "May 2025" = "may_2025",
            "April 2025" = "april_2025",
            "July 2024" = "july_2024"
          ),
          selected = "july_2025"
        )
      )
    ),
    
    column(
      width = 9,
      
      # Metric explanation
      box(
        title = "Metric Information",
        width = NULL,
        status = "info",
        solidHeader = TRUE,
        tags$div(style = "font-size:14px;",
                 textOutput("metric_explanation_employment")
        )
      ),
      
      # Main map
      box(
        width = NULL,
        status = "primary",
        solidHeader = TRUE,
        title = "Interactive Employment Map",
        tags$p(style = "font-size:14px; margin-bottom:15px;", 
               "Hover over states to see detailed statistics. Use the dropdown menus on the left to change the metric and time period displayed."),
        plotlyOutput("employment_map_other", height = "500px")
      )
    )
  ),
  
  fluidRow(
    column(
      width = 6,
      box(
        width = NULL,
        status = "success",
        solidHeader = TRUE,
        title = "Top 5 States",
        tags$p(style = "font-size:14px;", "States with the highest values for the selected metric."),
        tableOutput("top_states_employment")
      )
    ),
    column(
      width = 6,
      box(
        width = NULL,
        status = "danger",
        solidHeader = TRUE,
        title = "Bottom 5 States",
        tags$p(style = "font-size:14px;", "States with the lowest values for the selected metric."),
        tableOutput("bottom_states_employment")
      )
    )
  ),
  
  fluidRow(
    column(12,
           box(
             title = "Data Source Information",
             width = 12,
             status = "warning",
             solidHeader = TRUE,
             collapsible = TRUE,
             collapsed = TRUE,
             
             tags$div(style = "font-size:14px;",
                      tags$div(style = "margin-bottom:20px;",
                               tags$h5(tags$b("Bureau of Labor Statistics (BLS) - JOLTS")),
                               tags$ul(
                                 tags$li(tags$b("Source:"), " Job Openings and Labor Turnover Survey (JOLTS)"),
                                 tags$li(tags$b("Coverage:"), " All 50 U.S. states, monthly data"),
                                 tags$li(tags$b("Collection Method:"), " Survey of approximately 21,000 establishments covering all industries"),
                                 tags$li(tags$b("URL:"), tags$a(href = "https://www.bls.gov/jlt/", target = "_blank", "https://www.bls.gov/jlt/")),
                                 tags$li(tags$b("Data Period:"), " July 2024 - July 2025"),
                                 tags$li(tags$b("Release Schedule:"), " Monthly, approximately 6 weeks after reference month")
                               )
                      ),
                      
                      tags$h4("Definitions & Methodology:"),
                      tags$ul(
                        tags$li(tags$b("Job Openings:"), " Positions that are open (not filled) on the last business day of the month, could start within 30 days, and employer is actively recruiting"),
                        tags$li(tags$b("Hires:"), " All additions to payroll during the month, including new employees and recalls"),
                        tags$li(tags$b("Quits:"), " Voluntary separations initiated by the employee (excludes layoffs, discharges, retirements, transfers, and deaths)"),
                        tags$li(tags$b("Rates:"), " Calculated as the number divided by employment plus job openings (for openings rate) or employment (for hires/quits rates), then multiplied by 100")
                      ),
                      
                      tags$h4(style = "margin-top:20px;", "Data Limitations:"),
                      tags$ul(
                        tags$li("State-level JOLTS data has higher sampling variability than national estimates"),
                        tags$li("Some months may show volatility due to seasonal factors or one-time events"),
                        tags$li("Data represents establishment-based counts, not individual workers"),
                        tags$li("Preliminary estimates may be revised in subsequent releases")
                      )
             )
           )
    )
  )
)