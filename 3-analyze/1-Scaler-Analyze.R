# *************************************************
# * This script calculates average scalers for 
# * crops and forests, such that these can be mapped.
# *************************************************
print("********* Running 1-Scaler-Analyze.R *******************")

source( "../Header.R" )

# Read Data
gcam_scaler_aez_cropland <- read.csv("../2-process/1.gcam_scaler_data.csv")

# Separate AEZ and remove non-crops
gcam_scaler_aez_cropland %>%
  filter(sector != "UnmanagedLand") %>%
  separate(technology, into=c("crop", "AEZ"), sep="AEZ") ->
  gcam_scaler_aez_cropland

# Calculate cropland scaler (note scalers for individual crops are identical, we use averages because no single crop exists in all regions)
gcam_scaler_aez_cropland %>%
  filter(crop == "Forest") ->
  gcam_scaler_forest

gcam_scaler_aez_cropland %>%
  filter(crop %!in% c("Forest", "Pasture")) %>%
  na.omit() %>%
  group_by(region, AEZ, year, REF, scenario, variant, tax) %>%
  summarize(scaler = mean(scaler)) %>%
  ungroup() ->
  gcam_scaler_crops
  
# Compute average for a period centered around `map_year`
min_year <- map_year - (avg_period/2) + 1
max_year <- map_year + (avg_period/2)
gcam_scaler_forest %>%
  filter(year >= min_year, year <= max_year) %>%
  group_by(region, AEZ, REF, scenario, variant, tax) %>%
  summarize(scaler = mean(scaler)) %>%
  ungroup() ->
  gcam_scaler_forest

gcam_scaler_crops %>%
  filter(year >= min_year, year <= max_year) %>%
  group_by(region, AEZ, REF, scenario, variant, tax) %>%
  summarize(scaler = mean(scaler)) %>%
  ungroup() ->
  gcam_scaler_crops

# Print all data to file
write.table( gcam_scaler_crops, "1.gcam_scaler_crops.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( gcam_scaler_forest, "1.gcam_scaler_forest.csv", sep=",", col.names=T, row.names=F, append=F )
