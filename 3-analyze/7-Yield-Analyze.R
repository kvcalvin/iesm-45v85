# *************************************************
# * This script combines % change in yield and % change 
# * in land into a single data frame for easier comparison
# * later.
# *************************************************
print("********* Running 7-Yield-Analyze.R *******************")

source( "../Header.R" )

# Read Data
gcam_yield_aez_cropland <- read.csv("../2-process/6.gcam_yield_cropland_AEZ.csv")

# Compute change in yield & land due to coupling for cropland
min_year <- map_year - (avg_period/2) + 1
max_year <- map_year + (avg_period/2)
gcam_yield_aez_cropland %>%
  filter(variant == "default", land > 1) %>%
  select(-scen_name) %>%
  filter(year >= min_year, year <= max_year) %>%
  group_by(region, AEZ, REF, scenario, feedbacks, variant, tax) %>%
  summarize(land = sum(land), prod=sum(prod)) %>%
  ungroup() %>%
  mutate(yield = prod / land) %>%
  gather(type, value, -region, -AEZ, -REF, -scenario, -feedbacks, -variant, -tax) %>%
  spread(feedbacks, value) %>%
  mutate(delta = (YES - NO), pct.delta = 100*(YES - NO)/NO) %>%
  na.omit() %>%
  select(-NO, -YES) ->
  TEMP

# We want to be able to compare % change in yield to % change in land AND absolute change in land
TEMP %>%
  filter(type == "yield") %>%
  select(-type, -delta) %>%
  rename(yield_pct.delta = pct.delta) %>%
  left_join(filter(TEMP, type=="land"), by=c("region", "AEZ", "REF", "scenario", "variant", "tax")) %>%
  rename(land_pct.delta = pct.delta, land_delta = delta) ->
  gcam_aez_cropland_coupling

# Print all data to file
write.table( gcam_aez_cropland_coupling, "7.gcam_aez_cropland_coupling.csv", sep=",", col.names=T, row.names=F, append=F )
