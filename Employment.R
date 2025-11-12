library(readxl)
library(dplyr)
library(ggplot2)
library(maps)

# 1. Read your files
jobs <- read_excel("data/state/Employment/JobOpens.xlsx")
hires <- read_excel("data/state/Employment/Hires.xlsx")
quits <- read_excel("data/state/Employment/Quits.xlsx")

# 2. Merge all three datasets by state
merged_data <- jobs %>%
  full_join(hires, by = "State") %>%
  full_join(quits, by = "State")

# 3. Clean up state names
merged_data <- merged_data %>%
  mutate(State = tolower(State))

# 4. Rename the variable you want to map
merged_data <- merged_data %>%
  rename(job_open_rate_july2025 = `Job Open Rates -7/1/2025`)

# 5. Get map data
states_map <- map_data("state")

# 6. Merge map with your data
map_df <- states_map %>%
  left_join(merged_data, by = c("region" = "State"))

# 7. Plot the map
ggplot(map_df, aes(x = long, y = lat, group = group, fill = job_open_rate_july2025)) +
  geom_polygon(color = "white") +
  coord_fixed(1.3) +
  scale_fill_continuous(name = "Job Open Rate (%)",
                        low = "lightblue", high = "darkblue", na.value = "grey90") +
  theme_minimal() +
  labs(title = "Job Opening Rates by State – July 2025")