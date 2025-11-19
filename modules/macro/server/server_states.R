# ============================================================================
# U.S. States Analysis - Server Logic
# ============================================================================

states_server <- function(input, output, session, shared_state) {
  
  # Load state data
  state_data <- reactive({
    df <- read_csv("data/state/State_Data_Demographics.csv", show_col_types = FALSE)
    # Filter out DC and Puerto Rico - only show the 50 U.S. states
    df <- df %>% filter(!State %in% c("District of Columbia", "Puerto Rico"))
    df
  })
  
  output$states_metric_explanation <- renderText({
    switch(input$states_map_metric,
      "median_income" = "Unit: U.S. Dollars ($). Definition: The middle value of household income where half earn more and half earn less. Higher values indicate better economic conditions (shown in green).",
      "unemployment" = "Unit: Percentage (%). Definition: Proportion of the labor force actively seeking work but unable to find employment. Lower values indicate better economic conditions (shown in green).",
      "poverty" = "Unit: Percentage (%). Definition: Proportion of the population living below the federal poverty line ($31,200 annual income for a family of 4 in 2023). Lower values indicate better economic conditions (shown in green).",
      "cost_living" = "Unit: Index (100 = U.S. average). Definition: Relative cost of goods and services. Values below 100 are cheaper than average (e.g., 88 = 12% below average), values above 100 are more expensive (e.g., 151.7 = 51.7% above average). Lower values indicate more affordable living (shown in green)."
    )
  })
  
  observe({
    df <- state_data()
    state_names <- sort(unique(df$State))
    
    updateSelectizeInput(session, "states_compare_state_1", choices = state_names, selected = state_names[1])
    updateSelectizeInput(session, "states_compare_state_2", choices = state_names, selected = state_names[2])
  })
  
  output$states_map <- renderPlotly({
    df <- state_data()
    metric <- input$states_map_metric
    req(metric)
    
    metric_col <- switch(
      metric,
      "median_income" = "Median_Income",
      "unemployment" = "Unemployment_Rate",
      "poverty" = "Poverty_Rate",
      "cost_living" = "Cost_of_Living_Index"
    )
    
    metric_title <- switch(
      metric,
      "median_income" = "Median Household Income",
      "unemployment" = "Unemployment Rate",
      "poverty" = "Poverty Rate",
      "cost_living" = "Cost of Living Index"
    )
    
    if (!metric_col %in% names(df)) {
      return(plot_ly() %>% layout(title = "Data not available for selected metric"))
    }
    
    # Create a column for the z values that plotly can access
    df$map_value <- df[[metric_col]]
    
    # Remove NA values for color scale calculation
    df_no_na <- df[!is.na(df$map_value), ]
    
    # Calculate dynamic color range (matching global map style)
    if (nrow(df_no_na) > 0) {
      data_values <- df_no_na$map_value
      data_min <- min(data_values, na.rm = TRUE)
      data_max <- max(data_values, na.rm = TRUE)
      
      # For median income, use 95th percentile to avoid outliers
      if (metric == "median_income") {
        scale_max <- quantile(data_values, 0.95, na.rm = TRUE)
        scale_min <- data_min
      } else {
        scale_max <- data_max
        scale_min <- data_min
      }
    } else {
      scale_min <- 0
      scale_max <- 1
    }
    
    # Create properly formatted hover text with units
    df$hover_text <- sapply(seq_len(nrow(df)), function(i) {
      value <- df[[metric_col]][i]
      if (is.na(value)) {
        formatted_value <- "Data Not Available"
      } else if (metric == "median_income") {
        formatted_value <- paste0("$", format(round(value), big.mark = ","))
      } else if (metric %in% c("unemployment", "poverty")) {
        formatted_value <- paste0(round(value, 1), "%")
      } else {  # cost_living
        formatted_value <- paste0(round(value, 1), " (100 = U.S. avg)")
      }
      
      paste0(
        "<b>", df$State[i], "</b><br>",
        metric_title, ": ", formatted_value
      )
    })
    
    # Use same style as global map - "Blues" color scale
    plot_geo(
      data = df,
      locationmode = "USA-states"
    ) %>%
      add_trace(
        locations = ~State_Code,
        z = ~map_value,
        color = ~map_value,
        colors = "Blues",
        text = ~hover_text,
        hoverinfo = "text",
        marker = list(line = list(color = 'rgb(255,255,255)', width = 0.5)),
        zmin = scale_min,
        zmax = scale_max
      ) %>%
      colorbar(title = metric_title, len = 0.9) %>%
      layout(
        title = list(text = paste("U.S. State-Level", metric_title), font = list(color = "#1e293b", size = 18)),
        font = list(family = "Inter"),
        geo = list(
          scope = "usa",
          projection = list(type = "albers usa"),
          showframe = FALSE,
          showcoastlines = TRUE,
          coastlinecolor = "#e2e8f0",
          showlakes = TRUE,
          lakecolor = "#f1f5f9",
          landcolor = "#f8fafc",
          bgcolor = "rgba(0,0,0,0)"
        ),
        paper_bgcolor = 'rgba(0,0,0,0)',
        plot_bgcolor = 'rgba(0,0,0,0)',
        margin = list(t = 50, b = 0, l = 0, r = 0)
      )
  })
  
  output$states_top_table <- renderTable({
    df <- state_data()
    metric <- input$states_map_metric
    req(metric)
    
    metric_col <- switch(
      metric,
      "median_income" = "Median_Income",
      "unemployment" = "Unemployment_Rate",
      "poverty" = "Poverty_Rate",
      "cost_living" = "Cost_of_Living_Index"
    )
    
    if (!metric_col %in% names(df)) {
      return(data.frame(State = "N/A", Value = "N/A"))
    }
    
    sorted <- if (metric %in% c("unemployment", "poverty", "cost_living")) {
      df %>% arrange(!!sym(metric_col)) %>% head(5)
    } else {
      df %>% arrange(desc(!!sym(metric_col))) %>% head(5)
    }
    
    result <- sorted %>%
      select(State, Value = !!sym(metric_col))
    
    # Format values with proper units
    if (metric == "median_income") {
      result <- result %>% mutate(Value = paste0("$", format(round(Value), big.mark = ",")))
    } else if (metric %in% c("unemployment", "poverty")) {
      result <- result %>% mutate(Value = paste0(round(Value, 1), "%"))
    } else {  # cost_living
      result <- result %>% mutate(Value = paste0(round(Value, 1)))
    }
    
    result
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
  
  output$states_bottom_table <- renderTable({
    df <- state_data()
    metric <- input$states_map_metric
    req(metric)
    
    metric_col <- switch(
      metric,
      "median_income" = "Median_Income",
      "unemployment" = "Unemployment_Rate",
      "poverty" = "Poverty_Rate",
      "cost_living" = "Cost_of_Living_Index"
    )
    
    if (!metric_col %in% names(df)) {
      return(data.frame(State = "N/A", Value = "N/A"))
    }
    
    sorted <- if (metric %in% c("unemployment", "poverty", "cost_living")) {
      df %>% arrange(desc(!!sym(metric_col))) %>% head(5)
    } else {
      df %>% arrange(!!sym(metric_col)) %>% head(5)
    }
    
    result <- sorted %>%
      select(State, Value = !!sym(metric_col))
    
    # Format values with proper units
    if (metric == "median_income") {
      result <- result %>% mutate(Value = paste0("$", format(round(Value), big.mark = ",")))
    } else if (metric %in% c("unemployment", "poverty")) {
      result <- result %>% mutate(Value = paste0(round(Value, 1), "%"))
    } else {  # cost_living
      result <- result %>% mutate(Value = paste0(round(Value, 1)))
    }
    
    result
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
  
  comparison_data <- eventReactive(input$states_compare_btn, {
    df <- state_data()
    
    state1 <- df %>% filter(State == input$states_compare_state_1)
    state2 <- df %>% filter(State == input$states_compare_state_2)
    
    list(state1 = state1, state2 = state2)
  })
  
  output$states_comparison_output <- renderUI({
    comp <- comparison_data()
    
    if (nrow(comp$state1) == 0 || nrow(comp$state2) == 0) {
      return(p("Select states to compare"))
    }
    
    s1 <- comp$state1
    s2 <- comp$state2
    
    fluidRow(
      column(6,
        h4(s1$State),
        tags$table(
          class = "table table-sm",
          tags$tr(
            tags$td(tags$b("Median Household Income:")), 
            tags$td(paste0("$", format(round(s1$Median_Income), big.mark = ",")), 
                    tags$br(), 
                    tags$small(style = "color:#64748b;", "Unit: U.S. Dollars"))
          ),
          tags$tr(
            tags$td(tags$b("Unemployment Rate:")), 
            tags$td(paste0(round(s1$Unemployment_Rate, 1), "%"),
                    tags$br(),
                    tags$small(style = "color:#64748b;", "Unit: Percentage of labor force"))
          ),
          tags$tr(
            tags$td(tags$b("Poverty Rate:")), 
            tags$td(paste0(round(s1$Poverty_Rate, 1), "%"),
                    tags$br(),
                    tags$small(style = "color:#64748b;", "Unit: Percentage of population"))
          ),
          tags$tr(
            tags$td(tags$b("Cost of Living Index:")), 
            tags$td(round(s1$Cost_of_Living_Index, 1),
                    tags$br(),
                    tags$small(style = "color:#64748b;", "Unit: Index (100 = U.S. average)"))
          )
        )
      ),
      column(6,
        h4(s2$State),
        tags$table(
          class = "table table-sm",
          tags$tr(
            tags$td(tags$b("Median Household Income:")), 
            tags$td(paste0("$", format(round(s2$Median_Income), big.mark = ",")),
                    tags$br(),
                    tags$small(style = "color:#64748b;", "Unit: U.S. Dollars"))
          ),
          tags$tr(
            tags$td(tags$b("Unemployment Rate:")), 
            tags$td(paste0(round(s2$Unemployment_Rate, 1), "%"),
                    tags$br(),
                    tags$small(style = "color:#64748b;", "Unit: Percentage of labor force"))
          ),
          tags$tr(
            tags$td(tags$b("Poverty Rate:")), 
            tags$td(paste0(round(s2$Poverty_Rate, 1), "%"),
                    tags$br(),
                    tags$small(style = "color:#64748b;", "Unit: Percentage of population"))
          ),
          tags$tr(
            tags$td(tags$b("Cost of Living Index:")), 
            tags$td(round(s2$Cost_of_Living_Index, 1),
                    tags$br(),
                    tags$small(style = "color:#64748b;", "Unit: Index (100 = U.S. average)"))
          )
        )
      )
    )
  })
}

