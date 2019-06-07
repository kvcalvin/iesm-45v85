# *************************************************
# * This script determines which land type increases
# * the most when cropland declines (or expands less)
# * due to coupling.
# *************************************************
print("********* Running 5-Land-AEZ-Compare.R *******************")

source( "../Header.R" )

# Read Data
gcam_land_data <- read.csv( "../2-process/2.gcam_land_aez_data.csv" )

#Step 1: Calculate difference between coupled & uncoupled
land_coupling <- subset( gcam_land_data, scen_name %in% c( "RCP45_Coupled", "RCP85_Coupled" ) )
land_coupling$ref_land <- gcam_land_data$land[ match( vecpaste( land_coupling[ c( "region", "AEZ", "category", "ref_scen" )] ),
                                                              vecpaste( gcam_land_data[ c( "region", "AEZ", "category", "scen_name" )]))]
land_coupling$delta_land <- land_coupling$land - land_coupling$ref_land
land_coupling$land <- NULL
land_coupling$ref_land <- NULL

#Step 2: Determine which land type increases the most when cropland decreases
land_coupling %>%
  mutate(category = sub(" ", ".", category)) %>%
  mutate(category = sub("-", ".", category)) %>%
  spread(category, delta_land) %>%
  mutate(max_value = pmax(Bioenergy, Commercial.Forest, Grassland, Non.commercial.Forest, Pasture, Shrubland)) %>%
  mutate(max_cat = if_else(Non.Energy.Crops >= 0, "Non-Energy Crops", "temp")) %>%
  mutate(max_cat = if_else(Non.Energy.Crops < 0 & Bioenergy == max_value, "Bioenergy", max_cat)) %>%
  mutate(max_cat = if_else(Non.Energy.Crops < 0 & Commercial.Forest == max_value, "Commercial Forest", max_cat)) %>%
  mutate(max_cat = if_else(Non.Energy.Crops < 0 & Grassland == max_value, "Grassland", max_cat)) %>%
  mutate(max_cat = if_else(Non.Energy.Crops < 0 & Non.commercial.Forest == max_value, "Non-commercial Forest", max_cat)) %>%
  mutate(max_cat = if_else(Non.Energy.Crops < 0 & Pasture == max_value, "Pasture", max_cat)) %>%
  mutate(max_cat = if_else(Non.Energy.Crops < 0 & Shrubland == max_value, "Shrubland", max_cat)) %>%
  select(region, AEZ, scen_name, max_cat) ->
  land_coupling_type

# Print all data to file
write.table( land_coupling_type, "5.land_coupling_type.csv", sep=",", col.names=T, row.names=F, append=F )
