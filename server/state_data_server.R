# ---- STATE DATA SOURCES TAB SERVER LOGIC ----
# Handles state economic data table display and downloads

# Render state economic data table
output$state_data_table <- DT::renderDT({
  df <- read_csv("data/state/State_Data_Demographics.csv", show_col_types = FALSE)
  # Filter out DC and Puerto Rico
  df <- df %>% filter(!State %in% c("District of Columbia", "Puerto Rico"))
  # Format the data for display
  df_display <- df %>%
    mutate(
      Median_Income = paste0("$", format(round(Median_Income), big.mark = ",")),
      Unemployment_Rate = paste0(round(Unemployment_Rate, 1), "%"),
      Poverty_Rate = paste0(round(Poverty_Rate, 1), "%"),
      Cost_of_Living_Index = round(Cost_of_Living_Index, 1)
    ) %>%
    select(
      State,
      `State Code` = State_Code,
      `Median Income` = Median_Income,
      `Unemployment Rate` = Unemployment_Rate,
      `Poverty Rate` = Poverty_Rate,
      `Cost of Living Index` = Cost_of_Living_Index
    )
  DT::datatable(
    df_display,
    options = list(
      pageLength = 25,
      scrollX = TRUE,
      searchHighlight = TRUE,
      dom = 'Bfrtip',
      buttons = c('copy', 'excel', 'pdf')
    ),
    rownames = FALSE,
    class = 'cell-border stripe hover',
    filter = 'top'
  )
})

# Download handler for state data
output$download_state_data <- downloadHandler(
  filename = function() {
    paste0("state_economic_data_", Sys.Date(), ".csv")
  },
  content = function(file) {
    df <- read_csv("data/state/State_Data_Demographics.csv", show_col_types = FALSE)
    # Filter out DC and Puerto Rico
    df <- df %>% filter(!State %in% c("District of Columbia", "Puerto Rico"))
    write_csv(df, file)
  }
)
