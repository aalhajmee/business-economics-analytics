tabItem(
  tabName = "cfhi_data",
  h2("CFHI Data Sources"),
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
  )
)
