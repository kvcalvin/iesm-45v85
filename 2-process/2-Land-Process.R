# *************************************************
# * This script processes the gcam land data      *
# * into something usable for further analysis    *
# * and comparison                                *
# *************************************************
print("********* Running 2-Land-Process.R *******************")

source( "../Header.R" )

# Read Data
gcam_land <- read.csv( "../1-data/gcam/land.csv")

# Read Mappings
scen_map <- read.csv( "../1-data/mappings/scenarios.csv" )
land_map <- read.csv( "../1-data/mappings/lty.csv" )

# Reformat Data and aggregate to category & AEZ
gcam_land$category <- land_map$agg_lty[ match( gcam_land$land.allocation, land_map$gcam_lty ) ]
gcam_land %>% separate( land.allocation, into=c( "type", "AEZ"), sep="AEZ" ) -> gcam_land
gcam_land$type <- NULL
gcam_land$land.allocation <- NULL
gcam_land %>% gather( variable, value, -scenario, -region, -category, -AEZ, -title, -Units ) %>%
                mutate( year=as.numeric( substr( variable, 2, 5 ) ), variable=NULL, title=NULL, Units=NULL ) %>%
                group_by( scenario, region, AEZ, category, year ) %>%
                summarize( land=sum( value ) ) -> gcam_land_aez_data

# Now aggregate to region
gcam_land_aez_data %>%  
  group_by( scenario, region, category, year ) %>%
  summarize( land=sum( land ) ) %>%
  ungroup() -> 
  gcam_land_data

# Add world region
gcam_land_data %>% 
  group_by( scenario, category, year ) %>%
  summarize( land=sum( land ) ) %>%
  ungroup() %>%
  mutate( region="WORLD" ) -> 
  TEMP
gcam_land_data <- rbind( gcam_land_data, TEMP )

# Add total cropland category
gcam_land_data %>% 
  filter( category %in% c( "Bioenergy", "Non-Energy Crops" ) ) %>%
  group_by( scenario, region, year ) %>%
  summarize( land=sum( land ) ) %>%
  ungroup() %>%
  mutate( category="Cropland" ) -> 
  TEMP
gcam_land_data <- rbind( gcam_land_data, TEMP )

# Map in scenario names and identifiers
names( gcam_land_data )[ names( gcam_land_data ) == "scenario" ] <- "id"
gcam_land_data$scen_name <- scen_map$scen_name[ match( gcam_land_data$id, scen_map$gcam_scenario ) ]
gcam_land_data$ref_scen <- scen_map$REF[ match( gcam_land_data$id, scen_map$gcam_scenario ) ]
gcam_land_data$feedbacks <- scen_map$feedbacks[ match( gcam_land_data$id, scen_map$gcam_scenario ) ]
gcam_land_data$variant <- scen_map$variant[ match( gcam_land_data$id, scen_map$gcam_scenario ) ]
gcam_land_data$tax <- scen_map$tax[ match( gcam_land_data$id, scen_map$gcam_scenario ) ]
gcam_land_data$id <- NULL

names( gcam_land_aez_data )[ names( gcam_land_aez_data ) == "scenario" ] <- "id"
gcam_land_aez_data$scen_name <- scen_map$scen_name[ match( gcam_land_aez_data$id, scen_map$gcam_scenario ) ]
gcam_land_aez_data$ref_scen <- scen_map$REF[ match( gcam_land_aez_data$id, scen_map$gcam_scenario ) ]
gcam_land_aez_data$feedbacks <- scen_map$feedbacks[ match( gcam_land_aez_data$id, scen_map$gcam_scenario ) ]
gcam_land_aez_data$variant <- scen_map$variant[ match( gcam_land_aez_data$id, scen_map$gcam_scenario ) ]
gcam_land_aez_data$tax <- scen_map$tax[ match( gcam_land_aez_data$id, scen_map$gcam_scenario ) ]
gcam_land_aez_data$id <- NULL

# Convert to million km2
gcam_land_data$land <- gcam_land_data$land / 1e3 
gcam_land_aez_data$land <- gcam_land_aez_data$land / 1e3 

# Average the aez-level data to get a period of `avg_period` years, centered on the `map_year`, as this is what we plot
min_year <- map_year - (avg_period/2) + 1
max_year <- map_year + (avg_period/2)
gcam_land_aez_data %>% 
  ungroup() %>%
  filter(year >= min_year, year <= max_year) %>%
  group_by(region, AEZ, category, scen_name, ref_scen, feedbacks, variant, tax) %>%
  summarize(land = mean(land)) %>%
  ungroup() ->
  gcam_land_aez_data

# Print data into csv for use in future scripts.
write.table( gcam_land_aez_data, "2.gcam_land_aez_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( gcam_land_data, "2.gcam_land_data.csv", sep=",", col.names=T, row.names=F, append=F )
  
  