# Financial Health Dashboard

Business and Economics Analytics group project by Ammar Alhajmee, Bemnet Ali, and Colin Bridges.

An interactive R Shiny dashboard for analyzing household financial well-being through the Composite Financial Health Index (CFHI), macroeconomic correlations, state-level economic comparisons, and personal finance tools.

## ⚠️ Disclaimer

**AI-Assisted Development**: The code in this project was primarily written with the assistance of Large Language Model (LLM) AI tools, including ChatGPT and Claude. These AI models were used to generate code, provide implementation guidance, and assist with debugging throughout the development process. While the project concept, design decisions, and data analysis approaches were directed by the team members, the actual code implementation heavily relied on AI assistance.

## Quick Start

### Running the Application

```bash
# Automatic package installation and launch
Rscript -e "shiny::runApp()"
```


The application automatically detects and installs missing R packages on first run. Access the dashboard at http://127.0.0.1:3838 after startup.

### Manual Installation

```bash
# Install dependencies first
Rscript install_packages.R

# Launch dashboard
Rscript -e "shiny::runApp()"
```

## Features

### CFHI Analysis

The Composite Financial Health Index (CFHI) aggregates multiple economic indicators to measure household financial well-being over time.

**Analysis Tab**
- Time series visualization of CFHI from 2000-2025
- Interactive component breakdown showing individual indicator contributions
- Correlation matrix analyzing relationships between financial components
- Statistical summaries and trend analysis

**Forecasting Tab**
- Ensemble time series forecasting combining ARIMA and ETS models
- Multiple forecast horizons: 6 months, 1 year, 2 years
- Four preset economic scenarios: baseline, growth, decline, high inflation
- Custom scenario modeling with adjustable parameters for savings rates, wage growth, inflation, and borrowing costs
- Confidence interval visualization (80% and 95%)

**Data Sources Tab**
- Detailed methodology documentation
- Component variable descriptions and sources
- Data processing pipeline explanation
- Coverage period and frequency information

### Market Analysis

Analysis of the relationship between stock market performance and household financial health using S&P 500 index data.

**S&P 500 Correlation Tab**
- Dual-axis time series comparing CFHI and S&P 500 trends (2006-2025)
- Linear regression analysis with scatter plots
- Rolling 12-month correlation tracking
- Statistical metrics: Pearson/Spearman correlation coefficients, R-squared, p-values
- Dynamic date range filtering: full period, 10/5/3 years, or custom ranges
- Automated insight generation interpreting correlation strength and significance

**Market Data Sources Tab**
- FactSet data documentation
- S&P 500 methodology and relevance to household finances
- Data overlap and quality considerations
- Limitations and interpretation guidelines

### State Analysis

State-level economic comparison tools for analyzing geographic variations in financial conditions.

**Explore States Tab**
- Interactive U.S. state selection
- Comparative economic metrics: median income, unemployment rates, cost of living indices
- Time series visualizations of state economic indicators
- Multi-state comparison capabilities
- Data tables with sorting and filtering

**Data Sources Tab**
- State economic data sources and collection methodology
- Variable definitions and measurement standards
- Geographic coverage details

### Personal Finance Tools

Practical calculators and guides for individual financial planning.

**Overview Tab**
- Summary of available personal finance features
- Quick links to specific tools

**Savings Guide Tab**
- Savings rate recommendations based on income levels
- Goal-based savings calculations
- Visual savings projections over time
- Best practices and financial planning tips

**Loan Calculator Tab**
- Loan approval probability estimator using logistic regression
- Required inputs: credit score, income, debt-to-income ratio, loan amount
- Amortization schedule generation
- Monthly payment calculations
- Total interest cost analysis
- Interactive parameter adjustment

## Technical Architecture

**Framework**: R Shiny with shinydashboard
**Data Processing**: tidyverse (dplyr, tidyr, readr, lubridate)
**Visualization**: plotly, ggplot2
**Time Series**: forecast package (auto.arima, ets)
**Statistical Modeling**: glmnet for regularized regression

### Project Structure

```
business-economics-analytics/
├── ui.R                        # Main UI definition
├── server.R                    # Server logic coordinator
├── tabs/                       # UI components for each feature
│   ├── cfhi_tab.R
│   ├── forecast_tab.R
│   ├── market_correlation_tab.R
│   ├── state_analysis_tab.R
│   └── loans.R
├── server/                     # Backend logic for each feature
│   ├── forecast_server.R
│   ├── market_correlation_server.R
│   └── state_analysis_server.R
├── modules/                    # Reusable Shiny modules
├── cfhi_data/                  # CFHI and S&P 500 datasets
│   ├── cfhi_master_2000_onward.csv
│   └── SP500_PriceHistory_Monthly_042006_082025_FactSet.xlsx
└── Financial_Calculator_datasets/  # State and loan data
```

## Data Sources

**CFHI Components**
- Federal Reserve Economic Data (FRED): savings rates, borrowing rates, inflation
- Bureau of Labor Statistics (BLS): wage data, CPI
- Coverage: January 2000 to December 2025, monthly frequency

**S&P 500 Index**
- Source: FactSet Research Systems
- Coverage: April 2006 to August 2025, end-of-month prices
- Includes: price, volume, total return, cumulative return

**State Economic Data**
- U.S. Census Bureau: income statistics
- Bureau of Labor Statistics: unemployment rates
- Various sources: cost of living indices

**Loan Data**
- Synthetic dataset for educational purposes
- Variables: credit scores, income, debt ratios, approval outcomes

## Required Packages

The application requires the following R packages (auto-installed on first run):

- Core: shiny, shinydashboard, shinythemes, shinyjs
- Data manipulation: tidyverse (includes dplyr, tidyr, ggplot2, readr)
- Data import: readxl, DT
- Time series: zoo, lubridate, forecast
- Visualization: plotly
- Modeling: glmnet

## Development Notes

This dashboard was developed as a class project for Business and Economics Analytics. The CFHI methodology synthesizes multiple economic indicators into a composite measure of household financial health. Forecasting models use ensemble methods to improve prediction accuracy. Market correlation analysis employs both Pearson and Spearman methods to capture linear and monotonic relationships. All visualizations are interactive using plotly for enhanced data exploration.
