tabItem(
  tabName = "home",
  h2("Welcome to our Financial Health Dashboard"),
  br(),
  p("Use the sidebar to navigate between different features:"),
  br(),
  fluidRow(
    column(
      4,
      div(
        style = "
          border: 2px solid #1e2a38;
          border-radius: 8px;
          padding: 15px;
          text-align: center;
          box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
          background-color: #f9f9f9;
        ",
        h4("CFHI Analysis"),
        p("Track the Consumer Financial Health Index")
      )
    ),
    column(
      4,
      div(
        style = "
          border: 2px solid #1e2a38;
          border-radius: 8px;
          padding: 15px;
          text-align: center;
          box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
          background-color: #f9f9f9;
        ",
        h4("Savings Guide"),
        p("Use the 50/30/20 rule for budgeting")
      )
    ),
    column(
      4,
      div(
        style = "
          border: 2px solid #1e2a38;
          border-radius: 8px;
          padding: 15px;
          text-align: center;
          box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
          background-color: #f9f9f9;
        ",
        h4("Loan Calculator"),
        p("Estimate loan approval probability")
      )
    )
  )
)

