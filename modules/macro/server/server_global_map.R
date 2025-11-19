# ============================================================================
# Global Map - Server Logic
# ============================================================================

global_map_server <- function(input, output, session, macro_data, shared_state) {
  
  # Animation state
  is_playing <- reactiveVal(FALSE)
  
  # Get year range from data
  year_range <- reactive({
    req(macro_data)
    years <- sort(unique(macro_data$year))
    list(min = min(years, na.rm = TRUE), max = max(years, na.rm = TRUE), all = years)
  })
  
  # Play/Pause button handler
  observeEvent(input$map_play_pause, {
    if (is_playing()) {
      # Pause animation
      is_playing(FALSE)
      updateActionButton(session, "map_play_pause", label = "Play", icon = shiny::icon("play"))
    } else {
      # Start animation
      is_playing(TRUE)
      updateActionButton(session, "map_play_pause", label = "Pause", icon = shiny::icon("pause"))
    }
  })
  
  # Animation timer - updates every 500ms
  auto_invalidate <- reactiveTimer(500, session)
  
  # Animation logic - triggered by timer when playing
  observe({
    # Trigger timer (this makes the observe block re-run every 500ms)
    auto_invalidate()
    
    # Only proceed if playing
    if (!is_playing()) return()
    
    years <- year_range()$all
    current_year <- input$map_year
    current_idx <- which(years == current_year)
    
    if (length(current_idx) == 0) {
      current_idx <- 1
    }
    
    # Move to next year
    if (current_idx < length(years)) {
      next_year <- years[current_idx + 1]
      updateSliderInput(session, "map_year", value = next_year)
    } else {
      # Reached the end, stop animation
      is_playing(FALSE)
      updateActionButton(session, "map_play_pause", label = "Play", icon = shiny::icon("play"))
    }
  })
  
  # Reset to first year when indicator changes
  observeEvent(input$map_indicator, {
    if (is_playing()) {
      is_playing(FALSE)
      updateActionButton(session, "map_play_pause", label = "Play", icon = shiny::icon("play"))
    }
    years <- year_range()$all
    if (length(years) > 0) {
      updateSliderInput(session, "map_year", value = years[1])
    }
  })
  
  # Animation status text
  output$map_animation_status <- renderText({
    if (is_playing()) {
      years <- year_range()$all
      current_idx <- which(years == input$map_year)
      total <- length(years)
      paste("Playing:", current_idx, "of", total, "years")
    } else {
      ""
    }
  })
  
  # Reactive map data - Auto-updates on input change
  map_data_reactive <- reactive({
    req(input$map_year, input$map_indicator)
    
    macro_data %>%
      filter(year == input$map_year, !is.na(.data[[input$map_indicator]]))
  })
  
  output$map_plot <- renderPlotly({
    map_data <- map_data_reactive()
    indicator <- input$map_indicator
    
    validate(
      need(nrow(map_data) > 0, paste("No data available for", indicator, "in", input$map_year))
    )
    
    indicator_label <- tools::toTitleCase(gsub("_", " ", indicator))
    
    # CRITICAL FIX: Dynamic color scale based on actual data range
    # This prevents the "all grey" issue when max is too high
    data_values <- map_data[[indicator]]
    data_min <- min(data_values, na.rm = TRUE)
    data_max <- max(data_values, na.rm = TRUE)
    
    # For GDP per capita, use a more reasonable scale (e.g., 95th percentile as max)
    # This ensures most countries are visible, not just the outliers
    if (indicator == "gdp_per_capita") {
      # Use 95th percentile as max to avoid extreme outliers dominating the scale
      scale_max <- quantile(data_values, 0.95, na.rm = TRUE)
      scale_min <- data_min
    } else {
      # For other indicators, use full range
      scale_max <- data_max
      scale_min <- data_min
    }
    
    # Modern Light Theme Map with Dynamic Scale
    plot_geo(map_data) %>%
      add_trace(
        z = ~get(indicator),
        color = ~get(indicator),
        colors = "Blues", # Professional Blue Scale
        text = ~paste(country, "<br>", indicator_label, ":", round(get(indicator), 2)),
        locations = ~iso3c,
        marker = list(line = list(color = 'rgb(255,255,255)', width = 0.5)), # White borders
        zmin = scale_min,
        zmax = scale_max  # Dynamic max based on data
      ) %>%
      colorbar(title = indicator_label, len = 0.9) %>%
      layout(
        title = list(text = paste("Global", indicator_label, "-", input$map_year), font = list(color = "#1e293b", size = 18)),
        font = list(family = "Inter"),
        geo = list(
          showframe = FALSE,
          showcoastlines = TRUE,
          coastlinecolor = "#e2e8f0",
          projection = list(type = 'natural earth'),
          bgcolor = "rgba(0,0,0,0)", # Transparent background
          lakecolor = "#f1f5f9",     # Match page background
          landcolor = "#f8fafc",
          countrycolor = "#e2e8f0"
        ),
        margin = list(t = 50, b = 0, l = 0, r = 0)
      )
  })
}
