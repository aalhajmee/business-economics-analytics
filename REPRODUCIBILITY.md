# Reproducibility Documentation

## Overview

This document ensures all analyses in the Financial Health Analytics Dashboard can be reliably reproduced. We follow best practices for computational reproducibility in data science.

## Random Seed Management

All stochastic processes in this application use fixed random seeds to ensure reproducible results across runs.

### Forecasting Module (`server/forecast_server.R`)
- **Seed:** `54321`
- **Purpose:** Ensures consistent forecast confidence intervals from bootstrap methods
- **Location:** 
  - Line 23: ARIMA and ETS model fitting
  - Line 127: Backtesting validation (12-month holdout)
- **Functions affected:**
  - `auto.arima()` - Automatic ARIMA selection with stepwise search
  - `ets()` - Exponential smoothing state space models
  - `forecast()` - Bootstrap confidence interval generation

### Retirement Calculator (`server/retirement_calculator.R`)
- **Seeds:** `12345` (Scenario A), `12346` (Scenario B)
- **Purpose:** Ensures consistent Monte Carlo simulation results
- **Location:** Lines 117 and 132
- **Functions affected:**
  - `rnorm()` - Random normal draws for investment returns and inflation
  - 200 simulation paths per scenario
- **Details:**
  - Each simulation generates 200 random portfolio trajectories
  - Investment returns: Normal distribution with user-specified mean and SD
  - Inflation: Normal distribution with separate mean and SD parameters
  - Monthly time steps over user-defined horizon

## Software Environment

### R Version
```
R version 4.5.1 (2025-06-13)
Platform: aarch64-apple-darwin20
Running under: macOS Sequoia 15.6.1
```

### Core Packages

| Package | Version | Purpose |
|---------|---------|---------|
| shiny | 1.9.1 | Web application framework |
| shinydashboard | 0.7.2 | Dashboard UI components |
| tidyverse | 2.0.0 | Data manipulation and visualization |
| plotly | 4.10.4 | Interactive plots |
| forecast | 8.23.0 | Time series forecasting (ARIMA, ETS) |
| readxl | 1.4.3 | Excel file import |
| DT | 0.33 | Interactive data tables |
| glmnet | 4.1-10 | Regularized regression models |
| lubridate | 1.9.4 | Date/time manipulation |
| zoo | 1.8-12 | Time series infrastructure |

### Full Session Info
Complete package dependency information can be obtained by running:
```r
sessionInfo()
```
within the R environment.

## Data Processing Pipeline

### Primary Data Sources

1. **CFHI Master Data** (`data/cfhi/cfhi_master_2000_onward.csv`)
   - **Source:** Compiled from FRED economic indicators
   - **Time Range:** January 2000 - Present
   - **Frequency:** Monthly
   - **Variables:**
     - Savings Rate (Personal Saving Rate - PSAVERT)
     - Wage Growth (Average Hourly Earnings YoY% - CES0500000003)
     - Inflation (CPI-U All Items YoY% - CPIAUCSL)
     - Borrowing Costs (Bank Prime Loan Rate - DPRIME)
   - **Processing:**
     - Min-max normalization to 0-100 scale
     - Equal weighting (0.25 each component)
     - Base period: October 2006 = 100

2. **S&P 500 Data** (`data/market/SP500_PriceHistory_Monthly_042006_082025_FactSet.xlsx`)
   - **Source:** FactSet via manual download
   - **Time Range:** April 2006 - August 2025
   - **Frequency:** Monthly closing prices
   - **Note:** Could be automated with financial API (e.g., Alpha Vantage, Yahoo Finance)

3. **State Demographics** (`data/state/State_Data_Demographics.csv`)
   - **Variables:** Population, median income, unemployment rate by state
   - **Source:** US Census Bureau and BLS

4. **Loan Approval Data** (`data/loan/loan_approval.xlsx`)
   - **Purpose:** Personal finance calculator training data
   - **Variables:** Income, debt, credit score, approval status

