# ============================================================================
# Relationships - Server Logic
# ============================================================================

relationships_server <- function(input, output, session, macro_data, shared_state) {
  
  # Initialize country selector
  observe({
    countries <- unique(macro_data$country) %>% sort()
    updateSelectizeInput(session, "rel_country", choices = countries, selected = "United States", server = TRUE)
  })
  
  # Reactive data - Auto-updates on input change
  rel_data <- reactive({
    req(input$rel_country, input$rel_y1, input$rel_y2)
    
    macro_data %>%
      filter(country == input$rel_country) %>%
      arrange(year) %>%
      select(year, country, val1 = .data[[input$rel_y1]], val2 = .data[[input$rel_y2]])
  })
  
  output$rel_plot <- renderPlotly({
    data <- rel_data()
    
    validate(
      need(nrow(data) > 0, "No data available for selected country and indicators.")
    )
    
    # Indicator labels
    label1 <- tools::toTitleCase(gsub("_", " ", input$rel_y1))
    label2 <- tools::toTitleCase(gsub("_", " ", input$rel_y2))
    
    # Create Dual-Axis Plot
    p <- plot_ly(data, x = ~year)
    
    # Line 1 (Left Axis) - Royal Blue
    p <- p %>% add_lines(
      y = ~val1, 
      name = label1,
      line = list(color = "#2563eb", width = 3)
    )
    
    # Line 2 (Right Axis) - Emerald Green or Amber
    p <- p %>% add_lines(
      y = ~val2, 
      name = label2, 
      yaxis = "y2",
      line = list(color = "#f59e0b", width = 3, dash = "dot")
    )
    
    # Layout
    p <- p %>% layout(
      title = list(
        text = paste(input$rel_country, ":", label1, "vs", label2),
        font = list(color = "#1e293b", size = 18)
      ),
      paper_bgcolor = "rgba(0,0,0,0)", # Transparent to match card
      plot_bgcolor = "rgba(0,0,0,0)",
      legend = list(orientation = "h", x = 0.1, y = -0.15),
      
      # Left Y-Axis
      yaxis = list(
        title = label1,
        titlefont = list(color = "#2563eb"),
        tickfont = list(color = "#2563eb"),
        showgrid = TRUE,
        gridcolor = "#e2e8f0"
      ),
      
      # Right Y-Axis
      yaxis2 = list(
        overlaying = "y",
        side = "right",
        title = label2,
        titlefont = list(color = "#f59e0b"),
        tickfont = list(color = "#f59e0b"),
        showgrid = FALSE
      ),
      
      xaxis = list(
        title = "Year",
        showgrid = FALSE
      ),
      
      margin = list(r = 50) # Right margin for second axis
    )
    
    p
  })
}
