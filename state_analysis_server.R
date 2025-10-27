library(readxl)

library(readr)
library(tidyr)

state_data <- reactive({
  df <- read_csv("Financial_Calculator_datasets/State_Data.csv", show_col_types = FALSE)
  
  df_wide <- df %>%
    filter(GeoFips != 0) %>%
    select(GeoName, Description, `2024`) %>%
    tidyr::pivot_wider(names_from = Description, values_from = `2024`)
  
  df_clean <- df_wide %>%
    rename(
      State = GeoName,
      GDP = `  Gross domestic product (GDP)`,
      Personal_Income = `  Personal income`,
      Disposable_Income = `  Disposable personal income`
    ) %>%
    mutate(
      State_Code = state.abb[match(State, state.name)],
      GDP_per_Capita = GDP / 1000,
      Income_per_Capita = Personal_Income / 1000,
      Disposable_per_Capita = Disposable_Income / 1000
    ) %>%
    filter(!is.na(State_Code))
  
  df_clean
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
    "median_income" = "Personal_Income",
    "unemployment" = "GDP_per_Capita",
    "poverty" = "Disposable_per_Capita",
    "cost_living" = "Income_per_Capita"
  )
  
  metric_title <- switch(
    metric,
    "median_income" = "Personal Income (Millions $)",
    "unemployment" = "GDP per Capita",
    "poverty" = "Disposable Income per Capita",
    "cost_living" = "Income per Capita"
  )
  
  if (!metric_col %in% names(df)) {
    return(plot_ly() %>% layout(title = "Data not available for selected metric"))
  }
  
  df$hover_text <- paste0(
    df$State, "<br>",
    metric_title, ": ", round(df[[metric_col]], 2)
  )
  
  color_scale <- list(c(0, "#dc2626"), c(0.5, "#eab308"), c(1, "#16a34a"))
  
  plot_geo(
    data = df,
    locationmode = "USA-states"
  ) %>%
    add_trace(
      locations = ~State_Code,
      z = ~get(metric_col),
      text = ~hover_text,
      hoverinfo = "text",
      type = "choropleth",
      colorscale = color_scale,
      colorbar = list(title = metric_title)
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
    "median_income" = "Personal_Income",
    "unemployment" = "GDP_per_Capita",
    "poverty" = "Disposable_per_Capita",
    "cost_living" = "Income_per_Capita"
  )
  
  if (!metric_col %in% names(df)) {
    return(data.frame(State = "N/A", Value = "N/A"))
  }
  
  sorted <- df %>% arrange(desc(!!sym(metric_col))) %>% head(5)
  
  sorted %>%
    select(State, Value = !!sym(metric_col)) %>%
    mutate(Value = round(Value, 2))
}, striped = TRUE, hover = TRUE, bordered = TRUE)

output$bottom_states <- renderTable({
  df <- state_data()
  metric <- input$map_metric
  
  metric_col <- switch(
    metric,
    "median_income" = "Personal_Income",
    "unemployment" = "GDP_per_Capita",
    "poverty" = "Disposable_per_Capita",
    "cost_living" = "Income_per_Capita"
  )
  
  if (!metric_col %in% names(df)) {
    return(data.frame(State = "N/A", Value = "N/A"))
  }
  
  sorted <- df %>% arrange(!!sym(metric_col)) %>% head(5)
  
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
        tags$tr(tags$td("GDP:"), tags$td(paste0("$", format(round(s1$GDP, 2), big.mark = ","), "M"))),
        tags$tr(tags$td("Personal Income:"), tags$td(paste0("$", format(round(s1$Personal_Income, 2), big.mark = ","), "M"))),
        tags$tr(tags$td("Disposable Income:"), tags$td(paste0("$", format(round(s1$Disposable_Income, 2), big.mark = ","), "M")))
      )
    ),
    column(
      6,
      h4(s2$State),
      tags$table(
        class = "table table-sm",
        tags$tr(tags$td("GDP:"), tags$td(paste0("$", format(round(s2$GDP, 2), big.mark = ","), "M"))),
        tags$tr(tags$td("Personal Income:"), tags$td(paste0("$", format(round(s2$Personal_Income, 2), big.mark = ","), "M"))),
        tags$tr(tags$td("Disposable Income:"), tags$td(paste0("$", format(round(s2$Disposable_Income, 2), big.mark = ","), "M")))
      )
    )
  )
})
