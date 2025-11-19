# ============================================================================
# Correlations - Server Logic
# ============================================================================

correlations_server <- function(input, output, session, macro_data, shared_state) {
  
  # Initialize country selector
  observe({
    countries <- unique(macro_data$country) %>% sort()
    updateSelectizeInput(session, "corr_countries", choices = countries, server = TRUE)
  })
  
  # Reactive Correlation Matrix - Auto-updates on input change
  corr_data <- reactive({
    req(input$corr_year_range)
    
    # Filter data by year
    data <- macro_data %>%
      filter(year >= input$corr_year_range[1], year <= input$corr_year_range[2])
    
    # Filter by country if selected
    if (!is.null(input$corr_countries) && length(input$corr_countries) > 0) {
      data <- data %>% filter(country %in% input$corr_countries)
    }
    
    # Select numeric indicators
    numeric_cols <- c("gdp_per_capita", "inflation", "unemployment", "life_expectancy", "pop_growth")
    
    # Use pairwise complete observations to handle NAs robustly
    # This calculates correlations based on available matching pairs for each variable set
    cor_matrix <- cor(data[, numeric_cols], use = "pairwise.complete.obs")
    
    # Rename columns for display
    colnames(cor_matrix) <- c("GDP/Cap", "Inflation", "Unemployment", "Life Exp", "Pop Growth")
    rownames(cor_matrix) <- colnames(cor_matrix)
    
    cor_matrix
  })
  
  output$corr_plot <- renderPlot({
    M <- corr_data()
    
    validate(
      need(!any(is.na(M)), "Insufficient data to calculate correlations for this selection. Try selecting a longer year range or more countries.")
    )
    
    # Professional Color Palette for Correlations
    # Diverging: Red (Neg) - White - Blue (Pos)
    col <- colorRampPalette(c("#EF4444", "#FFFFFF", "#3B82F6"))(200)
    
    corrplot(M, 
             method = "color", 
             type = "upper", 
             order = "hclust", 
             col = col,
             addCoef.col = "#0F172A", # Dark Slate for text
             tl.col = "#0F172A",      # Dark Slate for labels
             tl.srt = 45,             # Rotated labels
             diag = FALSE,            # Hide diagonal
             outline = TRUE,
             mar = c(0,0,1,0)
    )
  })
}
