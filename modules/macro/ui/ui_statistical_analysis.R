# ============================================================================
# Statistical Analysis - UI Component
# ============================================================================

statistical_analysis_ui <- function() {
  fluidRow(
    column(12,
      card(
        card_header("Statistical Analysis"),
        p("Advanced statistical methods for exploring relationships, testing hypotheses, and making predictions from macroeconomic data."),
        div(style = "margin-top: 15px;",
          actionButton("stat_show_methodology", "View Methodology", 
                     icon = icon("info-circle"), 
                     class = "btn-outline-primary btn-sm")
        )
      ),
      conditionalPanel(
        condition = "input.stat_show_methodology % 2 == 1",
        card(
          card_header("Methodology: Why These Statistical Tests?"),
          div(class = "p-3",
            h5("1. ANOVA (Analysis of Variance)"),
            p(style = "font-size: 14px;",
              "ANOVA is chosen to test for statistically significant differences in economic indicators across global regions. ",
              "Unlike simple visual comparisons, ANOVA provides a rigorous statistical framework to determine if observed ",
              "differences are likely due to chance or represent true regional disparities. This is essential for understanding ",
              "whether geographic factors meaningfully influence economic outcomes."
            ),
            hr(),
            h5("2. Multiple Linear Regression"),
            p(style = "font-size: 14px;",
              "Multiple linear regression allows us to quantify how much variation in life expectancy can be explained by ",
              "economic factors (GDP, unemployment, government debt, etc.). This method goes beyond correlation by providing ",
              "coefficients that indicate the magnitude and direction of relationships, while controlling for multiple variables ",
              "simultaneously. Residual analysis helps validate model assumptions."
            ),
            hr(),
            h5("3. Chi-Square Test of Independence"),
            p(style = "font-size: 14px;",
              "The Chi-Square test determines whether economic indicator categories (e.g., high/low GDP per capita, high/low inflation) ",
              "are independent of geographic regions. This test is appropriate for categorical data where countries are classified into ",
              "economic performance levels and regional groups. A significant result indicates that certain regions are more likely to have ",
              "specific economic characteristics, revealing geographic patterns in economic development."
            )
          )
        )
      )
    ),
    column(3,
      card(
        card_header("Analysis Selection"),
        selectInput("stat_analysis_type", "Select Analysis:",
                   choices = c(
                     "Regional Differences (ANOVA)" = "anova",
                     "Life Expectancy Regression" = "regression",
                     "Economic Independence (Chi-Square)" = "chisquare"
                   ),
                   selected = "anova")
      ),
      
      # ANOVA Controls
      conditionalPanel(
        condition = "input.stat_analysis_type == 'anova'",
        card(
          card_header("ANOVA Controls"),
          selectInput("anova_indicator", "Indicator:",
                     choices = c("Inflation Rate" = "inflation",
                               "Unemployment Rate" = "unemployment",
                               "GDP per Capita" = "gdp_per_capita",
                               "Life Expectancy" = "life_expectancy",
                               "Government Debt" = "govt_debt"),
                     selected = "inflation"),
          sliderInput("anova_year", "Year:", min = 1960, max = 2023, value = 2020, sep = "", step = 1),
          p(style = "font-size: 12px; color: #64748b;",
            "Tests if there are statistically significant differences in the selected indicator across global regions.")
        )
      ),
      
      # Regression Controls
      conditionalPanel(
        condition = "input.stat_analysis_type == 'regression'",
        card(
          card_header("Regression Controls"),
          selectInput("regression_year", "Year:", 
                     choices = NULL, selected = NULL),
          checkboxGroupInput("regression_predictors", "Predictor Variables:",
                           choices = c("GDP per Capita" = "gdp_per_capita",
                                     "Unemployment Rate" = "unemployment",
                                     "Government Debt" = "govt_debt",
                                     "Inflation Rate" = "inflation",
                                     "Population Growth" = "pop_growth"),
                           selected = c("gdp_per_capita", "unemployment")),
          p(style = "font-size: 12px; color: #64748b;",
            "Multiple linear regression predicting Life Expectancy from selected economic indicators.")
        )
      ),
      
      # Chi-Square Controls
      conditionalPanel(
        condition = "input.stat_analysis_type == 'chisquare'",
        card(
          card_header("Chi-Square Test Controls"),
          selectInput("chisquare_indicator", "Indicator:",
                     choices = c("GDP per Capita" = "gdp_per_capita",
                               "Inflation Rate" = "inflation",
                               "Unemployment Rate" = "unemployment",
                               "Life Expectancy" = "life_expectancy",
                               "Government Debt" = "govt_debt"),
                     selected = "gdp_per_capita"),
          sliderInput("chisquare_year", "Year:", min = 1960, max = 2023, value = 2020, sep = "", step = 1),
          selectInput("chisquare_categorization", "Categorization Method:",
                     choices = c("Above/Below Median" = "median",
                               "High/Medium/Low (Tertiles)" = "tertiles",
                               "Quartiles" = "quartiles"),
                     selected = "median"),
          p(style = "font-size: 12px; color: #64748b;",
            "Tests if economic indicator categories are independent of geographic regions.")
        )
      )
    ),
    
    column(9,
      # ANOVA Output
      conditionalPanel(
        condition = "input.stat_analysis_type == 'anova'",
        card(
          card_header("ANOVA Results"),
          htmlOutput("anova_results"),
          plotlyOutput("anova_plot", height = "400px")
        )
      ),
      
      # Regression Output
      conditionalPanel(
        condition = "input.stat_analysis_type == 'regression'",
        card(
          card_header("Regression Results"),
          htmlOutput("regression_summary"),
          plotlyOutput("regression_plot", height = "400px"),
          plotlyOutput("regression_residuals", height = "300px")
        )
      ),
      
      # Chi-Square Output
      conditionalPanel(
        condition = "input.stat_analysis_type == 'chisquare'",
        card(
          card_header("Chi-Square Test Results"),
          htmlOutput("chisquare_results"),
          plotlyOutput("chisquare_plot", height = "400px"),
          DTOutput("chisquare_table")
        )
      )
    )
  )
}

