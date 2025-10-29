library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(zoo)
library(lubridate)
library(shinydashboard)

# CFHI module (reads cfhi_data/cfhi_master_2000_onward.csv)
source("R_Scripts/cfhi_feature_server.R")

shinyServer(function(input, output, session) {
  
  # ---- CFHI MODULE ----
  cfhi_feature_server(
    id = "cfhi",
    master_path = "cfhi_data/cfhi_master_2000_onward.csv"
  )
  
  # ---- OPTIONAL: Savings Guide or other outputs ----
  # If you keep additional server logic in a separate file, source it here
  # so it has access to input/output/session.
  if (file.exists("calculations.R")) {
    source("calculations.R", local = TRUE)
  }
  
  
})
