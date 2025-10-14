library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Financial Health"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Explore", tabName = "explore", icon = icon("search")),
      menuItem("Forecasting", tabName = "forecast", icon = icon("line-chart")),
      menuItem("Savings Guide", tabName = "guide", icon = icon("lightbulb")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # --- HOME TAB ---
      tabItem(tabName = "home",
              h2("Welcome to our Financial Health Dashboard"),
              br(),
              
              # Gradient bar
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
              
              # Text boxes below
              fluidRow(
                column(6,
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
                column(6,
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
              )
      ),
      
      # --- SAVINGS GUIDE TAB ---
      tabItem(tabName = "guide",
              h2("Savings Guide"),
              p("Enter your information and learn how to improve your financial health step-by-step.")
      ),
      
      # --- FORECASTING TAB ---
      tabItem(tabName = "forecast",
              h2("Forecasting"),
              p("Predict future trends.")
      ),
      
      # --- EXPLORE TAB ---
      tabItem(tabName = "explore",
              h2("Explore"),
              p("Dive into the data and uncover insights.")
      ),
      
      tabItem(tabName = "about",
      h2("About This Dashboard"),
      p("This is a project done by Ammar Alhajmee, Bemnet Ali, and Colin Bridges."),
      br(),
      p("Data Sources:")
    )
  )
)
)
