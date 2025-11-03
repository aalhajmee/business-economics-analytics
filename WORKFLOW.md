# Team Workflow

## 📁 Project Structure

```
business-economics-analytics/
├── ui.R                    # Main UI - defines layout
├── server.R                # Main server - coordinates everything
├── install_packages.R      # Manual package installer
├── run_app.R               # App launcher with checks
│
├── tabs/                   # All UI tabs
│   ├── frontpage.R
│   ├── cfhi_tab.R
│   ├── cfhi_data_tab.R
│   ├── forecast_tab.R
│   ├── state_analysis_tab.R
│   ├── state_data_tab.R
│   ├── loans.R
│   ├── savingsguide.R
│   ├── overview.R
│   └── explore.R
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
├── cfhi_data/             # CFHI datasets
├── Financial_Calculator_datasets/  # Loan/state data
└── www/                   # Images/static files
```

---

## 🚀 Daily Workflow

### **Start Working**
```bash
cd /Users/[YOUR_NAME]/Desktop/DevOps/business-economics-analytics
git pull origin main                    # Get latest changes
Rscript -e "shiny::runApp()"           # Start app (auto-installs packages)
```

### **Make Changes**
1. Edit YOUR file (see ownership below)
2. Test in browser: http://127.0.0.1:3838
3. Commit:
   ```bash
   git add [your-file]
   git commit -m "What you changed"
   git push origin main
   ```
4. **Tell team in group chat**: "Pushed [file] - pull before working!"

### **If Push Fails** (someone else pushed first)
```bash
git pull origin main        # Get their changes
# If conflicts, fix them together on Zoom
git push origin main        # Try again
```

---

## 🎯 Adding New Features

### **Add a New Tab**

1. Create file in `tabs/`:
   ```bash
   # Create tabs/my_new_tab.R
   ```

2. Write tab code:
   ```r
   tabItem(
     tabName = "my_tab",
     h2("My Feature"),
     # Your UI here
   )
   ```

3. Add to `ui.R` (line ~50):
   ```r
   my_tab <- safe_source_tab("tabs/my_new_tab.R", "my_tab")
   ```

4. Add to menu in `ui.R` (line ~70):
   ```r
   menuSubItem("My Feature", tabName = "my_tab")
   ```

5. Add to body in `ui.R` (line ~120):
   ```r
   my_tab,
   ```

6. If needs server logic, create `server/my_tab_server.R` and add to `server.R`:
   ```r
   source("server/my_tab_server.R", local = TRUE)
   ```

7. Test, commit, push

### **Edit Existing Feature**

1. Find file in `tabs/` or `server/`
2. Make changes
3. Test: `Rscript -e "shiny::runApp()"`
4. Commit & push

### **Add New Package/Library**

**Example:** You want to use `leaflet` for interactive maps

1. **Add library to your code:**
   ```r
   # In your tabs/my_feature.R or server/my_server.R
   library(leaflet)
   
   # Use the package
   output$map <- renderLeaflet({
     leaflet() %>% addTiles()
   })
   ```

2. **Update `ui.R` line 8** - add to required_packages:
   ```r
   required_packages <- c("shiny", "shinydashboard", "shinythemes", "shinyjs", 
                          "tidyverse", "readxl", "plotly", "DT", "zoo", 
                          "lubridate", "forecast", "glmnet", "leaflet")
   #                                                    ^^^^^^^^ ADD HERE
   ```

3. **Update `install_packages.R` line 19-30** - add there too:
   ```r
   required_packages <- c(
     "shiny", "shinydashboard", "shinythemes", "shinyjs",
     "tidyverse", "readxl", "plotly", "DT", "zoo",
     "lubridate", "forecast", "glmnet", "leaflet"  # ADD HERE TOO
   )
   ```

4. **Test** (app auto-installs the new package):
   ```bash
   Rscript -e "shiny::runApp()"
   ```

5. **Commit & push:**
   ```bash
   git add ui.R install_packages.R tabs/my_feature.R
   git commit -m "Add leaflet package for interactive maps"
   git push origin main
   ```

6. **Tell team:** "📦 Added leaflet package - restart your app to install it!"

---

## 👥 File Ownership (Avoid Conflicts!)

| Your Name | Your Files | Can Edit Freely? |
|-----------|------------|------------------|
| **Ammar** | `tabs/state_analysis_tab.R`, `server/calculations.R` | ✅ Yes |
| **Bemnet** | `tabs/frontpage.R`, `tabs/savingsguide.R` | ✅ Yes |
| **Colin** | `tabs/loans.R`, `tabs/cfhi_tab.R`, `modules/cfhi_*` | ✅ Yes |
| **Anyone** | `ui.R`, `server.R` | ⚠️ Ask in chat first! |

**Golden Rule:** If you need to edit someone else's file, ask them in group chat first!

---

## 🚫 DO / DON'T

### ✅ DO:
- Pull before you start working
- Work on your assigned files
- Test before pushing
- Push small changes often (every 30-60 min)
- Tell team when you push

### 🚫 DON'T:
- Edit same file as someone else simultaneously
- Push without testing
- Wait days to push (conflicts pile up)
- Edit ui.R/server.R without asking team

---

## 🛠️ Common Tasks

### Kill stuck app:
```bash
pkill -9 Rscript
```

### Reinstall all packages:
```bash
Rscript install_packages.R
```

### Check what changed:
```bash
git status
git diff
```

### Undo your changes (careful!):
```bash
git checkout -- [file]     # Undoes changes to one file
```

---

## 🆘 When Things Break

1. **DON'T PANIC**
2. **DON'T PUSH** if app is broken
3. **Message team in chat**
4. **Jump on Zoom** and fix together

---

**That's it!** Pull → Edit → Test → Push → Tell team 🎉
