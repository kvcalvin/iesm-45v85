# *************************************************
# * This script processes the temperature data    *
# * into something usable for further analysis    *
# * and comparison                                *
# *************************************************
print("********* Running 8-T-Process.R *******************")

source( "../Header.R" )

# Read Data
cesm_rcp45 <- read.csv( "../1-data/cesm/clim_data_rcp45.csv" )
cesm_rcp85 <- read.csv( "../1-data/cesm/clim_data_rcp85.csv" )

# Prepare iESM 4.5 data
cesm_rcp45 <- cesm_rcp45[ names( cesm_rcp45 ) %in% c( "case", "year", "TS_K" ) ]
names( cesm_rcp45 )[ names( cesm_rcp45 ) == "TS_K" ] <- "temp"
cesm_rcp45$model <- "iESM"
cesm_rcp45$scenario <- "rcp45"
cesm_rcp45$ens <- "r1i1p1"
cesm_rcp45$IAM <- "DEFAULT"
cesm_rcp45$feedbacks[ cesm_rcp45$case == "iESM45_coupled" ] <- "YES"
cesm_rcp45$feedbacks[ cesm_rcp45$case == "iESM45_uncoupled" ] <- "NO"
cesm_rcp45$driver <- "EMISSIONS"
cesm_rcp45$case <- NULL 

# Prepare iESM 8.5 data
cesm_rcp85 <- cesm_rcp85[ names( cesm_rcp85 ) %in% c( "case", "year", "TS_K" ) ]
names( cesm_rcp85 )[ names( cesm_rcp85 ) == "TS_K" ] <- "temp"
cesm_rcp85$model <- "iESM"
cesm_rcp85$scenario <- "rcp85"
cesm_rcp85$ens <- "r1i1p1"
cesm_rcp85$IAM <- "GCAM"
cesm_rcp85$feedbacks[ cesm_rcp85$case == "iESM_coupled" ] <- "YES"
cesm_rcp85$feedbacks[ cesm_rcp85$case == "iESM_uncoupled_ref" ] <- "NO"
cesm_rcp85$driver <- "EMISSIONS"
cesm_rcp85$case <- NULL 

# Bind all data together
all_temp_data <- rbind( cesm_rcp45, cesm_rcp85 )

# Print data into csv for use in future scripts.
write.table( all_temp_data, "8.all_temp_data.csv", sep=",", col.names=T, row.names=F, append=F )
  
  