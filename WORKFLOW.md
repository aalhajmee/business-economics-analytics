# Development Workflow

## Project Structure

```
business-economics-analytics/
├── ui.R                    # Main UI definition
├── server.R                # Main server logic
├── install_packages.R      # Manual package installer
│
├── tabs/                   # UI tab definitions
│   ├── frontpage.R
│   ├── cfhi_tab.R
│   ├── cfhi_data_tab.R
│   ├── forecast_tab.R
│   ├── state_analysis_tab.R
│   ├── state_data_tab.R
│   ├── loans.R
│   ├── savingsguide.R
│   └── overview.R
│
├── server/                 # Server logic files
│   ├── forecast_server.R
│   ├── state_analysis_server.R
│   ├── calculations.R
│   └── Loan_Approval_Calculator.R
│
├── modules/                # Reusable modules
│   ├── cfhi_feature_ui.R
│   └── cfhi_feature_server.R
│
├── cfhi_data/
├── Financial_Calculator_datasets/
└── www/
```

## Standard Workflow

### Before Starting Work
```bash
cd /path/to/business-economics-analytics
git pull origin main
```

### Making Changes
1. Open files in Posit Workbench
2. Edit and save changes
3. Test application: `Rscript -e "shiny::runApp()"`
4. Commit changes:
   ```bash
   git add [modified-files]
   git commit -m "Description of changes"
   git push origin main
   ```

### Handling Push Conflicts
If push is rejected due to remote changes:
```bash
git pull origin main
```
Resolve any merge conflicts if they occur, then:
```bash
git push origin main
```

## Adding New Features

### Creating a New Tab

1. Create new file in `tabs/` directory (e.g., `tabs/new_feature.R`)

2. Define tab UI:
   ```r
   tabItem(
     tabName = "feature_name",
     h2("Feature Title"),
     # UI components
   )
   ```

3. Register tab in `ui.R`:
   
   Add source call (around line 50):
   ```r
   feature_tab <- safe_source_tab("tabs/new_feature.R", "feature_name")
   ```
   
   Add menu item (around line 70):
   ```r
   menuSubItem("Feature Title", tabName = "feature_name")
   ```
   
   Add to body (around line 120):
   ```r
   feature_tab,
   ```

4. Add server logic if required:
   
   Create `server/new_feature_server.R`
   
   Source in `server.R` (around line 23):
   ```r
   source("server/new_feature_server.R", local = TRUE)
   ```

5. Test and commit:
   ```bash
   Rscript -e "shiny::runApp()"
   git add tabs/new_feature.R ui.R server.R server/new_feature_server.R
   git commit -m "Add new feature tab"
   git push origin main
   ```

### Modifying Existing Features

1. Locate relevant file in `tabs/` or `server/`
2. Make modifications and save
3. Test: `Rscript -e "shiny::runApp()"`
4. Commit and push changes

### Adding New Package Dependencies

1. Add library call to your code:
   ```r
   library(package_name)
   ```

2. Update `ui.R` (line 8):
   ```r
   required_packages <- c("shiny", "shinydashboard", "shinythemes", "shinyjs", 
                          "tidyverse", "readxl", "plotly", "DT", "zoo", 
                          "lubridate", "forecast", "glmnet", "package_name")
   ```

3. Update `install_packages.R` (lines 19-30):
   ```r
   required_packages <- c(
     "shiny", "shinydashboard", "shinythemes", "shinyjs",
     "tidyverse", "readxl", "plotly", "DT", "zoo",
     "lubridate", "forecast", "glmnet", "package_name"
   )
   ```

4. Test and commit:
   ```bash
   Rscript -e "shiny::runApp()"
   git add ui.R install_packages.R [your-modified-files]
   git commit -m "Add package_name dependency"
   git push origin main
   ```

Note: The application automatically installs missing packages on startup.

## Common Commands

### Terminate running app:
```bash
pkill -9 Rscript
```

### Manual package installation:
```bash
Rscript install_packages.R
```

### Check repository status:
```bash
git status
git diff
```

### Discard local changes:
```bash
git checkout -- [filename]
```
