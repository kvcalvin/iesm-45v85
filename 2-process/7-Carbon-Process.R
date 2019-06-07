# *************************************************
# * This script processes the carbon stock data   *
# * into something usable for further analysis    *
# * and comparison                                *
# *************************************************
print("********* Running 7-Carbon-Process.R *******************")
source( "../Header.R" )

# Read Data
clm_rcp85 <- read.csv( "../1-data/cesm/clm_carbon_data_85.csv" )
clm_rcp45 <- read.csv( "../1-data/cesm/clm_carbon_data_45.csv" )
cam_rcp85 <- read.csv( "../1-data/cesm/cam_carbon_data_85.csv" )
cam_rcp45 <- read.csv( "../1-data/cesm/cam_carbon_data_45.csv" )
pop_rcp85 <- read.csv( "../1-data/cesm/pop_carbon_data_85.csv" )

# Prepare iESM 4.5 CLM data
clm_rcp45 <- clm_rcp45[ names( clm_rcp45 ) %in% c( "case", "year", "TOTECOSYSC_PgC_avg" )]
names( clm_rcp45 )[ names( clm_rcp45 ) == "TOTECOSYSC_PgC_avg" ] <- "carbon"
names( clm_rcp45 )[ names( clm_rcp45 ) == "case" ] <- "scenario"
clm_rcp45$feedbacks[ clm_rcp45$scenario == "iesm45_coupled" ] <- "YES"
clm_rcp45$feedbacks[ clm_rcp45$scenario == "iESM45_uncoupled" ] <- "NO"
clm_rcp45$model <- "iESM"
clm_rcp45$scenario <- "rcp45"
clm_rcp45$ens <- "r1i1p1"
clm_rcp45$IAM <- "DEFAULT"
clm_rcp45$driver <- "EMISSIONS"
clm_rcp45$variable <- NULL 

# Prepare iESM 8.5 CLM data
clm_rcp85 <- clm_rcp85[ names( clm_rcp85 ) %in% c( "case", "year", "TOTECOSYSC_PgC_avg" )]
names( clm_rcp85 )[ names( clm_rcp85 ) == "TOTECOSYSC_PgC_avg" ] <- "carbon"
names( clm_rcp85 )[ names( clm_rcp85 ) == "case" ] <- "scenario"
clm_rcp85$feedbacks[ clm_rcp85$scenario == "iesm85_coupled" ] <- "YES"
clm_rcp85$feedbacks[ clm_rcp85$scenario == "iESM85_uncoupled" ] <- "NO"
clm_rcp85$model <- "iESM"
clm_rcp85$scenario <- "rcp85"
clm_rcp85$ens <- "r1i1p1"
clm_rcp85$IAM <- "GCAM"
clm_rcp85$driver <- "EMISSIONS"
clm_rcp85$variable <- NULL 

# Bind all land carbon data together
all_carbon_data <- rbind( clm_rcp45, clm_rcp85 )

# Copy CAM data so we can process it for other variables
conc_rcp45 <- cam_rcp45
conc_rcp85 <- cam_rcp85

# Prepare iESM 4.5 CAM data
cam_rcp45 <- cam_rcp45[ names( cam_rcp45 ) %in% c( "case", "year", "TMCO2_PgC_avg" )]
names( cam_rcp45 )[ names( cam_rcp45 ) == "TMCO2_PgC_avg" ] <- "carbon"
names( cam_rcp45 )[ names( cam_rcp45 ) == "case" ] <- "scenario"
cam_rcp45$feedbacks[ cam_rcp45$scenario == "iesm45_coupled" ] <- "YES"
cam_rcp45$feedbacks[ cam_rcp45$scenario == "iESM45_uncoupled" ] <- "NO"
cam_rcp45$model <- "iESM"
cam_rcp45$scenario <- "rcp45"
cam_rcp45$ens <- "r1i1p1"
cam_rcp45$IAM <- "DEFAULT"
cam_rcp45$driver <- "EMISSIONS"
cam_rcp45$variable <- NULL 