### Data Update Procedure
To update the CFHI master dataset:
1. Download latest monthly data from FRED for all 4 indicators
2. Run normalization script (saved in `data/cfhi/series_normalized/`)
3. Append to master CSV with proper date formatting (YYYY-MM-DD)

## Model Validation

### Forecast Models
- **Method:** Ensemble of ARIMA and ETS (average predictions)
- **Validation:** 12-month backtesting with train/test split
- **Metrics:** RMSE, MAE, MAPE
- **Diagnostics:** ACF/PACF plots, Q-Q plots for residual normality
- **Selection:** AIC/BIC comparison between ARIMA and ETS

### Correlation Analysis
- **Method:** Pearson correlation by default (Spearman available)
- **Hypothesis Test:** Two-tailed t-test at α = 0.05
- **Effect Size:** Cohen's interpretation (small/medium/large)
- **Confidence Intervals:** 95% CI on correlation coefficient

## Reproducing the Analysis

### Installation
```r
# Install all required packages
source("install_packages.R")
```

### Running the Application
```r
# Load dependencies and launch dashboard
shiny::runApp(port = 4012)
```

### Running Specific Analyses

#### 1. Forecast CFHI 12 Months Forward
```r
source("server/forecast_server.R", local = TRUE)
# Applies baseline scenario with ensemble ARIMA+ETS
# Results include 80% and 95% confidence bands
```

#### 2. Calculate CFHI-S&P500 Correlation
```r
source("server/market_correlation_server.R", local = TRUE)
# Pearson correlation with hypothesis test (α = 0.05)
# Includes rolling 12-month correlation analysis
```

#### 3. Monte Carlo Retirement Simulation
```r
source("server/retirement_calculator.R", local = TRUE)
# 200 simulations with fixed seed (12345)
# Returns distribution of portfolio outcomes
```

## Assumptions and Limitations

### CFHI Methodology Assumptions
1. **Equal Weighting:** All 4 components (Savings, Wages, Inflation, Borrowing) weighted at 25% each
   - **Justification:** Simplicity and interpretability; no strong theoretical basis for differential weighting
   - **Alternative:** Principal Component Analysis (PCA) could derive empirical weights

2. **Linear Normalization:** Min-max scaling assumes linear relationship between raw values and financial health
   - **Limitation:** May not capture non-linear threshold effects
   - **Example:** 10% inflation vs. 5% may be more than 2x worse for households

3. **Composite Index:** Assumes components are substitutable and additive
   - **Reality:** Interaction effects exist (e.g., wage growth + high inflation)

### Forecast Assumptions
1. **Stationarity:** ARIMA assumes differenced series is stationary
2. **Normality:** Residuals should be approximately normal (validated via Q-Q plots)
3. **No Structural Breaks:** Forecasts assume economic regime remains similar to training period
4. **Bootstrap:** Confidence intervals assume residuals are exchangeable

### Retirement Simulation Assumptions
1. **Normal Returns:** Investment returns follow normal distribution
   - **Reality:** Returns often have fat tails (use with caution for extreme scenarios)
2. **Constant Withdrawals:** Real withdrawals remain constant (inflation-adjusted)
3. **No Fees:** Does not account for management fees or taxes
4. **Independence:** Monthly returns are independent (no autocorrelation)

## Contact & Maintenance

For questions about reproducibility or to report issues:
- **Team:** Ammar Alhajmee, Bemnet Ali, Colin Bridges
- **Course:** BIOL 185 - Data Science for Biology
- **Institution:** Washington and Lee University
- **Last Updated:** November 2025

## Version Control

This project uses Git for version control. To reproduce a specific version:
```bash
git clone https://github.com/WL-Biol185-ShinyProjects/Financial-Health-Analytics-Dashboard.git
git checkout <commit-hash>
```

All major analysis changes are documented in commit messages and pull requests.
