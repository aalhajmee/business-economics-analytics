# ===============================================================================
# Package Installation Script for Financial Health Dashboard
# ===============================================================================
# This script installs all required R packages for the Shiny dashboard.
# Run this once before first use, or anytime packages are missing.
#
# Usage: Rscript install_packages.R
# ===============================================================================

cat("\n")
cat("========================================================================\n")
cat("  Financial Health Dashboard - Package Installation\n")
cat("========================================================================\n")
cat("\n")

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# List of all required packages
required_packages <- c(
  # Core Shiny packages
  "shiny",
  "shinydashboard",
  "shinythemes",
  "shinyjs",
  
  # Data manipulation
  "tidyverse",  # Includes dplyr, tidyr, ggplot2, readr, and more
  "readxl",
  
  # Data visualization
  "plotly",
  
  # Data tables
  "DT",
  
  # Date/time handling
  "zoo",
  "lubridate",
  
  # Forecasting
  "forecast",
  
  # Machine learning (for loan calculator)
  "glmnet"
)

cat("Checking for missing packages...\n\n")

# Identify missing packages
installed <- installed.packages()[, "Package"]
missing <- required_packages[!required_packages %in% installed]

if (length(missing) == 0) {
  cat("✓ All required packages are already installed!\n\n")
  cat("Installed packages:\n")
  for (pkg in required_packages) {
    version <- packageVersion(pkg)
    cat(sprintf("  ✓ %-20s (version %s)\n", pkg, version))
  }
  cat("\n")
  cat("You're ready to run the dashboard!\n")
  cat("Run: Rscript run_app.R\n")
  cat("\n")
} else {
  cat(sprintf("Found %d missing package(s):\n", length(missing)))
  for (pkg in missing) {
    cat(sprintf("  ✗ %s\n", pkg))
  }
  cat("\n")
  
  cat("========================================================================\n")
  cat("Installing missing packages...\n")
  cat("========================================================================\n\n")
  
  # Install missing packages with progress
  for (pkg in missing) {
    cat(sprintf("Installing %s...", pkg))
    tryCatch({
      install.packages(pkg, quiet = TRUE)
      cat(" ✓ SUCCESS\n")
    }, error = function(e) {
      cat(" ✗ FAILED\n")
      cat(sprintf("  Error: %s\n", conditionMessage(e)))
    })
  }
  
  cat("\n")
  cat("========================================================================\n")
  cat("Installation Summary\n")
  cat("========================================================================\n\n")
  
  # Verify installation
  installed_after <- installed.packages()[, "Package"]
  still_missing <- required_packages[!required_packages %in% installed_after]
  
  if (length(still_missing) == 0) {
    cat("✓ All packages successfully installed!\n\n")
    cat("Installed packages:\n")
    for (pkg in required_packages) {
      version <- packageVersion(pkg)
      cat(sprintf("  ✓ %-20s (version %s)\n", pkg, version))
    }
    cat("\n")
    cat("========================================================================\n")
    cat("You're ready to run the dashboard!\n")
    cat("Run: Rscript run_app.R\n")
    cat("========================================================================\n\n")
  } else {
    cat("✗ Some packages failed to install:\n")
    for (pkg in still_missing) {
      cat(sprintf("  ✗ %s\n", pkg))
    }
    cat("\n")
    cat("Please install these packages manually:\n")
    cat(sprintf('  install.packages(c("%s"))\n', paste(still_missing, collapse = '", "')))
    cat("\n")
    quit(status = 1)
  }
}
