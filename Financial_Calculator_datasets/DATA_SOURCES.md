# State Economic Data - Sources and Documentation

## Overview
This directory contains state-level economic and demographic data used for geographic analysis in the Financial Health Dashboard.

## Data Files

### State_Data_Demographics.csv
**Last Updated:** October 27, 2025  
**States Covered:** All 50 U.S. States  
**Download Script:** `download_state_data.py`

## Data Sources

### 1. Median Household Income
- **Source:** U.S. Census Bureau
- **Dataset:** American Community Survey (ACS) 5-Year Estimates (2019-2023)
- **Table:** S1903 - Median Income in the Past 12 Months
- **URL:** https://data.census.gov/
- **License:** Public Domain (U.S. Government Work)
- **Coverage:** All 50 states
- **Notes:** Values in current dollars, not inflation-adjusted

### 2. Poverty Rate
- **Source:** U.S. Census Bureau
- **Dataset:** American Community Survey (ACS) 5-Year Estimates (2019-2023)
- **Table:** S1701 - Poverty Status in the Past 12 Months
- **URL:** https://data.census.gov/
- **License:** Public Domain (U.S. Government Work)
- **Coverage:** All 50 states
- **Notes:** Percentage of population below federal poverty line

### 3. Unemployment Rate
- **Source:** Bureau of Labor Statistics (BLS)
- **Program:** Local Area Unemployment Statistics (LAUS)
- **Reference Period:** October 2025
- **URL:** https://www.bls.gov/lau/
- **Direct Data:** https://www.bls.gov/web/laus/laumstrk.htm
- **License:** Public Domain (U.S. Government Work)
- **Coverage:** All 50 states
- **Notes:** Seasonally adjusted rates

### 4. Cost of Living Index
- **Source:** Missouri Economic Research and Information Center (MERIC)
- **Based on:** Council for Community and Economic Research (C2ER) Cost of Living Index
- **URL:** https://meric.mo.gov/data/cost-living-data-series
- **Coverage:** All 50 states
- **Notes:** Composite index where 100 = U.S. average
  - Index includes: grocery, housing, utilities, transportation, health care, and miscellaneous goods/services
  - Values above 100 indicate higher than average cost of living
  - Values below 100 indicate lower than average cost of living

## How to Update Data

### Automated Update (Recommended)
```bash
cd Financial_Calculator_datasets
python3 download_state_data.py
```

### Manual Update from Census Bureau
1. Visit https://data.census.gov/
2. Search for "S1903" (Median Income) and "S1701" (Poverty Status)
3. Select "State" geography
4. Download data for all states
5. Update values in `download_state_data.py`

### Manual Update from BLS
1. Visit https://www.bls.gov/web/laus/laumstrk.htm
2. Download latest state unemployment rates (seasonally adjusted)
3. Update values in `download_state_data.py`

### Manual Update for Cost of Living
1. Visit https://meric.mo.gov/data/cost-living-data-series
2. Download latest quarterly Cost of Living Index
3. Update values in `download_state_data.py`

## Data Dictionary

| Column | Type | Description | Range | Source |
|--------|------|-------------|-------|--------|
| State | String | Full state name | 50 states | - |
| State_Code | String | Two-letter state abbreviation | AL-WY | - |
| Median_Income | Integer | Median household income in dollars | $52,985 - $98,461 | Census ACS |
| Poverty_Rate | Float | % of population below poverty line | 7.2% - 19.4% | Census ACS |
| Unemployment_Rate | Float | % of labor force unemployed | 2.0% - 5.1% | BLS LAUS |
| Cost_of_Living_Index | Float | Relative cost of living (100 = average) | 84.8 - 184.1 | MERIC/C2ER |

## Data Quality Notes

- **Census ACS Data:** 5-year estimates provide more reliable data for smaller geographies but represent averages over the period
- **BLS Unemployment:** Monthly data is subject to revision; seasonally adjusted rates smooth out seasonal employment patterns
- **Cost of Living:** Composite index may not reflect individual household experiences; regional variation exists within states

## License and Attribution

All data sources are from U.S. government agencies and are in the public domain. No copyright restrictions apply.

**Recommended Citation:**
```
State economic data compiled from:
- U.S. Census Bureau, American Community Survey 5-Year Estimates (2019-2023)
- Bureau of Labor Statistics, Local Area Unemployment Statistics (October 2025)
- Missouri Economic Research and Information Center, Cost of Living Data Series
```

## Contact

For questions about data sources or methodology, refer to:
- Census Bureau: https://www.census.gov/programs-surveys/acs/guidance.html
- BLS: https://www.bls.gov/bls/contact.htm
- MERIC: https://meric.mo.gov/contact
