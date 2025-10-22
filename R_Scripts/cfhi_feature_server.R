# cfhi_feature_server.R
# Server module for Consumer Financial Health Index (CFHI)

cfhi_feature_server <- function(id,
                                master_path = "cfhi_data/cfhi_master_2000_onward.csv",
                                title_prefix = "Consumer Financial Health Index (CFHI)") {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Load plotly if not already loaded
    if (!requireNamespace("plotly", quietly = TRUE)) {
      install.packages("plotly")
    }
    library(plotly)
    
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
      # default: last 5 years
      default_start <- max(min_d, max_d %m-% months(60))
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
    
    # Current CHFI card with trend indicator
    observe({
      df <- df_master()
      req(nrow(df) > 0)
      last_row <- df[tail(which(!is.na(df$CFHI)), 1), ]
      if (nrow(last_row)) {
        lbl <- sprintf("%.1f", last_row$CFHI)
        sub <- paste0("Latest month: ", format(last_row$date, "%b %Y"))
        
        # Calculate trend (compare to 3 months ago)
        idx <- which(!is.na(df$CFHI))
        if (length(idx) >= 4) {
          prev_val <- df$CFHI[idx[length(idx) - 3]]
          curr_val <- last_row$CFHI
          trend <- curr_val - prev_val
          trend_icon <- if (trend > 0) "↑" else if (trend < 0) "↓" else "→"
          trend_color <- if (trend > 0) "#10b981" else if (trend < 0) "#ef4444" else "#6b7280"
          sub <- paste0(sub, " ", trend_icon, " ", sprintf("%.1f", abs(trend)))
        }
        
        shinyjs::runjs(sprintf("document.getElementById('%s').innerText = '%s';", ns("current_label"), lbl))
        shinyjs::runjs(sprintf("document.getElementById('%s').innerText = '%s';", ns("current_sub"), sub))
      }
    })
    
    # Summary statistics
    output$summary_stats <- renderUI({
      df <- df_filtered()
      req(nrow(df) > 0)
      
      cfhi_vals <- df$CFHI[!is.na(df$CFHI)]
      if (length(cfhi_vals) == 0) return(NULL)
      
      avg_cfhi <- mean(cfhi_vals, na.rm = TRUE)
      min_cfhi <- min(cfhi_vals, na.rm = TRUE)
      max_cfhi <- max(cfhi_vals, na.rm = TRUE)
      
      tagList(
        tags$div(
          style = "display: flex; gap: 12px; justify-content: space-around; margin-top: 12px;",
          tags$div(
            style = "text-align: center;",
            tags$div(style = "font-size: 11px; color: #64748b; text-transform: uppercase;", "Average"),
            tags$div(style = "font-size: 18px; font-weight: 600; color: #0f172a;", sprintf("%.1f", avg_cfhi))
          ),
          tags$div(
            style = "text-align: center;",
            tags$div(style = "font-size: 11px; color: #64748b; text-transform: uppercase;", "Min"),
            tags$div(style = "font-size: 18px; font-weight: 600; color: #ef4444;", sprintf("%.1f", min_cfhi))
          ),
          tags$div(
            style = "text-align: center;",
            tags$div(style = "font-size: 11px; color: #64748b; text-transform: uppercase;", "Max"),
            tags$div(style = "font-size: 18px; font-weight: 600; color: #10b981;", sprintf("%.1f", max_cfhi))
          )
        )
      )
    })
    
    # Interactive Plotly visualization
    output$cfhi_plot <- renderPlotly({
      df <- df_filtered()
      req(nrow(df) > 0)
      
      show_components <- identical(input$show_series, "cfhi_plus")
      
      # Create main CFHI trace with gradient coloring
      cfhi_color <- ifelse(df$CFHI >= 90, "#10b981",
                    ifelse(df$CFHI >= 70, "#84cc16",
                    ifelse(df$CFHI >= 50, "#eab308",
                    ifelse(df$CFHI >= 30, "#f97316", "#ef4444"))))
      
      # Build hover text
      hover_text <- paste0(
        "<b>", format(df$date, "%B %Y"), "</b><br>",
        "CFHI: <b>", sprintf("%.2f", df$CFHI), "</b><br>",
        "<extra></extra>"
      )
      
      # Create the main plot
      fig <- plot_ly(df, x = ~date, y = ~CFHI, type = 'scatter', mode = 'lines+markers',
                     name = 'CFHI',
                     line = list(color = '#3b82f6', width = 3, shape = 'spline'),
                     marker = list(
                       size = 8,
                       color = cfhi_color,
                       line = list(color = '#ffffff', width = 2)
                     ),
                     hovertemplate = hover_text,
                     showlegend = TRUE)
      
      # Add health zones as background shapes
      fig <- fig %>% add_trace(
        x = df$date, y = rep(90, nrow(df)),
        type = 'scatter', mode = 'none',
        fill = 'tonexty', fillcolor = 'rgba(16, 185, 129, 0.1)',
        name = 'Excellent (90-100)',
        showlegend = TRUE,
        hoverinfo = 'skip'
      )
      
      fig <- fig %>% add_trace(
        x = df$date, y = rep(70, nrow(df)),
        type = 'scatter', mode = 'none',
        fill = 'tonexty', fillcolor = 'rgba(132, 204, 22, 0.1)',
        name = 'Good (70-90)',
        showlegend = TRUE,
        hoverinfo = 'skip'
      )
      
      fig <- fig %>% add_trace(
        x = df$date, y = rep(50, nrow(df)),
        type = 'scatter', mode = 'none',
        fill = 'tonexty', fillcolor = 'rgba(234, 179, 8, 0.1)',
        name = 'Fair (50-70)',
        showlegend = TRUE,
        hoverinfo = 'skip'
      )
      
      fig <- fig %>% add_trace(
        x = df$date, y = rep(30, nrow(df)),
        type = 'scatter', mode = 'none',
        fill = 'tonexty', fillcolor = 'rgba(249, 115, 22, 0.1)',
        name = 'Poor (30-50)',
        showlegend = TRUE,
        hoverinfo = 'skip'
      )
      
      fig <- fig %>% add_trace(
        x = df$date, y = rep(0, nrow(df)),
        type = 'scatter', mode = 'none',
        fill = 'tonexty', fillcolor = 'rgba(239, 68, 68, 0.1)',
        name = 'Critical (0-30)',
        showlegend = TRUE,
        hoverinfo = 'skip'
      )
      
      # Add component lines if selected
      if (show_components) {
        if (!all(c("S_star","W_star","I_star","R_star") %in% names(df))) {
          s <- 100 * scale01(df$savings_rate)
          w <- 100 * scale01(df$wage_yoy)
          i <- 100 - 100 * scale01(df$inflation_yoy)
          r <- 100 - 100 * scale01(df$borrow_rate)
          df$S_star <- s; df$W_star <- w; df$I_star <- i; df$R_star <- r
        }
        
        fig <- fig %>% add_trace(
          x = ~date, y = ~S_star, data = df,
          type = 'scatter', mode = 'lines',
          name = 'Savings Rate',
          line = list(color = '#8b5cf6', width = 2, dash = 'dash'),
          hovertemplate = paste0("<b>Savings Rate</b><br>",
                                 "%{x|%B %Y}<br>",
                                 "Value: %{y:.2f}<br>",
                                 "<extra></extra>")
        )
        
        fig <- fig %>% add_trace(
          x = ~date, y = ~W_star, data = df,
          type = 'scatter', mode = 'lines',
          name = 'Wage Growth',
          line = list(color = '#06b6d4', width = 2, dash = 'dash'),
          hovertemplate = paste0("<b>Wage Growth</b><br>",
                                 "%{x|%B %Y}<br>",
                                 "Value: %{y:.2f}<br>",
                                 "<extra></extra>")
        )
        
        fig <- fig %>% add_trace(
          x = ~date, y = ~I_star, data = df,
          type = 'scatter', mode = 'lines',
          name = 'Inflation (inverted)',
          line = list(color = '#f59e0b', width = 2, dash = 'dash'),
          hovertemplate = paste0("<b>Inflation (inverted)</b><br>",
                                 "%{x|%B %Y}<br>",
                                 "Value: %{y:.2f}<br>",
                                 "<extra></extra>")
        )
        
        fig <- fig %>% add_trace(
          x = ~date, y = ~R_star, data = df,
          type = 'scatter', mode = 'lines',
          name = 'Borrowing Rate (inverted)',
          line = list(color = '#ec4899', width = 2, dash = 'dash'),
          hovertemplate = paste0("<b>Borrowing Rate (inverted)</b><br>",
                                 "%{x|%B %Y}<br>",
                                 "Value: %{y:.2f}<br>",
                                 "<extra></extra>")
        )
      }
      
      # Layout configuration
      fig <- fig %>% layout(
        title = list(
          text = paste0("<b>", title_prefix, "</b><br>",
                       "<sub>", format(min(df$date), "%B %Y"), " — ", 
                       format(max(df$date), "%B %Y"), "</sub>"),
          font = list(size = 20, family = "Arial, sans-serif")
        ),
        xaxis = list(
          title = "",
          showgrid = TRUE,
          gridcolor = '#e5e7eb',
          zeroline = FALSE
        ),
        yaxis = list(
          title = "Index (Jan 2000 = 100)",
          showgrid = TRUE,
          gridcolor = '#e5e7eb',
          zeroline = TRUE,
          range = c(0, 105)
        ),
        hovermode = 'x unified',
        plot_bgcolor = '#ffffff',
        paper_bgcolor = '#ffffff',
        font = list(family = "Arial, sans-serif", size = 12, color = '#1f2937'),
        legend = list(
          orientation = "h",
          yanchor = "bottom",
          y = -0.3,
          xanchor = "center",
          x = 0.5,
          bgcolor = 'rgba(255, 255, 255, 0.8)',
          bordercolor = '#e5e7eb',
          borderwidth = 1
        ),
        margin = list(t = 80, b = 120, l = 60, r = 40)
      )
      
      # Add range selector and slider
      fig <- fig %>% layout(
        xaxis = list(
          rangeselector = list(
            buttons = list(
              list(count = 6, label = "6m", step = "month", stepmode = "backward"),
              list(count = 1, label = "1y", step = "year", stepmode = "backward"),
              list(count = 3, label = "3y", step = "year", stepmode = "backward"),
              list(count = 5, label = "5y", step = "year", stepmode = "backward"),
              list(step = "all", label = "All")
            ),
            bgcolor = '#f3f4f6',
            activecolor = '#3b82f6',
            x = 0,
            y = 1.15
          ),
          rangeslider = list(visible = TRUE, thickness = 0.05)
        )
      )
      
      fig
    })
  })
}
