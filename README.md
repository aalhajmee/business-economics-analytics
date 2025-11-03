# Financial Health Dashboard

Business and Economics Analytics group project by **Ammar Alhajmee**, **Bemnet Ali**, and **Colin Bridges**.

An interactive R Shiny dashboard for analyzing consumer financial health through economic indicators, state comparisons, and personal finance calculators.

## 🚀 Quick Start

### First Time Setup (All Machines)

```bash
# 1. Install all required R packages
Rscript install_packages.R

# 2. Run the dashboard
Rscript run_app.R
```

The app will automatically open in your browser at http://127.0.0.1:3838

### For Collaborators

When working across multiple machines or after pulling new changes:

```bash
git pull origin main
Rscript install_packages.R  # Installs any new packages
Rscript run_app.R
```

## 📊 Features

- **CFHI Analysis** - Consumer Financial Health Index tracking and visualization
- **State Economic Analysis** - Compare all 50 U.S. states on income, employment, poverty, and cost of living
- **Forecasting** - Time series predictions for economic indicators
- **Personal Finance Calculators** - Budgeting tools, savings guidance, and loan approval predictions

## 📦 Required Packages

All packages are automatically installed by `install_packages.R`:

- Shiny ecosystem: `shiny`, `shinydashboard`, `shinythemes`, `shinyjs`
- Data: `dplyr`, `tidyr`, `readr`, `readxl`, `DT`
- Visualization: `ggplot2`, `plotly`
- Time series: `zoo`, `lubridate`, `forecast`
- ML: `glmnet`

## 📖 Documentation

See [README_SETUP.md](README_SETUP.md) for detailed setup instructions, troubleshooting, and development workflow.

## 🛠️ Development

This is a class project for Business and Economics Analytics.
