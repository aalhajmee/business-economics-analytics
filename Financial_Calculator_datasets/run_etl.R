library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(readr)

# Load environment variables
if(file.exists("../.env")) {
  env_vars <- readLines("../.env")
  env_vars <- env_vars[!grepl("^#", env_vars) & nchar(env_vars) > 0]
  for(line in env_vars) {
    parts <- strsplit(line, "=")[[1]]
    if(length(parts) == 2) {
      key <- trimws(parts[1])
      value <- trimws(parts[2])
      do.call(Sys.setenv, setNames(list(value), key))
    }
  }
  cat("✓ Loaded API keys from .env file\n\n")
}

CENSUS_API_KEY <- Sys.getenv("CENSUS_API_KEY")
BLS_API_KEY <- Sys.getenv("BLS_API_KEY")

cat("Census API Key:", substr(CENSUS_API_KEY, 1, 10), "...\n")
cat("BLS API Key:", substr(BLS_API_KEY, 1, 10), "...\n\n")

# ===== EXTRACT: Census Data =====
cat("=== Fetching Census Bureau Data ===\n")

# Median Income (Table B19013_001E) - 2023 ACS 5-Year
income_url <- paste0(
  "https://api.census.gov/data/2023/acs/acs5?",
  "get=NAME,B19013_001E&for=state:*&key=", CENSUS_API_KEY
)

cat("Fetching median income...\n")
income_response <- GET(income_url)
cat("Status:", status_code(income_response), "\n")

census_success <- FALSE

if(status_code(income_response) == 200) {
  
  content_text <- content(income_response, "text")
  
  # Check if response is JSON (not HTML error page)
  if(!grepl("^<html", content_text)) {
    
    income_data <- fromJSON(content_text)
    income_df <- as.data.frame(income_data[-1,], stringsAsFactors = FALSE)
    colnames(income_df) <- income_data[1,]
    
    # Poverty Rate (Table B17001) - 2023 ACS 5-Year
    poverty_url <- paste0(
      "https://api.census.gov/data/2023/acs/acs5?",
      "get=NAME,B17001_001E,B17001_002E&for=state:*&key=", CENSUS_API_KEY
    )
    
    cat("Fetching poverty data...\n")
    poverty_response <- GET(poverty_url)
    cat("Status:", status_code(poverty_response), "\n")
    
    poverty_data <- fromJSON(content(poverty_response, "text"))
    poverty_df <- as.data.frame(poverty_data[-1,], stringsAsFactors = FALSE)
    colnames(poverty_df) <- poverty_data[1,]
    
    # Combine Census data
    census_df <- income_df %>%
      left_join(poverty_df, by = c("NAME", "state")) %>%
      mutate(
        State = NAME,
        Median_Income = as.numeric(B19013_001E),
        Total_Pop = as.numeric(B17001_001E),
        Below_Poverty = as.numeric(B17001_002E),
        Poverty_Rate = round((Below_Poverty / Total_Pop) * 100, 1)
      ) %>%
      select(State, state, Median_Income, Poverty_Rate)
    
    cat("✓ Retrieved", nrow(census_df), "states from Census Bureau\n\n")
    census_success <- TRUE
    
  } else {
    cat("⚠ Census API returned HTML error page\n\n")
  }
  
} else {
  cat("⚠ Census API request failed with status:", status_code(income_response), "\n\n")
}

if(!census_success) {
  cat("Using fallback data from ACS 2023 published tables\n\n")
  
  # Fallback: Use published Census data
  census_df <- data.frame(
    State = c('Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 
              'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 
              'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 
              'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 
              'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 
              'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 
              'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 
              'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 
              'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 
              'West Virginia', 'Wisconsin', 'Wyoming'),
    state = sprintf("%02d", c(1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 15, 16, 17, 18, 19, 20, 
                              21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
                              35, 36, 37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 
                              50, 51, 53, 54, 55, 56)),
    Median_Income = c(59609, 86370, 72581, 56335, 91905, 87598, 90213, 79325, 
                      67106, 71355, 88005, 70214, 79253, 67173, 70571, 69747, 
                      60183, 57852, 68251, 98461, 96505, 68505, 84313, 52985, 
                      65920, 66341, 71722, 71646, 90845, 97126, 58722, 81386, 
                      66186, 73959, 66990, 61364, 76632, 73170, 81370, 63623, 
                      69457, 64035, 73035, 86833, 72431, 87249, 90955, 55217, 
                      72458, 72495),
    Poverty_Rate = c(15.7, 10.6, 13.5, 16.2, 12.3, 9.3, 9.4, 11.3, 12.5, 13.5, 
                     9.3, 11.2, 11.9, 11.9, 10.2, 11.4, 16.0, 18.6, 10.9, 9.0, 
                     9.4, 13.0, 8.9, 19.4, 12.8, 12.5, 9.9, 12.5, 7.2, 9.1, 
                     17.4, 13.6, 13.4, 10.7, 13.1, 15.2, 11.8, 11.8, 10.8, 14.6, 
                     11.0, 13.9, 13.9, 8.9, 10.4, 9.2, 9.5, 16.8, 10.3, 11.1),
    stringsAsFactors = FALSE
  )
}

# ===== EXTRACT: BLS Unemployment Data =====
cat("=== Fetching BLS Unemployment Data ===\n")

