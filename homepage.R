tabItem(
  tabName = "home",
  h2("Welcome to our Financial Health Dashboard"),
  br(),
  
  # Gradient color bar
  div(
    style = "
      height: 30px;
      background: linear-gradient(to right, red, orange, yellow, limegreen, green);
      border-radius: 4px;
      margin-left: auto;
      margin-right: auto;
      width: 80%;
    "
  ),
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
        strong("CHFI = 0"), br(),
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
        strong("CHFI = 100"), br(),
        "indicates high financial health"
      )
    )
  ),
  
  br(),
  
  # === CFHI feature panel ===
  shinydashboard::box(
    title = "Consumer Financial Health Index (CFHI) — Current Realistic CHFI",
    width = 12, status = "primary", solidHeader = TRUE,
    # The module renders:
    # - date-range control (change time window),
    # - line with points + month–year labels (toggle in module),
    # - current latest CHFI summary card,
    # - smoothing control inside the module.
    cfhi_feature_ui("cfhi")
  )
)