library(readxl)

state_data <- reactive({
  df <- read_csv("Financial_Calculator_datasets/State_Data_Demographics.csv", show_col_types = FALSE)
  df
})

output$metric_explanation <- renderText({
  switch(input$map_metric,
    "median_income" = "Unit: U.S. Dollars ($). Definition: The middle value of household income where half earn more and half earn less. Higher values indicate better economic conditions (shown in green).",
    "unemployment" = "Unit: Percentage (%). Definition: Proportion of the labor force actively seeking work but unable to find employment. Lower values indicate better economic conditions (shown in green).",
    "poverty" = "Unit: Percentage (%). Definition: Proportion of the population living below the federal poverty line ($31,200 annual income for a family of 4 in 2023). Lower values indicate better economic conditions (shown in green).",
    "cost_living" = "Unit: Index (100 = U.S. average). Definition: Relative cost of goods and services. Values below 100 are cheaper than average (e.g., 88 = 12% below average), values above 100 are more expensive (e.g., 151.7 = 51.7% above average). Lower values indicate more affordable living (shown in green)."
  )
})

observe({
  df <- state_data()
  state_names <- sort(unique(df$State))
  
  updateSelectInput(session, "compare_state_1", choices = state_names, selected = state_names[1])
  updateSelectInput(session, "compare_state_2", choices = state_names, selected = state_names[2])
})

output$state_map <- renderPlotly({
  df <- state_data()
  metric <- input$map_metric
  
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
  
  # Calculate quartiles for better color distribution
  if (nrow(df_no_na) > 0) {
    q1 <- quantile(df_no_na$map_value, 0.25, na.rm = TRUE)
    q2 <- quantile(df_no_na$map_value, 0.50, na.rm = TRUE)
    q3 <- quantile(df_no_na$map_value, 0.75, na.rm = TRUE)
    min_val <- min(df_no_na$map_value, na.rm = TRUE)
    max_val <- max(df_no_na$map_value, na.rm = TRUE)
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
  
  # Color scale with more granular steps for better differentiation
  # For unemployment/poverty, lower is better (green), higher is worse (red)
  # For income, higher is better (green), lower is worse (red)
  # For cost_living, lower is better (green), higher is worse (red)
  color_scale <- if (metric %in% c("unemployment", "poverty", "cost_living")) {
    list(
      c(0, "#16a34a"),      # Best (dark green)
      c(0.25, "#65a30d"),   # Good (light green)
      c(0.5, "#eab308"),    # Medium (yellow)
      c(0.75, "#f97316"),   # Poor (orange)
      c(1, "#dc2626")       # Worst (red)
    )
  } else {  # median_income
    list(
      c(0, "#dc2626"),      # Worst (red)
      c(0.25, "#f97316"),   # Poor (orange)
      c(0.5, "#eab308"),    # Medium (yellow)
      c(0.75, "#65a30d"),   # Good (light green)
      c(1, "#16a34a")       # Best (dark green)
    )
  }
  
  plot_geo(
    data = df,
    locationmode = "USA-states"
  ) %>%
    add_trace(
      locations = ~State_Code,
      z = ~map_value,
      text = ~hover_text,
      hoverinfo = "text",
      type = "choropleth",
      colorscale = color_scale,
      colorbar = list(
        title = list(
          text = metric_title,
          side = "right"
        )
      ),
      zmin = if (nrow(df_no_na) > 0) min_val else NULL,
      zmax = if (nrow(df_no_na) > 0) max_val else NULL
    ) %>%
    layout(
      title = paste("U.S. State-Level", metric_title),
      geo = list(
        scope = "usa",
        projection = list(type = "albers usa"),
        showlakes = TRUE,
        lakecolor = toRGB("white")
      )
    )
})

output$top_states <- renderTable({
  df <- state_data()
  metric <- input$map_metric
  
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

output$bottom_states <- renderTable({
  df <- state_data()
  metric <- input$map_metric
  
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

comparison_data <- eventReactive(input$compare_states, {
  df <- state_data()
  
  state1 <- df %>% filter(State == input$compare_state_1)
  state2 <- df %>% filter(State == input$compare_state_2)
  
  list(state1 = state1, state2 = state2)
})

output$comparison_output <- renderUI({
  comp <- comparison_data()
  
  if (nrow(comp$state1) == 0 || nrow(comp$state2) == 0) {
    return(p("Select states to compare"))
  }
  
  s1 <- comp$state1
  s2 <- comp$state2
  
  fluidRow(
    column(
      6,
      h4(s1$State),
      tags$table(
        class = "table table-sm",
        tags$tr(
          tags$td(tags$b("Median Household Income:")), 
          tags$td(paste0("$", format(round(s1$Median_Income), big.mark = ",")), 
                  tags$br(), 
                  tags$small(style = "color:#666;", "Unit: U.S. Dollars"))
        ),
        tags$tr(
          tags$td(tags$b("Unemployment Rate:")), 
          tags$td(paste0(round(s1$Unemployment_Rate, 1), "%"),
                  tags$br(),
                  tags$small(style = "color:#666;", "Unit: Percentage of labor force"))
        ),
        tags$tr(
          tags$td(tags$b("Poverty Rate:")), 
          tags$td(paste0(round(s1$Poverty_Rate, 1), "%"),
                  tags$br(),
                  tags$small(style = "color:#666;", "Unit: Percentage of population"))
        ),
        tags$tr(
          tags$td(tags$b("Cost of Living Index:")), 
          tags$td(round(s1$Cost_of_Living_Index, 1),
                  tags$br(),
                  tags$small(style = "color:#666;", "Unit: Index (100 = U.S. average)"))
        )
      )
    ),
    column(
      6,
      h4(s2$State),
      tags$table(
        class = "table table-sm",
        tags$tr(
          tags$td(tags$b("Median Household Income:")), 
          tags$td(paste0("$", format(round(s2$Median_Income), big.mark = ",")),
                  tags$br(),
                  tags$small(style = "color:#666;", "Unit: U.S. Dollars"))
        ),
        tags$tr(
          tags$td(tags$b("Unemployment Rate:")), 
          tags$td(paste0(round(s2$Unemployment_Rate, 1), "%"),
                  tags$br(),
                  tags$small(style = "color:#666;", "Unit: Percentage of labor force"))
        ),
        tags$tr(
          tags$td(tags$b("Poverty Rate:")), 
          tags$td(paste0(round(s2$Poverty_Rate, 1), "%"),
                  tags$br(),
                  tags$small(style = "color:#666;", "Unit: Percentage of population"))
        ),
        tags$tr(
          tags$td(tags$b("Cost of Living Index:")), 
          tags$td(round(s2$Cost_of_Living_Index, 1),
                  tags$br(),
                  tags$small(style = "color:#666;", "Unit: Index (100 = U.S. average)"))
        )
      )
    )
  )
})
