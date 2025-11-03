#!/bin/bash
# ===============================================================================
# Financial Health Dashboard - Quick Start Script
# ===============================================================================
# This script provides an easy way to set up and run the dashboard
# 
# Usage: ./start_dashboard.sh [install|run]
#   install - Install all required packages
#   run     - Run the dashboard (default)
# ===============================================================================

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print colored output
print_header() {
    echo -e "${BLUE}========================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if R is installed
check_r_installed() {
    if ! command -v Rscript &> /dev/null; then
        print_error "R is not installed or not in PATH"
        echo ""
        echo "Please install R from: https://www.r-project.org/"
        echo ""
        exit 1
    fi
    R_VERSION=$(Rscript --version 2>&1 | head -n 1)
    print_success "R is installed: $R_VERSION"
}

# Main script
main() {
    clear
    print_header "Financial Health Dashboard"
    echo ""
    
    # Check R installation
    check_r_installed
    echo ""
    
    # Determine action
    ACTION=${1:-run}
    
    case $ACTION in
        install)
            print_header "Installing Required Packages"
            echo ""
            Rscript install_packages.R
            ;;
        run)
            print_header "Starting Dashboard"
            echo ""
            Rscript run_app.R
            ;;
        *)
            print_error "Unknown action: $ACTION"
            echo ""
            echo "Usage: $0 [install|run]"
            echo "  install - Install all required packages"
            echo "  run     - Run the dashboard (default)"
            echo ""
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
