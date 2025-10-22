# cfhi_feature_server.R
# Server module for Consumer Financial Health Index (CFHI)

cfhi_feature_server <- function(id,
                                master_path = "cfhi_data/cfhi_master_2000_onward.csv",
                                title_prefix = "Consumer Financial Health Index (CFHI)") {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ---- Helpers ----
    scale01 <- function(x) {
      rng <- range(x, na.rm = TRUE)
      if (!is.finite(rng[1]) || !is.finite(rng[2])) return(rep(NA_real_, length(x)))
      if (diff(rng) == 0) return(rep(0.5, length(x)))
      (x - rng[1]) / (rng[2] - rng[1])
    }
    
    # Load master CSV once
    df_master <- reactive({
      validate(need(file.exists(master_path),
                    paste0("File not found: ", master_path)))
      df <- readr::read_csv(master_path, show_col_types = FALSE)
      names(df) <- tolower(names(df))
      if (!inherits(df$date, "Date")) df$date <- as.Date(df$date)
      # Expect these columns from your pipeline; recompute components if missing
      need <- c("date","savings_rate","wage_yoy","inflation_yoy","borrow_rate")
      missing <- setdiff(need, names(df))
      validate(need(length(missing) == 0,
                    paste("Master CSV missing columns:", paste(missing, collapse=", "))))
      df <- df[order(df$date), ]
      # if CFHI not present, build it minimally:
      if (!"cfhi" %in% names(df)) {
        df$S_star <- 100 * scale01(df$savings_rate)
        df$W_star <- 100 * scale01(df$wage_yoy)
        df$I_star <- 100 - 100 * scale01(df$inflation_yoy)
        df$R_star <- 100 - 100 * scale01(df$borrow_rate)
        df$CFHI_raw <- rowMeans(df[, c("S_star","W_star","I_star","R_star")], na.rm = TRUE)
        df$CFHI <- zoo::rollapply(df$CFHI_raw, 3, mean, align = "right", fill = NA)
      }
      # Provide year/month
      df$year <- lubridate::year(df$date)
      df$month <- lubridate::month(df$date)
      df
    })
    
    # Build date range input after data loads
    output$date_range_ui <- renderUI({
      df <- df_master()
      req(nrow(df) > 0)
      min_d <- min(df$date, na.rm = TRUE)
      max_d <- max(df$date, na.rm = TRUE)
      # default: start from earliest available data
      default_start <- min_d
      dateRangeInput(ns("date_range"),
                     "Time window",
                     start = default_start, end = max_d,
                     min = min_d, max = max_d)
    })
    
    # Compute CFHI for chosen window and smoothing
    df_filtered <- reactive({
      df <- df_master()
      req(input$date_range)
      rng <- as.Date(input$date_range)
      df <- df[df$date >= rng[1] & df$date <= rng[2], , drop = FALSE]
      # recompute smoothing based on user input for fairness
      k <- req(input$smooth_k)
      if ("cfhi_raw" %in% names(df)) {
        cfhi_raw <- df$cfhi_raw
      } else {
        # derive if necessary
        s <- 100 * scale01(df$savings_rate)
        w <- 100 * scale01(df$wage_yoy)
        i <- 100 - 100 * scale01(df$inflation_yoy)
        r <- 100 - 100 * scale01(df$borrow_rate)
        cfhi_raw <- rowMeans(cbind(s, w, i, r), na.rm = TRUE)
        df$S_star <- s; df$W_star <- w; df$I_star <- i; df$R_star <- r
      }
      cfhi <- if (k > 1) zoo::rollapply(cfhi_raw, k, mean, align = "right", fill = NA) else cfhi_raw
      df$CFHI_raw <- cfhi_raw
      df$CFHI <- cfhi
      df
    })
    
    # Current CHFI card
    observe({
      df <- df_master()
      req(nrow(df) > 0)
      last_row <- df[tail(which(!is.na(df$CFHI)), 1), ]
      if (nrow(last_row)) {
        lbl <- sprintf("%.1f", last_row$CFHI)
        sub <- paste0("Latest month: ", format(last_row$date, "%b %Y"))
        shinyjs::runjs(sprintf("document.getElementById('%s').innerText = '%s';", ns("current_label"), lbl))
        shinyjs::runjs(sprintf("document.getElementById('%s').innerText = '%s';", ns("current_sub"), sub))
      }
    })
    
    # Plot
    output$cfhi_plot <- renderPlotly({
      df <- df_filtered()
      req(nrow(df) > 0)
      
      show_components <- identical(input$show_series, "cfhi_plus")
      
      # Build the plot - main CFHI line
      fig <- plot_ly(df, x = ~date, y = ~CFHI, type = 'scatter', mode = 'lines+markers',
                     name = 'CFHI (Composite)',
                     line = list(color = '#1e40af', width = 3),
                     marker = list(size = 4, color = '#1e40af'),
                     hovertemplate = paste0(
                       "<b>%{x|%b %Y}</b><br>",
                       "CFHI: %{y:.2f}<br>",
                       "<extra></extra>"
                     ))
      
      # Add component lines if selected with distinct colors
      if (show_components) {
        if (!all(c("S_star","W_star","I_star","R_star") %in% names(df))) {
          s <- 100 * scale01(df$savings_rate)
          w <- 100 * scale01(df$wage_yoy)
          i <- 100 - 100 * scale01(df$inflation_yoy)
          r <- 100 - 100 * scale01(df$borrow_rate)
          df$S_star <- s; df$W_star <- w; df$I_star <- i; df$R_star <- r
        }
        
        fig <- fig %>%
          add_trace(x = ~date, y = ~S_star, data = df, type = 'scatter', mode = 'lines',
                   name = 'Savings Rate ↑',
                   line = list(color = '#16a34a', dash = 'dash', width = 2),
                   hovertemplate = paste0(
                     "<b>Savings Rate</b><br>",
                     "%{x|%b %Y}<br>",
                     "Value: %{y:.2f}<br>",
                     "<extra></extra>"
                   )) %>%
          add_trace(x = ~date, y = ~W_star, data = df, type = 'scatter', mode = 'lines',
                   name = 'Wage Growth ↑',
                   line = list(color = '#0891b2', dash = 'dash', width = 2),
                   hovertemplate = paste0(
                     "<b>Wage Growth</b><br>",
                     "%{x|%b %Y}<br>",
                     "Value: %{y:.2f}<br>",
                     "<extra></extra>"
                   )) %>%
          add_trace(x = ~date, y = ~I_star, data = df, type = 'scatter', mode = 'lines',
                   name = 'Inflation ↓ (inverted)',
                   line = list(color = '#ea580c', dash = 'dash', width = 2),
                   hovertemplate = paste0(
                     "<b>Inflation (inverted)</b><br>",
                     "%{x|%b %Y}<br>",
                     "Value: %{y:.2f}<br>",
                     "<extra></extra>"
                   )) %>%
          add_trace(x = ~date, y = ~R_star, data = df, type = 'scatter', mode = 'lines',
                   name = 'Borrow Rate ↓ (inverted)',
                   line = list(color = '#c026d3', dash = 'dash', width = 2),
                   hovertemplate = paste0(
                     "<b>Borrow Rate (inverted)</b><br>",
                     "%{x|%b %Y}<br>",
                     "Value: %{y:.2f}<br>",
                     "<extra></extra>"
                   ))
      }
      
      # Layout
      fig <- fig %>% layout(
        title = list(text = paste0(title_prefix, "<br><sub>", 
                                   format(min(df$date), "%b %Y"), " — ", 
                                   format(max(df$date), "%b %Y"), "</sub>")),
        xaxis = list(title = "", showgrid = TRUE, gridcolor = '#e5e7eb'),
        yaxis = list(title = "Index (Jan 2000 = 100)", showgrid = TRUE, gridcolor = '#e5e7eb'),
        hovermode = 'x unified',
        legend = list(
          orientation = "h", 
          yanchor = "bottom", 
          y = -0.25, 
          xanchor = "center", 
          x = 0.5,
          bgcolor = 'rgba(255, 255, 255, 0.9)',
          bordercolor = '#e5e7eb',
          borderwidth = 1
        ),
        plot_bgcolor = '#ffffff',
        paper_bgcolor = '#ffffff'
      )
      
      fig
    })
  })
}

