library(readxl)

state_data <- reactive({
  df <- read_csv("Financial_Calculator_datasets/State_Data_Demographics.csv", show_col_types = FALSE)
  df
})

output$metric_explanation <- renderText({
  switch(input$map_metric,
    "median_income" = "💰 Higher income = Better (Green). Shows the middle household earnings - half earn more, half earn less.",
    "unemployment" = "📉 Lower unemployment = Better (Green). Shows % of people actively looking for work but can't find jobs.",
    "poverty" = "📊 Lower poverty = Better (Green). Shows % of people living below federal poverty line ($31,200 for family of 4).",
    "cost_living" = "💵 Lower cost = Better (Green). 100 = U.S. average. California at 151.7 = 51.7% more expensive than average. Alabama at 88 = 12% cheaper than average."
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
    "median_income" = "Median Household Income ($)",
    "unemployment" = "Unemployment Rate (%)",
    "poverty" = "Poverty Rate (%)",
    "cost_living" = "Cost of Living Index"
  )
  
  if (!metric_col %in% names(df)) {
    return(plot_ly() %>% layout(title = "Data not available for selected metric"))
  }
  
  # Create a column for the z values that plotly can access
  df$map_value <- df[[metric_col]]
  
  df$hover_text <- paste0(
    "<b>", df$State, "</b><br>",
    metric_title, ": ", 
    ifelse(metric == "median_income", 
           paste0("$", format(round(df[[metric_col]]), big.mark = ",")),
           round(df[[metric_col]], 2))
  )
  
  # Color scale: for unemployment/poverty, lower is better (green), higher is worse (red)
  # For income/cost_living inverted, higher income is better (green)
  color_scale <- if (metric %in% c("unemployment", "poverty")) {
    list(c(0, "#16a34a"), c(0.5, "#eab308"), c(1, "#dc2626"))
  } else if (metric == "median_income") {
    list(c(0, "#dc2626"), c(0.5, "#eab308"), c(1, "#16a34a"))
  } else {  # cost_living: lower is better
    list(c(0, "#16a34a"), c(0.5, "#eab308"), c(1, "#dc2626"))
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
      colorbar = list(title = metric_title),
      zauto = TRUE
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
  
  sorted <- if (metric %in% c("unemployment", "poverty")) {
    df %>% arrange(!!sym(metric_col)) %>% head(5)
  } else {
    df %>% arrange(desc(!!sym(metric_col))) %>% head(5)
  }
  
  sorted %>%
    select(State, Value = !!sym(metric_col)) %>%
    mutate(Value = round(Value, 2))
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
  
  sorted <- if (metric %in% c("unemployment", "poverty")) {
    df %>% arrange(desc(!!sym(metric_col))) %>% head(5)
  } else {
    df %>% arrange(!!sym(metric_col)) %>% head(5)
  }
  
  sorted %>%
    select(State, Value = !!sym(metric_col)) %>%
    mutate(Value = round(Value, 2))
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
        tags$tr(tags$td("Median Income:"), tags$td(paste0("$", format(s1$Median_Income, big.mark = ",")))),
        tags$tr(tags$td("Unemployment:"), tags$td(paste0(s1$Unemployment_Rate, "%"))),
        tags$tr(tags$td("Poverty Rate:"), tags$td(paste0(s1$Poverty_Rate, "%"))),
        tags$tr(tags$td("Cost of Living:"), tags$td(s1$Cost_of_Living_Index))
      )
    ),
    column(
      6,
      h4(s2$State),
      tags$table(
        class = "table table-sm",
        tags$tr(tags$td("Median Income:"), tags$td(paste0("$", format(s2$Median_Income, big.mark = ",")))),
        tags$tr(tags$td("Unemployment:"), tags$td(paste0(s2$Unemployment_Rate, "%"))),
        tags$tr(tags$td("Poverty Rate:"), tags$td(paste0(s2$Poverty_Rate, "%"))),
        tags$tr(tags$td("Cost of Living:"), tags$td(s2$Cost_of_Living_Index))
      )
    )
  )
})
