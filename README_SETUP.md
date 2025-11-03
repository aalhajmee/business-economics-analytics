# Financial Health Dashboard - Setup Guide

## Quick Start (First Time Setup)

### Option 1: Automatic Setup (Recommended)
```bash
# Step 1: Install all required packages
Rscript install_packages.R

# Step 2: Run the dashboard
Rscript run_app.R
```

### Option 2: Manual Setup
```r
# In R or RStudio, run:
source("install_packages.R")
source("run_app.R")
```

## For Collaborators

If you're working on this project across multiple machines, follow these steps on each new machine:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aalhajmee/business-economics-analytics.git
   cd business-economics-analytics
   ```

2. **Install packages:**
   ```bash
   Rscript install_packages.R
   ```

3. **Run the app:**
   ```bash
   Rscript run_app.R
   ```

## Required Packages

The dashboard requires the following R packages:

### Core Shiny Packages
- `shiny` - Web application framework
- `shinydashboard` - Dashboard layout components
- `shinythemes` - Additional themes
- `shinyjs` - JavaScript operations

### Data Manipulation
- `dplyr` - Data manipulation
- `tidyr` - Data tidying
- `readr` - Reading CSV files
- `readxl` - Reading Excel files

### Visualization
- `ggplot2` - Statistical graphics
- `plotly` - Interactive plots
- `DT` - Interactive data tables

### Time Series
- `zoo` - Time series handling
- `lubridate` - Date/time manipulation
- `forecast` - Time series forecasting

### Machine Learning
- `glmnet` - Elastic net models (for loan calculator)

## Required Data Files

Make sure these files exist in your repository:

```
cfhi_data/
├── cfhi_master_2000_onward.csv

Financial_Calculator_datasets/
├── loan_approval.xlsx
└── State_Data.xlsx
```

## Troubleshooting

### Port Already in Use
If you see "address already in use" error:
```bash
# On macOS/Linux:
lsof -ti:3838 | xargs kill -9

# On Windows (in PowerShell):
Get-Process -Id (Get-NetTCPConnection -LocalPort 3838).OwningProcess | Stop-Process -Force
```

### Missing Packages
Run the installer again:
```bash
Rscript install_packages.R
```

### Package Installation Fails
Try installing problematic packages individually in R:
```r
install.packages("package_name", repos = "https://cloud.r-project.org")
```

### App Won't Start
1. Check that `ui.R` and `server.R` exist in the current directory
2. Verify all data files are present
3. Make sure no merge conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) exist in code files
4. Check R console for specific error messages

## Running on Different Ports

If port 3838 is unavailable, edit `run_app.R` and change:
```r
port = 3838
```
to:
```r
port = 8080  # or any available port
```

## Development Workflow

### Before Committing Changes
1. Test your changes locally: `Rscript run_app.R`
2. Check for errors in all tabs
3. Verify data loads correctly
4. Add any new required packages to both `install_packages.R` and `run_app.R`

### After Pulling Changes
If collaborators added new packages:
```bash
git pull origin main
Rscript install_packages.R  # Install any new packages
Rscript run_app.R
```

## System Requirements

- **R Version:** 4.0.0 or higher recommended
- **Operating Systems:** Windows, macOS, Linux
- **RAM:** 4GB minimum, 8GB recommended
- **Storage:** ~500MB for packages and data

## Getting Help

- Check the error messages in the R console
- Review the `MERGE_CONFLICT_INSTRUCTIONS.md` for git issues
- Ensure all packages are up to date: `update.packages()`

## Contributors

- Ammar Alhajmee
- Bemnet Ali
- Colin Bridges

## License

See LICENSE file for details.
