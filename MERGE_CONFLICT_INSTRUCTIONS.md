# MERGE CONFLICT RESOLUTION INSTRUCTIONS

## For Your Collaborator

Your local files have merge conflicts. Here's how to fix them:

### OPTION 1: Simple Copy/Replace (Recommended)

1. **Backup your current files** (just in case):
   ```bash
   cp ui.R ui.R.backup
   cp server.R server.R.backup
   ```

2. **Copy the resolved files**:
   ```bash
   cp ui_resolved.R ui.R
   cp server_resolved.R server.R
   ```

3. **Remove the resolved files**:
   ```bash
   rm ui_resolved.R
   rm server_resolved.R
   ```

4. **Commit the changes**:
   ```bash
   git add ui.R server.R
   git commit -m "Resolve merge conflicts"
   git push origin main
   ```

### OPTION 2: Manual Resolution

If you want to manually fix the conflicts, look for these markers and remove them:

```
<<<<<<< HEAD
(your old code)
=======
(new code from main)
>>>>>>> f379675...
```

**Keep this version for each conflict:**

#### In ui.R - Tab Sources (line ~28):
```r
home_tab       <- safe_source_tab("frontpage.R",     "home")
cfhi_tab       <- safe_source_tab("cfhi_tab.R",     "cfhi")
cfhi_data_tab  <- safe_source_tab("cfhi_data_tab.R", "cfhi_data")
explore_tab    <- safe_source_tab("state_analysis_tab.R", "explore")
state_data_tab <- safe_source_tab("state_data_tab.R", "state_data")
forecast_tab   <- safe_source_tab("forecast_tab.R", "forecast")
guide_tab      <- safe_source_tab("savingsguide.R", "guide")
overview_tab   <- safe_source_tab("overview.R", "overview")
loan_tab       <- safe_source_tab("loans.R", "loans")
```

#### In ui.R - Sidebar Menu (line ~50):
```r
menuItem("CFHI Analysis",   icon = icon("chart-line"),
  menuSubItem("Dashboard", tabName = "cfhi"),
  menuSubItem("Data Sources", tabName = "cfhi_data")
),
menuItem("State Analysis", icon = icon("map-marked-alt"),
  menuSubItem("Explore States", tabName = "explore"),
  menuSubItem("Data Sources", tabName = "state_data")
),
menuItem("Forecasting",     tabName = "forecast", icon = icon("line-chart")),
menuItem("Personal Finance", icon = icon("lightbulb"),
  menuSubItem("Overview",   tabName = "overview",    icon = icon("lightbulb")),
  menuSubItem("Savings Guide",   tabName = "guide",    icon = icon("lightbulb")),
  menuSubItem("Loan Calculator", tabName = "loans",     icon = icon("university"))
),
```

#### In ui.R - TabItems (line ~80):
Keep ALL tabs including:
- home_tab
- cfhi_tab
- cfhi_data_tab
- explore_tab
- state_data_tab
- forecast_tab
- overview_tab
- guide_tab
- loan_tab
- about (tabItem)

#### In server.R - Beginning:
Add these libraries at the top:
```r
library(shinyjs)
library(DT)
library(forecast)
```

#### In server.R - After state_analysis_server.R:
Add calculator logic:
```r
# ---- CALCULATOR LOGIC ----
if (file.exists("calculations.R")) {
  source("calculations.R", local = TRUE)
}

if (file.exists("Loan_Approval_Calculator.R")) {
  source("Loan_Approval_Calculator.R", local = TRUE)
}
```

#### In server.R - State Data Sources:
Keep the entire state_data_table output and download handler (lines ~40-90 in resolved version)

---

## Summary of Changes

### What's New:
✅ Hierarchical menu with sub-items (CFHI Analysis, State Analysis, Personal Finance)
✅ Data Sources tabs for CFHI and State data
✅ Forecast tab functionality
✅ Overview tab
✅ State data download functionality
✅ Improved navigation structure

### What's Preserved:
✅ All your loan calculator functionality
✅ Savings guide
✅ Calculations.R logic
✅ All existing features

---

## After Resolution

Once resolved, your app will have this structure:

**Sidebar Menu:**
- Home
- CFHI Analysis
  - Dashboard
  - Data Sources
- State Analysis
  - Explore States
  - Data Sources
- Forecasting
- Personal Finance
  - Overview
  - Savings Guide
  - Loan Calculator
- About

All features from both versions work together!
