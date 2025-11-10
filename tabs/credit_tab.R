library(shiny)

tabItem(
  tabName = "credit",
  
  fluidRow(
    column(12,
           h2("Credit Card Application Predictor"),
           p("Use our Random Forest machine learning model to predict credit card approval probability.")
    )
  ),
  
  fluidRow(
    # Sidebar-style column for inputs
    column(4,
           box(
             title = "Enter Application Details",
             status = "primary",
             solidHeader = TRUE,
             width = NULL,
             
             selectInput("Gender", 
                         "Gender:",
                         choices = c("Select..." = "", "Male" = "1", "Female" = "0")),
             
             numericInput("Age", 
                          "Age:",
                          value = NULL,
                          min = 18,
                          max = 100),
             
             numericInput("Debt", 
                          "Debt:",
                          value = NULL,
                          min = 0),
             
             selectInput("Married", 
                         "Marital Status:",
                         choices = c("Select..." = "", "Married" = "1", "Not Married" = "0")),
             
             selectInput("BankCustomer", 
                         "Bank Customer?:",
                         choices = c("Select..." = "", "Yes" = "1", "No" = "0")),
             
             selectInput("Industry", 
                         "Which best describes your current career industry?:",
                         choices = c("Select..." = "", "ConsumerDiscretionary", "Consumer Staples", 
                                     "Education", "Energy", "Financials", "Healthcare", 
                                     "Industrials", "InformationTechnology", "Materials", 
                                     "Real Estate", "Research", "Transport", "Utilities")),
             
             selectInput("Ethnicity", 
                         "Ethnicity:",
                         choices = c("Select..." = "", "White", "Latino", "Black", "Asian", "Other")),
             
             numericInput("YearsEmployed", 
                          "Years Employed:",
                          value = NULL,
                          min = 0),
             
             selectInput("PriorDefault", 
                         "No Prior Defaults?:",
                         choices = c("Select..." = "", "Yes" = "1", "No" = "0")),
             
             selectInput("Employed", 
                         "Employed?:",
                         choices = c("Select..." = "", "Yes" = "1", "No" = "0")),
             
             numericInput("CreditScore", 
                          "Credit Score:",
                          value = NULL,
                          min = 0,
                          max = 850),
             
             selectInput("DriversLicense", 
                         "Drivers License?:",
                         choices = c("Select..." = "", "Yes" = "1", "No" = "0")),
             
             selectInput("Citizen", 
                         "Are you a citizen?:",
                         choices = c("Select..." = "", "ByBirth", "ByOtherMeans", "Temporary")),
             
             numericInput("Income", 
                          "Annual Income ($):",
                          value = NULL,
                          min = 0),
             
             actionButton("predict", "Calculate Acceptance Probability", 
                          class = "btn-primary btn-block")
           )
    ),
    
    # Main panel for results
    column(8,
           tabBox(
             width = NULL,
             
             tabPanel("Prediction Results",
                      icon = icon("chart-bar"),
                      
                      conditionalPanel(
                        condition = "input.predict > 0",
                        box(
                          width = NULL,
                          status = "success",
                          solidHeader = TRUE,
                          title = textOutput("prediction_text"),
                          
                          plotOutput("prob_plot", height = "200px"),
                          br(),
                          verbatimTextOutput("prob_details")
                        )
                      ),
                      
                      box(
                        width = NULL,
                        title = "Instructions",
                        status = "info",
                        tags$ol(
                          tags$li("Fill out all the application fields in the left panel"),
                          tags$li("Click 'Calculate Acceptance Probability' to see results"),
                          tags$li("The prediction is based on a Random Forest model with 500 trees")
                        )
                      )
             ),
             
             tabPanel("Model Information",
                      icon = icon("info-circle"),
                      
                      box(
                        width = NULL,
                        title = "Random Forest Model Performance",
                        status = "primary",
                        solidHeader = TRUE,
                        verbatimTextOutput("model_summary")
                      ),
                      
                      box(
                        width = NULL,
                        title = "Feature Importance",
                        status = "primary",
                        solidHeader = TRUE,
                        plotOutput("importance_plot", height = "400px"),
                        p("This shows which features are most important for the prediction.")
                      )
             )
           )
    )
  )
)