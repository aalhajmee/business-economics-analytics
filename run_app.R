# ===============================================================================
# Financial Health Dashboard - Application Runner
# ===============================================================================
# This script checks for required packages and runs the Shiny dashboard.
# It will automatically prompt to install missing packages if needed.
#
# Usage: Rscript run_app.R
# Or from R console: source("run_app.R")
# ===============================================================================

cat("\n")
cat("========================================================================\n")
cat("  Financial Health Dashboard\n")
cat("  by Ammar Alhajmee, Bemnet Ali, and Colin Bridges\n")
cat("========================================================================\n")
cat("\n")

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# List of all required packages
required_packages <- c(
  "shiny", "shinydashboard", "shinythemes", "shinyjs",
  "dplyr", "tidyr", "readr", "readxl",
  "ggplot2", "plotly", "DT",
  "zoo", "lubridate", "forecast", "glmnet"
)

cat("Checking package dependencies...\n")

# Check for missing packages
installed <- installed.packages()[, "Package"]
missing <- required_packages[!required_packages %in% installed]

if (length(missing) > 0) {
  cat("\n")
  cat("⚠️  WARNING: Missing required packages!\n\n")
  cat(sprintf("The following %d package(s) are not installed:\n", length(missing)))
  for (pkg in missing) {
    cat(sprintf("  ✗ %s\n", pkg))
  }
  cat("\n")
  cat("========================================================================\n")
  cat("Would you like to install them now? (Recommended)\n")
  cat("========================================================================\n")
  cat("\n")
  cat("Option 1: Run the automatic installer:\n")
  cat("  Rscript install_packages.R\n")
  cat("\n")
  cat("Option 2: Install manually in R:\n")
  cat(sprintf('  install.packages(c("%s"))\n', paste(missing, collapse = '", "')))
  cat("\n")
  cat("Then run this script again.\n")
  cat("\n")
  
  # Ask user if they want to auto-install (only works in interactive mode)
  if (interactive()) {
    response <- readline(prompt = "Auto-install now? (y/n): ")
    if (tolower(trimws(response)) %in% c("y", "yes")) {
      cat("\nInstalling missing packages...\n")
      install.packages(missing)
      cat("\nPackages installed! Starting app...\n\n")
    } else {
      cat("\nPlease install the required packages and try again.\n\n")
      quit(status = 1)
    }
  } else {
    quit(status = 1)
  }
} else {
  cat("✓ All required packages are installed!\n\n")
}

# Verify data files exist
cat("Checking data files...\n")
required_files <- c(
  "cfhi_data/cfhi_master_2000_onward.csv",
  "Financial_Calculator_datasets/loan_approval.xlsx",
  "Financial_Calculator_datasets/State_Data.xlsx"
)

missing_files <- character(0)
for (file in required_files) {
  if (file.exists(file)) {
    cat(sprintf("  ✓ %s\n", file))
  } else {
    cat(sprintf("  ✗ %s (MISSING)\n", file))
    missing_files <- c(missing_files, file)
  }
}

if (length(missing_files) > 0) {
  cat("\n")
  cat("⚠️  WARNING: Missing data files!\n")
  cat("The app may not function correctly.\n\n")
} else {
  cat("✓ All required data files found!\n\n")
}

cat("========================================================================\n")
cat("Starting Shiny Dashboard...\n")
cat("========================================================================\n")
cat("\n")
cat("The app will open in your default web browser.\n")
cat("If it doesn't open automatically, navigate to the URL shown below.\n")
cat("\n")
cat("Press Ctrl+C (or Cmd+C on Mac) to stop the server.\n")
cat("\n")

# Load shiny and run the app
library(shiny)

# Run the app
tryCatch({
  runApp(
    appDir = ".",
    port = 3838,
    host = "127.0.0.1",
    launch.browser = TRUE
  )
}, error = function(e) {
  cat("\n")
  cat("========================================================================\n")
  cat("⚠️  ERROR: Failed to start the app\n")
  cat("========================================================================\n")
  cat("\n")
  cat("Error message:\n")
  cat(sprintf("  %s\n", conditionMessage(e)))
  cat("\n")
  cat("Common solutions:\n")
  cat("  1. Make sure ui.R and server.R are in the current directory\n")
  cat("  2. Check that all data files are present\n")
  cat("  3. Run install_packages.R to ensure all packages are installed\n")
  cat("  4. Try closing other instances of R/RStudio using port 3838\n")
  cat("\n")
  quit(status = 1)
})
