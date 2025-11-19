# ============================================================================
# Data Table - Server Logic
# ============================================================================

data_table_server <- function(input, output, session, macro_data, shared_state) {
  
  # Load state data
  state_data <- reactive({
    df <- read_csv("data/state/State_Data_Demographics.csv", show_col_types = FALSE)
    df <- df %>% filter(!State %in% c("District of Columbia", "Puerto Rico"))
    df
  })
  
  # Reactive data selection
  selected_data <- reactive({
    if (is.null(input$data_source_selector) || input$data_source_selector == "wdi") {
      return(macro_data)
    } else {
      return(state_data())
    }
  })
  
  # Render Table with Server-Side Processing (Efficient for large data)
  output$data_explorer_table <- renderDT({
    data <- selected_data()
    req(data)
    
    datatable(data,
              options = list(
                pageLength = 20, 
                scrollX = TRUE,
                dom = 'lfrtip'
              ),
              filter = "top",
              rownames = FALSE
    )
  }, server = TRUE)
  
  # Handle CSV Download Logic
  output$download_csv <- downloadHandler(
    filename = function() {
      source_name <- if (is.null(input$data_source_selector) || input$data_source_selector == "wdi") {
        "wdi"
      } else {
        "states"
      }
      paste("financial_insight_data_", source_name, "_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      data <- selected_data()
      write.csv(data, file, row.names = FALSE)
    }
  )
}
