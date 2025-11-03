# 🤝 Collaboration Guide for Business Economics Analytics Dashboard

## Team: Ammar Alhajmee, Bemnet Ali, Colin Bridges

---

## 📋 Table of Contents
1. [Working Structure](#working-structure)
2. [Daily Workflow](#daily-workflow)
3. [File Ownership & Responsibility](#file-ownership--responsibility)
4. [Avoiding Merge Conflicts](#avoiding-merge-conflicts)
5. [Library Management](#library-management)
6. [Communication Protocol](#communication-protocol)
7. [Troubleshooting](#troubleshooting)

---

## 🏗️ Working Structure

### Branch Strategy (Simple for 3-Person Team)

**Option 1: Feature Branches (Recommended)**
```bash
main branch          # Always working, production-ready code
├── ammar-feature    # Ammar's current work
├── bemnet-feature   # Bemnet's current work
└── colin-feature    # Colin's current work
```

**Option 2: Person Branches (Alternative)**
```bash
main branch          # Always working, production-ready code
├── ammar-dev        # All Ammar's work
├── bemnet-dev       # All Bemnet's work
└── colin-dev        # All Colin's work
```

**We recommend Option 1** - create a new branch for each feature/task.

---

## 📅 Daily Workflow

### 1️⃣ **Start of Work Session**

```bash
# ALWAYS start with these commands
cd /Users/[YOUR_USERNAME]/Desktop/DevOps/business-economics-analytics

# Get latest changes from everyone
git checkout main
git pull origin main

# Create your feature branch (or switch to existing)
git checkout -b [yourname-feature-description]
# Example: git checkout -b ammar-add-inflation-chart

# Run the app (packages auto-install)
Rscript -e "shiny::runApp()"
```

### 2️⃣ **During Work Session**

```bash
# Save your work frequently (every 30-60 minutes)
git add [files-you-changed]
git commit -m "Brief description of what you did"

# Example:
git add ui.R homepage.R
git commit -m "Add welcome message to homepage"
```

### 3️⃣ **End of Work Session (Push Your Changes)**

```bash
# Make sure app still works before pushing
pkill -9 Rscript 2>/dev/null
Rscript -e "shiny::runApp()"
# Test in browser at http://127.0.0.1:3838
# Ctrl+C to stop

# Push your branch to GitHub
git push origin [yourname-feature-description]
```

### 4️⃣ **Merging to Main (When Feature is Complete)**

**DO THIS TOGETHER on Zoom/Slack!**

```bash
# Update your branch with latest main
git checkout main
git pull origin main
git checkout [yourname-feature-description]
git merge main

# If merge conflicts appear, fix them together
# Then test the app
Rscript -e "shiny::runApp()"

# If everything works, merge to main
git checkout main
git merge [yourname-feature-description]
git push origin main

# Tell teammates: "I just pushed to main, pull before you work!"
```

---

## 📂 File Ownership & Responsibility

To minimize conflicts, assign **primary ownership** to files:

### Core Files (Requires Team Discussion Before Editing)
| File | Primary Owner | Notes |
|------|---------------|-------|
| `ui.R` | **Team Decision** | Coordinate in group chat before editing |
| `server.R` | **Team Decision** | Coordinate in group chat before editing |
| `README.md` | Ammar | Others can suggest changes via chat |

### Feature Files (Individual Ownership)
| File Pattern | Owner | Safe to Edit? |
|--------------|-------|---------------|
| `homepage.R` | Bemnet | ✅ Bemnet can edit freely |
| `cfhi_*` files | Colin | ✅ Colin can edit freely |
| `state_*` files | Ammar | ✅ Ammar can edit freely |
| `loans.R` | Colin | ✅ Colin can edit freely |
| `savingsguide.R` | Bemnet | ✅ Bemnet can edit freely |
| `calculations.R` | Ammar | ✅ Ammar can edit freely |

### Golden Rule
**If you need to edit someone else's file:**
1. Message them first: "Hey, I need to update [file]. Working on it now?"
2. Wait for confirmation
3. Make your changes
4. Commit and push quickly
5. Tell them: "Done with [file], you can work on it now"

---

## 🚫 Avoiding Merge Conflicts

### Rule #1: Pull Before You Start
```bash
# ALWAYS do this before starting work
git checkout main
git pull origin main
git checkout -b your-new-branch
```

### Rule #2: Work on Different Files
**Bad:**
- Ammar edits `ui.R` lines 50-60
- Colin edits `ui.R` lines 55-65
- ❌ **MERGE CONFLICT!**

**Good:**
- Ammar creates new file `ammar_feature.R`
- Colin edits `loans.R`
- Bemnet edits `homepage.R`
- ✅ **No conflicts!**

### Rule #3: Commit Often, Push Daily
```bash
# Don't wait days to push - conflicts grow over time!
git add .
git commit -m "Work in progress on [feature]"
git push origin [your-branch]
```

### Rule #4: If You Must Edit Shared Files (ui.R, server.R)

**Announce in Group Chat:**
```
"🚨 I'm editing ui.R for the next 30 mins to add the new tab.
   Please don't touch ui.R until I say I'm done!"
```

**Work Fast:**
- Make your change
- Test it works
- Commit and push within 30 minutes
- Announce: "✅ Done with ui.R"

### Rule #5: Small, Focused Changes
**Bad:**
```bash
git commit -m "Fixed everything"
# Changed: ui.R, server.R, 5 other files, added new data
```

**Good:**
```bash
git commit -m "Add unemployment chart to state analysis tab"
# Changed: state_analysis_tab.R, state_analysis_server.R
```

---

## 📦 Library Management

### ✅ Packages Install Automatically!

The app now handles this for you. But understand what happens:

**When you run the app:**
```r
# ui.R automatically checks for these 12 packages:
required_packages <- c(
  "shiny", "shinydashboard", "shinythemes", "shinyjs",
  "tidyverse", "readxl", "plotly", "DT", "zoo",
  "lubridate", "forecast", "glmnet"
)

# If any are missing, they install automatically
```

### If You Need to Add a NEW Package

**Process:**
1. Add package to your code
2. Update `ui.R` required_packages list
3. Update `install_packages.R` list
4. Test on your machine
5. Commit with clear message
6. Tell team: "I added [package], pull and restart your app"

**Example:**
```bash
# You want to add 'leaflet' package for maps

# 1. Edit ui.R line 8
required_packages <- c("shiny", "shinydashboard", ..., "glmnet", "leaflet")

# 2. Edit install_packages.R line 19-30 (add "leaflet")

# 3. Test
Rscript -e "shiny::runApp()"

# 4. Commit
git add ui.R install_packages.R [your-feature-file.R]
git commit -m "Add leaflet package for interactive state maps"
git push origin your-branch

# 5. Message team
"📦 Added 'leaflet' package. Pull and restart your app to install it automatically!"
```

---

## 💬 Communication Protocol

### Use Group Chat (Slack/Discord/iMessage) for:

**🚨 Critical Announcements**
```
"🚨 EDITING ui.R for next 30 mins - don't touch it!"
"✅ Done with ui.R - all clear"
"🚫 App is broken on main branch - fixing now, don't pull"
"✅ Fixed - safe to pull now"
```

**📦 Package Updates**
```
"📦 Added 'ggExtra' package - pull and restart app"
```

**🔀 Merge to Main**
```
"🔀 Merged my-feature to main - PULL BEFORE YOU WORK"
```

**❓ Questions**
```
"❓ Who's working on the loan calculator?"
"❓ Can I edit state_analysis_server.R or is someone using it?"
```

### Daily Stand-up (5 minutes, on Slack or Zoom)

**Each person says:**
1. What I worked on yesterday
2. What I'm working on today
3. What files I'll be editing
4. Any blockers/issues

**Example:**
```
Ammar: "Yesterday added inflation tab. Today working on state_analysis_tab.R
        to add population chart. Need help with plotly syntax."
        
Bemnet: "Yesterday fixed homepage layout. Today adding savings calculator
         in savingsguide.R. No blockers."
         
Colin: "Yesterday worked on CFHI forecast. Today improving loans.R 
        approval algorithm. No blockers."
```

---

## 🔧 Troubleshooting

### "Address Already in Use" (Port 3838 Error)

```bash
# Kill existing app processes
pkill -9 Rscript 2>/dev/null
sleep 2

# Restart app
Rscript -e "shiny::runApp()"
```

### "Package Not Found" Error (Even After Auto-Install)

```bash
# Manually install all packages
Rscript install_packages.R

# Then restart app
Rscript -e "shiny::runApp()"
```

### Merge Conflict in ui.R or server.R

**DON'T PANIC! Do this together on Zoom:**

```bash
# 1. Open the conflicted file
code ui.R  # or nano ui.R

# 2. Look for conflict markers
<<<<<<< HEAD
your code here
=======
their code here
>>>>>>> branch-name

# 3. Decide together which to keep or merge both
# 4. Remove the <<<<<<, =======, >>>>>>> markers
# 5. Test the app
Rscript -e "shiny::runApp()"

# 6. If it works, commit
git add ui.R
git commit -m "Resolve merge conflict in ui.R"
git push origin main
```

### "Could Not Find Function" Error

**Cause:** Someone added code using a package that's not loaded

**Fix:**
```bash
# 1. Find which package has the function (Google it)
# 2. Add library([package]) to ui.R or server.R
# 3. Add package to required_packages in ui.R
# 4. Commit and push
# 5. Tell team to pull
```

### Git Says "You Have Uncommitted Changes"

```bash
# Option 1: Save your work
git add .
git commit -m "WIP: saving my changes"

# Option 2: Temporarily stash your work
git stash
git pull origin main
git stash pop

# Option 3: Discard your changes (CAREFUL!)
git checkout -- .
```

---

## ✅ Best Practices Checklist

Before you push code, check ALL of these:

- [ ] App runs without errors (`Rscript -e "shiny::runApp()"`)
- [ ] All tabs load correctly in browser
- [ ] No console errors in R terminal
- [ ] Committed with descriptive message
- [ ] Pulled latest main before merging
- [ ] Told team in group chat about your changes
- [ ] Updated COLLABORATION_GUIDE.md if you changed workflow

---

## 🎯 Summary: The Golden Workflow

```bash
# EVERY TIME you work:

1. git checkout main && git pull origin main
2. git checkout -b yourname-feature
3. [Make your changes to YOUR files]
4. Rscript -e "shiny::runApp()"  # Test it works
5. git add [your-files]
6. git commit -m "Clear description"
7. git push origin yourname-feature
8. [When done] Merge to main WITH THE TEAM
9. Tell team: "Merged to main - PULL!"
```

---

## 📞 Emergency Contact

If something breaks and you can't fix it:

1. **Don't push broken code to main**
2. **Message the team immediately**
3. **Share your screen on Zoom**
4. **Fix it together**

Remember: **Communication prevents conflicts** 🚀

---

*Last updated: November 3, 2025*
*Team: Ammar Alhajmee, Bemnet Ali, Colin Bridges*
