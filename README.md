# Financial Health Analytics Dashboard

Dashboard analyzing U.S. household financial health with economic indicators, forecasting models, market correlations, and personal finance calculators.

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

The Composite Financial Health Index (CFHI) synthesizes four economic indicators into a single measure of household financial well-being.

**Overview Tab**
- Time series visualization from January 2000 to August 2025 (233 monthly observations)
- Interactive component breakdown: Savings Rate, Wage Growth, Inflation, Borrowing Rate
- Each component min-max normalized to 0-100 scale (inflation and interest rates inverted)
- CFHI = simple average of four components, naturally ranging 0-100
- Historical range: 17.90 (May 2007 pre-crisis) to 93.34 (April 2020 pandemic peak)

**Key Findings Tab**
- Academic analysis of three major historical patterns
- Finding 1: 2007 pre-crisis financial deterioration (CFHI = 17.90 months before market crash)
- Finding 2: 2020 pandemic savings peak (forced savings, stimulus, zero rates)
- Finding 3: 2024-2025 affordability crisis (current 28.38 similar to pre-2008 levels)
- Finding 4: Stock market disconnect (1,000-point S&P gain = 0.7 CFHI increase)
- Professional academic writing with comprehensive methodology documentation

**Forecasting Tab**
- Ensemble ARIMA/ETS time series models
- Forecast horizons: 6 months, 1 year, 2 years
- Scenario-based projections: baseline, economic growth, recession, high inflation
- Custom parameter adjustments for each component
- Confidence intervals (80% and 95%) with uncertainty quantification

**S&P 500 Correlation Tab**
- Regression analysis of market impact on household finances
- Dual-axis time series comparing CFHI and S&P 500 (April 2006 - August 2025)
- Multiple regression controlling for Federal Reserve policy
- Statistical finding: β = 0.0007 per S&P point (statistically significant, practically negligible)
- Rolling 12-month correlation tracking
- Dynamic date filtering and automated interpretation

**Data Sources Tabs**
- CFHI methodology: BEA savings, BLS wages/inflation, FRED interest rates
- Market data: FactSet S&P 500 historical prices
- Comprehensive coverage periods and update frequencies
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

- **Framework**: R Shiny 1.9.1 with shinydashboard
- **Data Processing**: tidyverse (dplyr, tidyr, readr, lubridate)
- **Visualization**: plotly for interactive graphics, ggplot2 for static plots
- **Time Series**: forecast package (auto.arima, ets)
- **Statistical Analysis**: Linear regression, correlation analysis
- **Data Tables**: DT package for interactive tables

### Project Structure

```
business-economics-analytics/
├── ui.R                        # Main UI definition
├── server.R                    # Server logic coordinator
├── tabs/                       # UI components for each feature
│   ├── cfhi_tab.R
│   ├── cfhi_feature_ui.R      # CFHI module UI
│   ├── forecast_tab.R
│   ├── market_correlation_tab.R
│   ├── state_analysis_tab.R
│   └── loans.R
├── server/                     # Backend logic for each feature
│   ├── cfhi_feature_server.R  # CFHI module server
│   ├── forecast_server.R
│   ├── market_correlation_server.R
│   ├── state_analysis_server.R
│   └── retirement_calculator.R
├── data/                       # All project data organized by feature
│   ├── cfhi/                  # CFHI economic indicators
│   │   ├── cfhi_master_2000_onward.csv
│   │   ├── series_raw/
│   │   ├── series_normalized/
│   │   └── by_year/
│   ├── market/                # S&P 500 market data
│   │   └── SP500_PriceHistory_Monthly_042006_082025_FactSet.xlsx
│   ├── state/                 # State economic demographics
│   │   └── State_Data_Demographics.csv
│   └── loan/                  # Loan approval dataset
│       └── loan_approval.xlsx
└── www/                        # Static assets (images, CSS)
```

## Data Sources

**CFHI Components** (233 monthly observations)
- Personal Savings Rate: Bureau of Economic Analysis (BEA)
- Average Hourly Earnings Growth: Bureau of Labor Statistics (BLS)
- Consumer Price Index (CPI-U): Bureau of Labor Statistics (BLS)
- Federal Funds Effective Rate: Federal Reserve Economic Data (FRED)
- Coverage: January 2000 to August 2025, monthly frequency

**S&P 500 Index** (233 observations overlapping with CFHI)
- Source: FactSet Research Systems (equivalent data available via Yahoo Finance)
- Coverage: April 2006 to August 2025, end-of-month prices
- Fields: closing price, monthly returns, volume, total return index

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

See [REPRODUCIBILITY.md](REPRODUCIBILITY.md) for complete environment details, package versions, and instructions for reproducing all analyses.
- Modeling: glmnet

## Methodology Notes

**CFHI Calculation**
- Four components normalized independently using min-max scaling (0-100)
- Inflation and interest rates inverted (lower = better)
- Simple average: CFHI = (S* + W* + I* + R*) / 4
- No rebasing or additional transformations
- Naturally bounded 0-100 where extremes represent historical worst/best

**Key Findings**
- 2007 Trough (17.90): Pre-crisis financial stress with negative savings, peak rates
- 2020 Peak (93.34): Pandemic-era forced savings, stimulus, zero rates
- 2025 Current (28.38): Post-inflation affordability crisis near 2007 levels
- Stock Market Impact: Minimal (1,000 S&P points = 0.7 CFHI change = <1% of range)

**Statistical Approach**
- Time series: Ensemble ARIMA/ETS averaging for robustness
- Correlation: Multiple regression isolating S&P 500 effect from Fed policy
- Scenarios: Adjustments applied to base forecast via component-specific multipliers
- Confidence intervals: Derived from model prediction variance

This project was developed for BIOL 185 - Data Science at Washington and Lee University.

## Team Contributions


### Ammar Alhajmee
**Primary Focus:** 
- fill later

### Bemnet Ali
**Primary Focus:** 
- fill later

### Colin Bridges
**Primary Focus:** 
- fill later



**Note:** While individual contributions are documented above, this was a truly collaborative project where team members frequently consulted each other, shared ideas, and helped debug issues across all components. The final product reflects the collective effort and expertise of all three team members.
