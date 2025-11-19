# ============================================================================
# Regional Trends - Server Logic
# ============================================================================

regional_trends_server <- function(input, output, session, macro_data, shared_state) {
  
  # Reactive regional data - Auto-updates on input change
  regional_data_reactive <- reactive({
    req(input$reg_indicator, input$reg_year_range)
    
    indicator <- input$reg_indicator
    years <- input$reg_year_range
    
    # Calculate regional averages (weighted by population)
    macro_data %>%
      filter(year >= years[1], year <= years[2], !is.na(.data[[indicator]]), !is.na(population)) %>%
      group_by(region, year) %>%
      summarise(
        value = weighted.mean(.data[[indicator]], w = population, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(region, year) # Sort for clean plotting
  })
  
  output$regional_plot <- renderPlotly({
    data <- regional_data_reactive()
    indicator <- input$reg_indicator
    
    validate(
      need(nrow(data) > 0, "No data available for selected parameters.")
    )
    
    indicator_label <- tools::toTitleCase(gsub("_", " ", indicator))
    
    # Modern Financial Palette
    prof_palette <- c("#0F172A", "#3B82F6", "#10B981", "#F59E0B", "#8B5CF6", "#EF4444", "#06B6D4", "#EC4899")
    
    # Dynamic Palette Logic
    n_colors <- length(unique(data$region))
    final_palette <- if(n_colors <= length(prof_palette)) prof_palette[1:n_colors] else colorRampPalette(prof_palette)(n_colors)
    
    p <- ggplot(data, aes(x = year, y = value, color = region)) +
      geom_line(linewidth = 1.5) +
      geom_point(size = 2) +
      scale_color_manual(values = final_palette) +
      labs(
        title = paste("Regional Trends:", indicator_label),
        x = "Year",
        y = paste("Avg", indicator_label),
        color = "Region"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 16, color = "#1e293b"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "#e2e8f0"),
        axis.text = element_text(color = "#64748b"),
        axis.title = element_text(color = "#475569")
      )
    
    ggplotly(p) %>% layout(legend = list(orientation = "h", y = -0.2))
  })
}
