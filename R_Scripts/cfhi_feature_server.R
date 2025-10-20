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
    output$cfhi_plot <- renderPlot({
      df <- df_filtered()
      req(nrow(df) > 0)
      
      show_components <- identical(input$show_series, "cfhi_plus")
      show_labels <- isTRUE(input$show_point_labels)
      
      gg <- ggplot(df, aes(x = date)) +
        theme_minimal(base_size = 13) +
        labs(
          title = paste0(title_prefix, " — Current Realistic CFHI"),
          subtitle = paste0("Monthly; window: ",
                            format(min(df$date), "%b %Y"), " — ",
                            format(max(df$date), "%b %Y")),
          x = NULL, y = "Index (Jan 2000 = 100)"
        ) +
        geom_line(aes(y = CFHI), linewidth = 1.1)
      
      if (show_components) {
        # recompute components if not present
        if (!all(c("S_star","W_star","I_star","R_star") %in% names(df))) {
          s <- 100 * scale01(df$savings_rate)
          w <- 100 * scale01(df$wage_yoy)
          i <- 100 - 100 * scale01(df$inflation_yoy)
          r <- 100 - 100 * scale01(df$borrow_rate)
          df$S_star <- s; df$W_star <- w; df$I_star <- i; df$R_star <- r
        }
        gg <- gg +
          geom_line(aes(y = S_star), linetype = 2, alpha = 0.8) +
          geom_line(aes(y = W_star), linetype = 2, alpha = 0.8) +
          geom_line(aes(y = I_star), linetype = 2, alpha = 0.8) +
          geom_line(aes(y = R_star), linetype = 2, alpha = 0.8)
      }
      
      gg <- gg + geom_point(aes(y = CFHI), size = 1.8)
      
      if (show_labels) {
        lab <- format(df$date, "%Y-%m")
        # keep it readable: nudge labels slightly
        gg <- gg + geom_text(aes(y = CFHI, label = lab),
                             size = 3, vjust = -0.6, check_overlap = TRUE)
      }
      
      gg
    })
  })
}