# Prepare iESM 8.5 CAM data
cam_rcp85 <- cam_rcp85[ names( cam_rcp85 ) %in% c( "case", "year", "TMCO2_PgC_avg" )]
names( cam_rcp85 )[ names( cam_rcp85 ) == "TMCO2_PgC_avg" ] <- "carbon"
names( cam_rcp85 )[ names( cam_rcp85 ) == "case" ] <- "scenario"
cam_rcp85$feedbacks[ cam_rcp85$scenario == "iesm85_coupled" ] <- "YES"
cam_rcp85$feedbacks[ cam_rcp85$scenario == "iESM85_uncoupled" ] <- "NO"
cam_rcp85$model <- "iESM"
cam_rcp85$scenario <- "rcp85"
cam_rcp85$ens <- "r1i1p1"
cam_rcp85$IAM <- "GCAM"
cam_rcp85$driver <- "EMISSIONS"
cam_rcp85$variable <- NULL 

# Bind all atm carbon data together
atm_carbon_data <- rbind( cam_rcp45, cam_rcp85 )

# Prepare iESM 4.5 CAM concentration data
conc_rcp45 <- conc_rcp45[ names( conc_rcp45 ) %in% c( "case", "year", "TMCO2_ppmv_avg" )]
names( conc_rcp45 )[ names( conc_rcp45 ) == "TMCO2_ppmv_avg" ] <- "concentration"
names( conc_rcp45 )[ names( conc_rcp45 ) == "case" ] <- "scenario"
conc_rcp45$feedbacks[ conc_rcp45$scenario == "iesm45_coupled" ] <- "YES"
conc_rcp45$feedbacks[ conc_rcp45$scenario == "iESM45_uncoupled" ] <- "NO"
conc_rcp45$model <- "iESM"
conc_rcp45$scenario <- "rcp45"
conc_rcp45$ens <- "r1i1p1"
conc_rcp45$IAM <- "DEFAULT"
conc_rcp45$driver <- "EMISSIONS"
conc_rcp45$variable <- NULL 

# Prepare iESM 8.5 CAM data
conc_rcp85 <- conc_rcp85[ names( conc_rcp85 ) %in% c( "case", "year", "TMCO2_ppmv_avg" )]
names( conc_rcp85 )[ names( conc_rcp85 ) == "TMCO2_ppmv_avg" ] <- "concentration"
names( conc_rcp85 )[ names( conc_rcp85 ) == "case" ] <- "scenario"
conc_rcp85$feedbacks[ conc_rcp85$scenario == "iesm85_coupled" ] <- "YES"
conc_rcp85$feedbacks[ conc_rcp85$scenario == "iESM85_uncoupled" ] <- "NO"
conc_rcp85$model <- "iESM"
conc_rcp85$scenario <- "rcp85"
conc_rcp85$ens <- "r1i1p1"
conc_rcp85$IAM <- "GCAM"
conc_rcp85$driver <- "EMISSIONS"
conc_rcp85$variable <- NULL 

# Bind all atm concentration data together
atm_conc_data <- rbind( conc_rcp45, conc_rcp85 )

# Prepare iESM 8.5 POP data
pop_rcp85 <- pop_rcp85[ names( pop_rcp85 ) %in% c( "case", "year", "DIC_PgC_avg" )]
names( pop_rcp85 )[ names( pop_rcp85 ) == "DIC_PgC_avg" ] <- "carbon"
names( pop_rcp85 )[ names( pop_rcp85 ) == "case" ] <- "scenario"
pop_rcp85$feedbacks[ pop_rcp85$scenario == "iESM85_coupled" ] <- "YES"
pop_rcp85$feedbacks[ pop_rcp85$scenario == "iesm85_uncoupled" ] <- "NO"
pop_rcp85$model <- "iESM"
pop_rcp85$scenario <- "rcp85"
pop_rcp85$ens <- "r1i1p1"
pop_rcp85$IAM <- "GCAM"
pop_rcp85$driver <- "EMISSIONS"
pop_rcp85$variable <- NULL 

# Bind all ocn carbon data together
ocn_carbon_data <- rbind( pop_rcp85 )

# Print data into csv for use in future scripts.
write.table( all_carbon_data, "7.all_carbon_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( atm_carbon_data, "7.atm_carbon_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( ocn_carbon_data, "7.ocn_carbon_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( atm_conc_data, "7.atm_conc_data.csv", sep=",", col.names=T, row.names=F, append=F )