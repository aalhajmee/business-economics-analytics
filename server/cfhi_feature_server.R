# cfhi_feature_server.R
# Server module for Consumer Financial Health Index (CFHI)

cfhi_feature_server <- function(id,
                                master_path = "data/cfhi/cfhi_master_2000_onward.csv",
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
      # if cfhi not present, build it minimally:
      if (!"cfhi" %in% names(df)) {
        df$s_star <- 100 * scale01(df$savings_rate)
        df$w_star <- 100 * scale01(df$wage_yoy)
        df$i_star <- 100 - 100 * scale01(df$inflation_yoy)
        df$r_star <- 100 - 100 * scale01(df$borrow_rate)
        df$cfhi_raw <- rowMeans(df[, c("s_star","w_star","i_star","r_star")], na.rm = TRUE)
        # No smoothing (k=1)
        df$cfhi <- df$cfhi_raw
        
        # Rebase to October 2006 = 100
        base_date <- as.Date("2006-10-01")
        base_idx <- which(df$date == base_date)
        if (length(base_idx) > 0) {
          base_value <- df$cfhi[base_idx[1]]
          if (!is.na(base_value) && base_value != 0) {
            df$cfhi <- (df$cfhi / base_value) * 100
            df$cfhi_raw <- (df$cfhi_raw / base_value) * 100
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
    
    # Compute CFHI for chosen window
    df_filtered <- reactive({
      df_full <- df_master()
      req(input$date_range)
      
      # CSV should already have normalized components (s_star, w_star, i_star, r_star)
      # and CFHI normalized to 0-100 (0=worst, 100=best historical financial health)
      # No need to recalculate since we're using the pre-processed CSV
      
      # Filter to selected date range for visualization
      rng <- as.Date(input$date_range)
      df <- df_full[df_full$date >= rng[1] & df_full$date <= rng[2], , drop = FALSE]
      df
    })
    
    # Current CFHI card
    observe({
      df <- df_master()
      req(nrow(df) > 0)
      last_row <- df[tail(which(!is.na(df$cfhi)), 1), ]
      if (nrow(last_row)) {
        lbl <- sprintf("%.1f", last_row$cfhi)
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
      fig <- plot_ly(df, x = ~date, y = ~cfhi, type = 'scatter', mode = 'lines+markers',
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
        # Components should already exist from df_filtered() which uses full dataset normalization
        # No need to recalculate here
        
        # Add Savings Rate if selected
        if ("savings" %in% selected_comps) {
          fig <- fig %>%
            add_trace(x = ~date, y = ~s_star, data = df, type = 'scatter', mode = 'lines',
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
            add_trace(x = ~date, y = ~w_star, data = df, type = 'scatter', mode = 'lines',
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
            add_trace(x = ~date, y = ~i_star, data = df, type = 'scatter', mode = 'lines',
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
            add_trace(x = ~date, y = ~r_star, data = df, type = 'scatter', mode = 'lines',
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
                                   format(min(df$date), "%b %Y"), " - ", 
                                   format(max(df$date), "%b %Y"), "</sub>")),
        xaxis = list(title = "", showgrid = TRUE, gridcolor = '#e5e7eb'),
        yaxis = list(title = "Index (0=Worst, 100=Best)", showgrid = TRUE, gridcolor = '#e5e7eb'),
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
      req(input$monthly_income, input$monthly_savings, input$income_growth)
      
      # Get historical data
      df <- df_master()
      req(nrow(df) > 0)
      
      # Get current year (2025) data for U.S. average comparison
      current_year <- 2025
      df_current_year <- df[lubridate::year(df$date) == current_year, ]
      
      if (nrow(df_current_year) > 0 && "cfhi" %in% names(df_current_year)) {
        us_cfhi_avg <- mean(df_current_year$cfhi, na.rm = TRUE)
      } else {
        # Fallback to most recent available data
        if ("cfhi" %in% names(df)) {
          valid_idx <- which(!is.na(df$cfhi))
          if (length(valid_idx) > 0) {
            last_row <- df[tail(valid_idx, 1), ]
            us_cfhi_avg <- last_row$cfhi
          } else {
            us_cfhi_avg <- 100
          }
        } else {
          us_cfhi_avg <- 100
        }
      }
      
      # Get most recent U.S. economic indicators for comparison
      if (nrow(df_current_year) > 0) {
        us_inflation <- mean(df_current_year$inflation_yoy, na.rm = TRUE)
      } else {
        last_idx <- tail(which(!is.na(df$inflation_yoy)), 1)
        us_inflation <- if(length(last_idx) > 0) df$inflation_yoy[last_idx] else 3
      }
      
      # Calculate personal metrics
      personal_savings_rate <- if(input$monthly_income > 0) {
        (input$monthly_savings / input$monthly_income) * 100
      } else { 0 }
      
      personal_wage_growth <- input$income_growth
      
      # Calculate effective borrowing rate based on debt
      # Only matters if you have debt
      personal_borrow_rate <- if(input$total_debt > 0 && !is.null(input$avg_interest_rate)) {
        input$avg_interest_rate
      } else {
        0  # No debt = optimal score
      }
      
      # Get normalization ranges from historical data
      savings_min <- min(df$savings_rate, na.rm=TRUE)
      savings_max <- max(df$savings_rate, na.rm=TRUE)
      wage_min <- min(df$wage_yoy, na.rm=TRUE)
      wage_max <- max(df$wage_yoy, na.rm=TRUE)
      inflation_min <- min(df$inflation_yoy, na.rm=TRUE)
      inflation_max <- max(df$inflation_yoy, na.rm=TRUE)
      borrow_min <- min(df$borrow_rate, na.rm=TRUE)
      borrow_max <- max(df$borrow_rate, na.rm=TRUE)
      
      # Normalize personal components (same method as U.S. index)
      personal_S <- if(savings_max != savings_min) {
        100 * (personal_savings_rate - savings_min) / (savings_max - savings_min)
      } else { 50 }
      
      personal_W <- if(wage_max != wage_min) {
        100 * (personal_wage_growth - wage_min) / (wage_max - wage_min)
      } else { 50 }
      
      personal_I <- if(inflation_max != inflation_min) {
        100 - 100 * (us_inflation - inflation_min) / (inflation_max - inflation_min)
      } else { 50 }
      
      personal_R <- if(borrow_max != borrow_min) {
        100 - 100 * (personal_borrow_rate - borrow_min) / (borrow_max - borrow_min)
      } else { 100 }  # No debt = maximum score
      
      # Clamp to 0-100
      personal_S <- max(0, min(100, personal_S))
      personal_W <- max(0, min(100, personal_W))
      personal_I <- max(0, min(100, personal_I))
      personal_R <- max(0, min(100, personal_R))
      
      # Calculate personal CFHI as average
      personal_cfhi_raw <- mean(c(personal_S, personal_W, personal_I, personal_R), na.rm=TRUE)
      
      # Personal index should be on 0-100 scale (no rebasing needed for personal calc)
      # Cap at 100 since index is defined as 0-100
      personal_cfhi <- max(0, min(100, personal_cfhi_raw))
      
      # Calculate difference from 2025 U.S. average
      diff <- personal_cfhi - us_cfhi_avg
      diff_pct <- if(!is.na(us_cfhi_avg) && us_cfhi_avg != 0) (diff / us_cfhi_avg) * 100 else 0
      
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
          icon <- "≈"
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
    
    # Download handlers (inside moduleServer)
    output$download_cfhi_data <- downloadHandler(
      filename = function() {
        paste0("CFHI_data_", format(Sys.Date(), "%Y%m%d"), ".csv")
      },
      content = function(file) {
        df <- df_filtered()
        export_df <- df %>%
          select(date, CFHI, S_star, W_star, I_star, R_star, 
                 savings_rate, wage_yoy, inflation_yoy, borrow_rate)
        write.csv(export_df, file, row.names = FALSE)
      }
    )
    
    output$download_cfhi_plot <- downloadHandler(
      filename = function() {
        paste0("CFHI_plot_", format(Sys.Date(), "%Y%m%d"), ".png")
      },
      content = function(file) {
        df <- df_filtered()
        req(nrow(df) > 0)
        
        selected_comps <- input$show_components
        
        # Use ggplot2 for reliable PNG export
        p <- ggplot(df, aes(x = date, y = cfhi)) +
          geom_line(aes(color = "CFHI (Composite)"), linewidth = 1.2) +
          geom_point(aes(color = "CFHI (Composite)"), size = 1.5) +
          scale_color_manual(name = "", values = c("CFHI (Composite)" = "#1e40af"))
        
        if (!is.null(selected_comps) && length(selected_comps) > 0) {
          if (!all(c("s_star","w_star","i_star","r_star") %in% names(df))) {
            s <- 100 * scale01(df$savings_rate)
            w <- 100 * scale01(df$wage_yoy)
            i <- 100 - 100 * scale01(df$inflation_yoy)
            r <- 100 - 100 * scale01(df$borrow_rate)
            df$s_star <- s; df$w_star <- w; df$i_star <- i; df$r_star <- r
          }
          
          colors <- c("CFHI (Composite)" = "#1e40af")
          linetypes <- c("CFHI (Composite)" = "solid")
          
          if ("savings" %in% selected_comps) {
            p <- p + geom_line(data = df, aes(x = date, y = s_star, color = "Savings Rate ↑"), 
                              linetype = "dashed", linewidth = 0.8)
            colors["Savings Rate ↑"] <- "#16a34a"
            linetypes["Savings Rate ↑"] <- "dashed"
          }
          if ("wages" %in% selected_comps) {
            p <- p + geom_line(data = df, aes(x = date, y = w_star, color = "Wage Growth ↑"), 
                              linetype = "dashed", linewidth = 0.8)
            colors["Wage Growth ↑"] <- "#0891b2"
            linetypes["Wage Growth ↑"] <- "dashed"
          }
          if ("inflation" %in% selected_comps) {
            p <- p + geom_line(data = df, aes(x = date, y = i_star, color = "Inflation ↓"), 
                              linetype = "dashed", linewidth = 0.8)
            colors["Inflation ↓"] <- "#ea580c"
            linetypes["Inflation ↓"] <- "dashed"
          }
          if ("borrow" %in% selected_comps) {
            p <- p + geom_line(data = df, aes(x = date, y = r_star, color = "Borrow Rate ↓"), 
                              linetype = "dashed", linewidth = 0.8)
            colors["Borrow Rate ↓"] <- "#c026d3"
            linetypes["Borrow Rate ↓"] <- "dashed"
          }
          
          p <- p + scale_color_manual(name = "", values = colors) +
                   scale_linetype_manual(name = "", values = linetypes)
        }
        
        p <- p + 
          labs(title = paste0("CFHI: ", format(min(df$date), "%b %Y"), " - ", format(max(df$date), "%b %Y")),
               x = "", y = "Index (0=Worst, 100=Best)") +
          theme_minimal() +
          theme(legend.position = "bottom",
                plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
                panel.grid.minor = element_blank())
        
        ggsave(file, plot = p, width = 12, height = 6, dpi = 300, bg = "white")
      }
    )
  })
}