# State FIPS to abbreviation mapping
state_fips <- c(
  "01"="AL", "02"="AK", "04"="AZ", "05"="AR", "06"="CA", "08"="CO", "09"="CT", 
  "10"="DE", "12"="FL", "13"="GA", "15"="HI", "16"="ID", "17"="IL", "18"="IN", 
  "19"="IA", "20"="KS", "21"="KY", "22"="LA", "23"="ME", "24"="MD", "25"="MA", 
  "26"="MI", "27"="MN", "28"="MS", "29"="MO", "30"="MT", "31"="NE", "32"="NV", 
  "33"="NH", "34"="NJ", "35"="NM", "36"="NY", "37"="NC", "38"="ND", "39"="OH", 
  "40"="OK", "41"="OR", "42"="PA", "44"="RI", "45"="SC", "46"="SD", "47"="TN", 
  "48"="TX", "49"="UT", "50"="VT", "51"="VA", "53"="WA", "54"="WV", "55"="WI", 
  "56"="WY"
)

# Build series IDs for state unemployment (LASST + FIPS + 03 for unemployment rate)
series_ids <- paste0("LASST", names(state_fips), "0000000000003")

# BLS API v2 (can handle multiple series)
bls_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data/"

# Split into chunks of 25 (API limit per request with key)
chunk_size <- 25
chunks <- split(series_ids, ceiling(seq_along(series_ids)/chunk_size))

unemployment_list <- list()

for(i in seq_along(chunks)) {
  cat("Fetching chunk", i, "of", length(chunks), "...\n")
  
  payload <- list(
    seriesid = chunks[[i]],
    startyear = "2024",
    endyear = "2025",
    registrationkey = BLS_API_KEY
  )
  
  response <- POST(
    bls_url,
    body = toJSON(payload, auto_unbox = TRUE),
    content_type("application/json")
  )
  
  if(status_code(response) == 200) {
    result <- fromJSON(content(response, "text"))
    
    if(!is.null(result$status) && result$status == "REQUEST_SUCCEEDED") {
      series_df <- result$Results$series
      
      for(j in 1:nrow(series_df)) {
        series_id <- series_df$seriesID[j]
        series_data <- series_df$data[[j]]
        
        # Extract state FIPS from series ID (characters 6-7)
        fips <- substr(series_id, 6, 7)
        state_code <- state_fips[fips]
        
        # Get most recent value
        if(!is.null(series_data) && nrow(series_data) > 0) {
          latest <- series_data[1,]
          unemployment_list[[state_code]] <- as.numeric(latest$value)
        }
      }
    } else {
      cat("Warning:", ifelse(is.null(result$message), "Unknown error", result$message), "\n")
    }
  }
  
  Sys.sleep(0.5)  # Rate limiting
}

unemployment_df <- data.frame(
  State_Code = names(unemployment_list),
  Unemployment_Rate = unlist(unemployment_list),
  stringsAsFactors = FALSE
)

cat("✓ Retrieved unemployment data for", nrow(unemployment_df), "states\n\n")

# ===== MANUAL: Cost of Living =====
cat("=== Adding Cost of Living Index ===\n")

cost_of_living_df <- data.frame(
  State_Code = c('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 
                 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 
                 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 
                 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 
                 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'),
  Cost_of_Living_Index = c(88.0, 127.1, 102.2, 86.9, 151.7, 105.6, 116.1, 102.7, 
                           99.6, 89.2, 184.1, 98.6, 93.4, 90.3, 89.9, 87.0, 
                           92.3, 91.9, 115.0, 119.8, 131.6, 89.6, 94.1, 84.8, 
                           88.6, 100.7, 91.3, 104.9, 109.7, 114.4, 92.1, 125.1, 
                           94.2, 98.9, 91.7, 87.9, 113.1, 97.0, 110.6, 95.9, 
                           96.9, 88.7, 92.1, 101.9, 117.9, 103.0, 118.7, 87.5, 
                           95.4, 93.3),
  stringsAsFactors = FALSE
)

cat("✓ Added cost of living for 50 states\n\n")

# ===== TRANSFORM: Add State Codes =====
cat("=== Transforming Data ===\n")

# Add state codes to census data
state_lookup <- data.frame(
  state = sprintf("%02d", 1:56),
  State_Code = c('AL', 'AK', '', 'AZ', 'AR', 'CA', '', 'CO', 'CT', 'DE', '', 
                 'FL', 'GA', '', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 
                 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 
                 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 
                 'PA', '', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', '', 
                 'WA', 'WV', 'WI', 'WY'),
  stringsAsFactors = FALSE
) %>% filter(State_Code != '')

census_df <- census_df %>%
  left_join(state_lookup, by = "state") %>%
  select(State, State_Code, Median_Income, Poverty_Rate)

# ===== MERGE: Combine All Sources =====
final_df <- census_df %>%
  left_join(unemployment_df, by = "State_Code") %>%
  left_join(cost_of_living_df, by = "State_Code") %>%
  select(State, State_Code, Median_Income, Unemployment_Rate, 
         Poverty_Rate, Cost_of_Living_Index) %>%
  arrange(State)

cat("✓ Merged all data sources\n")
cat("  Total states:", nrow(final_df), "\n")
cat("  Missing values:", sum(is.na(final_df)), "\n\n")

# ===== LOAD: Save to CSV =====
cat("=== Saving Data ===\n")
output_file <- "State_Data_Demographics.csv"
write_csv(final_df, output_file)

cat("✓ Data saved to:", output_file, "\n")
cat("✓ File size:", file.size(output_file), "bytes\n\n")

# ===== PREVIEW =====
cat("=== Data Preview ===\n")
print(head(final_df, 10))

cat("\n=== Summary Statistics ===\n")
print(summary(final_df[, c("Median_Income", "Unemployment_Rate", 
                           "Poverty_Rate", "Cost_of_Living_Index")]))

cat("\n✓ ETL Complete!\n")
