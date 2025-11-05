tabItem(
  tabName = "state_data",
  h2("State Economic Data Sources",
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
          tags$p("This dataset combines official economic indicators for all 50 U.S. states from multiple authoritative government and research sources. The data provides a comprehensive view of state-level economic health through four key metrics."),
          
          tags$h4("Data Fields Explanation:"),
          tags$ul(
            tags$li(tags$b("State:"), " Full name of the U.S. state"),
            tags$li(tags$b("State_Code:"), " Two-letter postal abbreviation (e.g., CA, NY, TX)"),
            tags$li(tags$b("Median_Income:"), " Median household income in U.S. dollars. This represents the middle value where half of households earn more and half earn less. Based on annual household income from all sources."),
            tags$li(tags$b("Unemployment_Rate:"), " Percentage of the civilian labor force that is actively seeking employment but unable to find work. Measured as a percentage of the total labor force."),
            tags$li(tags$b("Poverty_Rate:"), " Percentage of the population living below the federal poverty threshold. For 2023, the poverty line is $31,200 for a family of four. Includes all age groups."),
            tags$li(tags$b("Cost_of_Living_Index:"), " Composite index measuring relative cost of goods and services. Baseline of 100 represents the U.S. national average. Values above 100 indicate higher costs (e.g., 151.7 = 51.7% more expensive), values below 100 indicate lower costs (e.g., 88 = 12% cheaper).")
          )
        )
      )
    )
  ),
  
  fluidRow(
    column(12,
      box(
        title = "Official Data Sources",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        
        tags$div(style = "font-size:14px;",
          tags$h4("Primary Data Sources:"),
          
          tags$div(style = "margin-bottom:20px;",
            tags$h5(tags$b("1. U.S. Census Bureau - American Community Survey (ACS)")),
            tags$ul(
              tags$li(tags$b("Source:"), " American Community Survey 2023 5-Year Estimates"),
              tags$li(tags$b("Tables Used:"), " B19013 (Median Household Income), B17001 (Poverty Status)"),
              tags$li(tags$b("Collection Method:"), " Annual survey of approximately 3.5 million households"),
              tags$li(tags$b("URL:"), tags$a(href = "https://www.census.gov/programs-surveys/acs", target = "_blank", "https://www.census.gov/programs-surveys/acs")),
              tags$li(tags$b("API Access:"), " Census Bureau API v2.0"),
              tags$li(tags$b("Data Vintage:"), " 2023 (5-year estimates 2019-2023)")
            )
          ),
          
          tags$div(style = "margin-bottom:20px;",
            tags$h5(tags$b("2. Bureau of Labor Statistics (BLS)")),
            tags$ul(
              tags$li(tags$b("Source:"), " Local Area Unemployment Statistics (LAUS)"),
              tags$li(tags$b("Series:"), " State-level unemployment rates"),
              tags$li(tags$b("Collection Method:"), " Monthly Current Population Survey (CPS) combined with state unemployment insurance records"),
              tags$li(tags$b("URL:"), tags$a(href = "https://www.bls.gov/lau/", target = "_blank", "https://www.bls.gov/lau/")),
              tags$li(tags$b("API Access:"), " BLS Public Data API v2"),
              tags$li(tags$b("Data Period:"), " August 2025 (most recent available)")
            )
          ),
          
          tags$div(style = "margin-bottom:20px;",
            tags$h5(tags$b("3. Missouri Economic Research and Information Center (MERIC)")),
            tags$ul(
              tags$li(tags$b("Source:"), " Cost of Living Data Series"),
              tags$li(tags$b("Methodology:"), " Composite index based on Council for Community and Economic Research (C2ER) data"),
              tags$li(tags$b("Components:"), " Housing, utilities, grocery items, transportation, healthcare, and miscellaneous goods/services"),
              tags$li(tags$b("URL:"), tags$a(href = "https://meric.mo.gov/data/cost-living-data-series", target = "_blank", "https://meric.mo.gov/data/cost-living-data-series")),
              tags$li(tags$b("Index Baseline:"), " 100 = U.S. national average"),
              tags$li(tags$b("Data Vintage:"), " 2024 Q3")
            )
          )
        )
      )
    )
  ),
  
  fluidRow(
    column(12,
      box(
        title = "Data Collection Methodology",
        width = 12,
        status = "warning",
        solidHeader = TRUE,
        collapsible = FALSE,
        
        tags$div(style = "font-size:14px;",
          tags$h4("ETL Process:"),
          tags$ol(
            tags$li(tags$b("Extraction:"), " Data retrieved via official government APIs using secure API keys stored in environment variables"),
            tags$li(tags$b("Transformation:"), 
              tags$ul(
                tags$li("Census data: Extracted median income and poverty counts from ACS 5-Year tables"),
                tags$li("BLS data: Retrieved state unemployment rates using LASST series IDs"),
                tags$li("MERIC data: Manually compiled from published cost of living indices"),
                tags$li("State codes standardized to two-letter postal abbreviations"),
                tags$li("Missing values handled: States with unavailable data marked as NA")
              )
            ),
            tags$li(tags$b("Loading:"), " All sources merged on state name, validated for completeness, saved as CSV"),
            tags$li(tags$b("Quality Assurance:"), " Cross-referenced values against published reports, checked for outliers and data consistency")
          ),
          
          tags$h4(style = "margin-top:20px;", "Data Limitations:"),
          tags$ul(
            tags$li("Income and poverty data represent 5-year averages (2019-2023) to ensure statistical reliability for smaller states"),
            tags$li("Unemployment rates are point-in-time estimates (August 2025) and subject to monthly fluctuations"),
            tags$li("Cost of Living Index is a composite measure and may not reflect individual household experiences"),
            tags$li("All data exclude U.S. territories except as noted in source documentation")
          )
        )
      )
    )
  ),
  
  fluidRow(
    column(12,
      box(
        title = "State Economic Data Table",
        width = 12,
        status = "success",
        solidHeader = TRUE,
        
        tags$p(style = "font-size:14px; margin-bottom:15px;", 
               "Complete dataset showing all 50 U.S. states with economic indicators. Use the search box to find specific states, or click column headers to sort."),
        
        downloadButton("download_state_data", "Download Data (CSV)", class = "btn-primary", style = "margin-bottom:15px;"),
        
        DT::DTOutput("state_data_table")
      )
    )
  )
)
