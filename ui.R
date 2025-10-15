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
      #HOME TAB
      tabItem(tabName = "home",
              h2("Welcome to our Financial Health Dashboard"),
              br(),
              
              #Gradient color bar
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
      
      #SAVINGS GUIDE TAB
      tabItem(tabName = "guide",
              h2("Savings Guide"),
              br(),
              h3("The 50, 30, 20 Rule"),
              img(savingchart = "savingchart.png", height = "200px", width = "300px"),
              p("Enter your information and learn how to improve your financial health step-by-step."),
              p("Make sure to consistently use monthly or yearly values."),
              numericInput("inNumber", "Gross Monthly Income:",
                           min = 0, max = 1000000000, value = 0, step = 1000),
              numericInput("inNumber2", "Rent or Mortgage Payments:",
                           min = 0, max = 1000000000, value = 0, step = 100),
              numericInput("inNumber3", "Utility Bills:",
                           min = 0, max = 1000000000, value = 0, step = 100),
              numericInput("inNumber4", "Healthcare:",
                           min = 0, max = 1000000000, value = 0, step = 100),
              numericInput("inNumber5", "Insurance Payments:",
                           min = 0, max = 1000000000, value = 0, step = 100),
              numericInput("inNumber6", "Other Needs*:",
                           min = 0, max = 1000000000, value = 0, step = 100),
              p("*If you can honestly say “I can’t live without it,” you have identified a need. Minimum required payments on a credit card or a loan also belong in this category")
      ),
      
      #FORECASTING TAB
      tabItem(tabName = "forecast",
              h2("Forecasting"),
              p("Predict future trends.")
      ),
      
      #EXPLORE TAB
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