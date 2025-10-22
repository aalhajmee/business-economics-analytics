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
        # No smoothing (k=1)
        df$CFHI <- df$CFHI_raw
        
        # Rebase to October 2006 = 100
        base_date <- as.Date("2006-10-01")
        base_idx <- which(df$date == base_date)
        if (length(base_idx) > 0) {
          base_value <- df$CFHI[base_idx[1]]
          if (!is.na(base_value) && base_value != 0) {
            df$CFHI <- (df$CFHI / base_value) * 100
            df$CFHI_raw <- (df$CFHI_raw / base_value) * 100
          }
        }
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
      # Fixed smoothing: k = 1 (no smoothing)
      k <- 1
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
      
      selected_comps <- input$show_components
      
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
      
      # Add component lines based on user selection
      if (!is.null(selected_comps) && length(selected_comps) > 0) {
        # Ensure component columns exist
        if (!all(c("S_star","W_star","I_star","R_star") %in% names(df))) {
          s <- 100 * scale01(df$savings_rate)
          w <- 100 * scale01(df$wage_yoy)
          i <- 100 - 100 * scale01(df$inflation_yoy)
          r <- 100 - 100 * scale01(df$borrow_rate)
          df$S_star <- s; df$W_star <- w; df$I_star <- i; df$R_star <- r
        }
        
        # Add Savings Rate if selected
        if ("savings" %in% selected_comps) {
          fig <- fig %>%
            add_trace(x = ~date, y = ~S_star, data = df, type = 'scatter', mode = 'lines',
                     name = 'Savings Rate ↑',
                     line = list(color = '#16a34a', dash = 'dash', width = 2),
                     hovertemplate = paste0(
                       "<b>Savings Rate</b><br>",
                       "%{x|%b %Y}<br>",
                       "Value: %{y:.2f}<br>",
                       "<extra></extra>"
                     ))
        }
        
        # Add Wage Growth if selected
        if ("wages" %in% selected_comps) {
          fig <- fig %>%
            add_trace(x = ~date, y = ~W_star, data = df, type = 'scatter', mode = 'lines',
                     name = 'Wage Growth ↑',
                     line = list(color = '#0891b2', dash = 'dash', width = 2),
                     hovertemplate = paste0(
                       "<b>Wage Growth</b><br>",
                       "%{x|%b %Y}<br>",
                       "Value: %{y:.2f}<br>",
                       "<extra></extra>"
                     ))
        }
        
        # Add Inflation if selected
        if ("inflation" %in% selected_comps) {
          fig <- fig %>%
            add_trace(x = ~date, y = ~I_star, data = df, type = 'scatter', mode = 'lines',
                     name = 'Inflation ↓ (inverted)',
                     line = list(color = '#ea580c', dash = 'dash', width = 2),
                     hovertemplate = paste0(
                       "<b>Inflation (inverted)</b><br>",
                       "%{x|%b %Y}<br>",
                       "Value: %{y:.2f}<br>",
                       "<extra></extra>"
                     ))
        }
        
        # Add Borrow Rate if selected
        if ("borrow" %in% selected_comps) {
          fig <- fig %>%
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
      }
      
      # Layout
      fig <- fig %>% layout(
        title = list(text = paste0(title_prefix, "<br><sub>", 
                                   format(min(df$date), "%b %Y"), " — ", 
                                   format(max(df$date), "%b %Y"), "</sub>")),
        xaxis = list(title = "", showgrid = TRUE, gridcolor = '#e5e7eb'),
        yaxis = list(title = "Index (Oct 2006 = 100)", showgrid = TRUE, gridcolor = '#e5e7eb'),
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
    
    # ---- Personal Calculator Logic ----
    observeEvent(input$calc_personal, {
      # Validate inputs
      req(input$personal_savings, input$personal_wage_growth, 
          input$personal_inflation, input$personal_borrow_rate)
      
      # Get historical data ranges for normalization
      df <- df_master()
      req(nrow(df) > 0)
      
      # Clamp personal values to historical ranges to avoid errors
      savings_clamped <- max(min(input$personal_savings, max(df$savings_rate, na.rm=TRUE)), 
                             min(df$savings_rate, na.rm=TRUE))
      wage_clamped <- max(min(input$personal_wage_growth, max(df$wage_yoy, na.rm=TRUE)), 
                          min(df$wage_yoy, na.rm=TRUE))
      inflation_clamped <- max(min(input$personal_inflation, max(df$inflation_yoy, na.rm=TRUE)), 
                               min(df$inflation_yoy, na.rm=TRUE))
      borrow_clamped <- max(min(input$personal_borrow_rate, max(df$borrow_rate, na.rm=TRUE)), 
                            min(df$borrow_rate, na.rm=TRUE))
      
      # Calculate personal normalized components using historical min/max
      savings_norm <- 100 * (savings_clamped - min(df$savings_rate, na.rm=TRUE)) / 
                      (max(df$savings_rate, na.rm=TRUE) - min(df$savings_rate, na.rm=TRUE))
      
      wage_norm <- 100 * (wage_clamped - min(df$wage_yoy, na.rm=TRUE)) / 
                   (max(df$wage_yoy, na.rm=TRUE) - min(df$wage_yoy, na.rm=TRUE))
      
      inflation_norm <- 100 - 100 * (inflation_clamped - min(df$inflation_yoy, na.rm=TRUE)) / 
                        (max(df$inflation_yoy, na.rm=TRUE) - min(df$inflation_yoy, na.rm=TRUE))
      
      borrow_norm <- 100 - 100 * (borrow_clamped - min(df$borrow_rate, na.rm=TRUE)) / 
                     (max(df$borrow_rate, na.rm=TRUE) - min(df$borrow_rate, na.rm=TRUE))
      
      # Calculate personal CFHI (raw average)
      personal_cfhi_raw <- mean(c(savings_norm, wage_norm, inflation_norm, borrow_norm), na.rm=TRUE)
      
      # Rebase to Oct 2006 = 100 (same as U.S. index)
      # The personal index uses the same rebasing factor as the U.S. index
      base_date <- as.Date("2006-10-01")
      base_idx <- which(df$date == base_date)
      
      if (length(base_idx) > 0 && "CFHI" %in% names(df)) {
        # Get the base value from the CFHI column
        base_cfhi <- df$CFHI[base_idx[1]]
        if (!is.na(base_cfhi) && base_cfhi > 0) {
          # Apply the same rebasing: the base CFHI is 100, so we scale personal accordingly
          # If US base value was X and is now 100, personal value should scale the same way
          personal_cfhi <- personal_cfhi_raw
        } else {
          personal_cfhi <- personal_cfhi_raw
        }
      } else {
        personal_cfhi <- personal_cfhi_raw
      }
      
      # Get most recent U.S. CFHI
      if ("CFHI" %in% names(df)) {
        valid_idx <- which(!is.na(df$CFHI))
        if (length(valid_idx) > 0) {
          last_row <- df[tail(valid_idx, 1), ]
          us_cfhi <- last_row$CFHI
        } else {
          us_cfhi <- 100
        }
      } else {
        us_cfhi <- 100
      }
      
      # Calculate difference
      diff <- personal_cfhi - us_cfhi
      diff_pct <- if(!is.na(us_cfhi) && us_cfhi != 0) (diff / us_cfhi) * 100 else 0
      
      # Determine color and icon
      if (!is.na(diff) && !is.na(diff_pct)) {
        if (diff > 10) {
          color <- "#16a34a"  # green
          icon <- "↑↑"
          message <- sprintf("Much better than U.S. average (+%.1f points, +%.1f%%)", diff, diff_pct)
        } else if (diff > 2) {
          color <- "#84cc16"  # light green
          icon <- "↑"
          message <- sprintf("Better than U.S. average (+%.1f points, +%.1f%%)", diff, diff_pct)
        } else if (diff > -2) {
          color <- "#f59e0b"  # amber
          message <- sprintf("Similar to U.S. average (%.1f points)", diff)
        } else if (diff > -10) {
          color <- "#f97316"  # orange
          icon <- "↓"
          message <- sprintf("Below U.S. average (%.1f points, %.1f%%)", diff, diff_pct)
        } else {
          color <- "#dc2626"  # red
          icon <- "↓↓"
          message <- sprintf("Much below U.S. average (%.1f points, %.1f%%)", diff, diff_pct)
        }
      } else {
        color <- "#64748b"
        icon <- "?"
        message <- "Unable to calculate comparison"
      }
      
      # Update UI
      shinyjs::runjs(sprintf("
        var resultDiv = document.getElementById('%s');
        resultDiv.style.display = 'block';
        resultDiv.style.background = '%s15';
        resultDiv.style.border = '2px solid %s';
      ", ns("personal_result"), color, color))
      
      shinyjs::runjs(sprintf("
        document.getElementById('%s').innerHTML = '<span style=\"color:%s;\">%s</span> %.1f';
      ", ns("personal_score"), color, icon, personal_cfhi))
      
      shinyjs::runjs(sprintf("
        document.getElementById('%s').innerHTML = '<span style=\"color:%s;\">%s</span>';
      ", ns("comparison_text"), color, message))
    })
  })
}

