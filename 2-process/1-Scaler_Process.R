# *************************************************
# * This script processes the gcam yield inputs   *
# * into scalers that can be used for further     *
# * analysis and comparison                       *
# *************************************************
print("********* Running 1-Scaler_Process.R *******************")

source( "../Header.R" )

# Read Data
gcam_yield <- read.csv( "../1-data/gcam/yield.csv")

# Read Mappings
scen_map <- read.csv( "../1-data/mappings/scenarios.csv" )

# Tidy data
gcam_yield %>% 
  gather(year, yield, -scenario, -region, -sector, -subsector, -technology, -title, -Units) %>%
  mutate(year=as.numeric( substr( year, 2, 5 ) ), title=NULL, Units=NULL) %>%
  rename(gcam_scenario = scenario) %>%
  left_join(scen_map, by=c("gcam_scenario")) %>%
  select(-gcam_scenario) -> 
  gcam_yield_aez_data

# Back out scalers
gcam_yield_aez_data %>%
  select(-scen_name) %>%
  spread(feedbacks, yield) %>%
  mutate(scaler = YES / NO) %>%
  select(-YES, -NO) ->
  gcam_scaler_data

# Print data into csv for use in future scripts.
write.table( gcam_scaler_data, "1.gcam_scaler_data.csv", sep=",", col.names=T, row.names=F, append=F )
  
  