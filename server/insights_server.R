# === LOAD DATASET ===
finance_data <- read.csv("data/personal/synthetic_personal_finance_dataset.csv")

# === Reactive Filter ===
filtered_data <- reactive({
  data <- finance_data
  if (input$region_filter != "All") {
    data <- subset(data, region == input$region_filter)
  }
  if (input$loan_filter != "All") {
    data <- subset(data, loan_type == input$loan_filter)
  }
  data
})

# === Dynamic Scatter Plot ===
output$scatter_plot <- renderPlot({
  data <- filtered_data()
  xvar <- input$x_var
  yvar <- input$y_var
  
  # Labels for axes
  x_label <- names(which(sapply(formals(selectInput)[["choices"]], identical, xvar)))
  y_label <- names(which(sapply(formals(selectInput)[["choices"]], identical, yvar)))
  
  plot(
    data[[xvar]], data[[yvar]],
    col = "#66003380", pch = 19,
    xlab = gsub("_", " ", xvar),
    ylab = gsub("_", " ", yvar),
    main = paste("Relationship between", gsub("_", " ", xvar), "and", gsub("_", " ", yvar)),
    family = "Trebuchet MS"
  )
  grid()
  abline(lm(data[[yvar]] ~ data[[xvar]]), col = "#006699", lwd = 2)
  
  # === Download Handler ===
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("personal_finance_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(finance_data, file, row.names = FALSE)
    }
  )
  
})
