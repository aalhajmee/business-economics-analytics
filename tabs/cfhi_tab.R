tabItem(
  tabName = "cfhi",
  h2("Consumer Financial Health Index (CFHI)",
     style = "text-align:center;
              font-family:'Trebuchet MS',sans-serif;
              font-weight:600;
              font-size:32px;"),
  br(),
  
  # Legend cards
  fluidRow(
    column(
      6,
      div(
        style = "
          border: 2px solid #1e2a38;
          border-radius: 8px;
          padding: 10px;
          width: 220px;
          margin-left: auto;
          margin-right: auto;
          text-align: center;
          box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
          background-color: #f9f9f9;
        ",
        strong("CFHI = 0"), br(),
        "indicates low financial health"
      )
    ),
    column(
      6,
      div(
        style = "
          border: 2px solid #1e2a38;
          border-radius: 8px;
          padding: 10px;
          width: 220px;
          margin-left: auto;
          margin-right: auto;
          text-align: center;
          box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
          background-color: #f9f9f9;
        ",
        strong("CFHI = 100"), br(),
        "indicates high financial health"
      )
    )
  ),
  
  br(),
  
  # === CFHI feature panel ===
  shinydashboard::box(
    title = "Consumer Financial Health Index (CFHI)",
    width = 12, status = "primary", solidHeader = TRUE,
    cfhi_feature_ui("cfhi")
  ),
  p(".")
  )

