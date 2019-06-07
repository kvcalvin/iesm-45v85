# *************************************************
# * This script calculates the change in CO2
# * emissions due to coupling.
# *************************************************
print("********* Running 3-CO2-Analyze.R *******************")

source( "../Header.R" )

# Read Data
all_co2_data <- read.csv( "../3-analyze/0.all_co2_data.csv" )

# Calculate change due to coupling by region for the `avg_period` number of years centered on the `map_year`
min_year <- map_year - (avg_period/2) + 1
max_year <- map_year + (avg_period/2)
all_co2_data %>%
  filter(IAM == "GCAM", variant == "default") %>%
  select(-base_co2, -delta_co2) %>%
  filter(year >= min_year, year <= max_year) %>%
  group_by(scenario, feedbacks, region, unit) %>%
  summarize(value = mean(value)) %>%
  ungroup() %>%
  spread(feedbacks, value) %>%
  mutate(delta_co2 = YES - NO, pct_delta = 100 * delta_co2 / NO) %>%
  select(-YES, -NO) ->
  regional_co2_change

# Filter for world
all_co2_data %>% filter( region == "WORLD" ) -> global_co2_data

# Print all data to file
write.table( global_co2_data, "3.co2_summary.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( regional_co2_change, "3.regional_co2_change.csv", sep=",", col.names=T, row.names=F, append=F )
