# *************************************************
# * This script processes the gcam yield data     *
# * into something usable for further analysis    *
# * and comparison                                *
# *************************************************
print("********* Running 6-Yield-Process.R *******************")

source( "../Header.R" )

# Read Data
gcam_land <- read.csv( "../1-data/gcam/land.csv")
gcam_prod <- read.csv("../1-data/gcam/prod.csv")

# Read Mappings
scen_map <- read.csv( "../1-data/mappings/scenarios.csv" )
land_map <- read.csv( "../1-data/mappings/lty.csv" )

# Tidy data
gcam_land %>% 
  gather(year, land, -scenario, -region, -land.allocation, -title, -Units) %>%
  mutate(year=as.numeric( substr( year, 2, 5 ) ), title=NULL, Units=NULL) %>%
  rename(gcam_scenario = scenario) %>%
  left_join(scen_map, by=c("gcam_scenario")) %>%
  select(-gcam_scenario) -> 
  gcam_land_aez_data

gcam_prod %>% 
  filter(output == sector) %>%
  gather(year, prod, -scenario, -region, -sector, -subsector, -output, -technology, -title, -Units) %>%
  mutate(year=as.numeric( substr( year, 2, 5 ) ), title=NULL, Units=NULL) %>%
  rename(gcam_scenario = scenario) %>%
  left_join(scen_map, by=c("gcam_scenario")) %>%
  select(-gcam_scenario, -subsector, -sector) ->  
  gcam_prod_aez_data

# Join data frames & calculate yield
gcam_land_aez_data %>%
  left_join(gcam_prod_aez_data, by=c("region", "year", "scen_name", "REF", "scenario", "feedbacks", "variant", "tax", "land.allocation" = "technology")) %>%
  mutate(yield = if_else(land == 0, 0, prod / land)) %>%
  na.omit() ->
  gcam_yield_aez

# Aggregate to cropland (not sure this would make sense for anything else)
gcam_yield_aez %>%
  left_join(land_map, by=c("land.allocation" = "gcam_lty")) %>%
  filter(agg_lty == "Non-Energy Crops") %>%
  separate(land.allocation, into=c("crop", "AEZ"), sep="AEZ") %>%
  group_by(region, year, AEZ, scen_name, REF, scenario, feedbacks, variant, tax) %>%
  summarize(land = sum(land), prod=sum(prod)) %>%
  mutate(yield = if_else(land == 0, 0, prod / land)) ->
  gcam_yield_cropland_AEZ

# Print data into csv for use in future scripts.
write.table( gcam_yield_aez, "6.gcam_yield_aez.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( gcam_yield_cropland_AEZ, "6.gcam_yield_cropland_AEZ.csv", sep=",", col.names=T, row.names=F, append=F )
  
  