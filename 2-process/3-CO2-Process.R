# *************************************************
# * This script processes CO2 emissions data      *
# * into something usable for further analysis    *
# * and comparison                                *
# *************************************************
print("********* Running 3-CO2-Process.R *******************")

source( "../Header.R" )

# Read Data
message_CO2 <- read.csv( "../1-data/cmip5/message_co2.csv" ) 
gcam_co2 <- read.csv( "../1-data/gcam/co2.csv" )

# Read Mappings
scen_map <- read.csv( "../1-data/mappings/scenarios.csv" )

# Reformat MESSAGE Data into the right format; Add extra columns
message_CO2 %>% gather( variable, value, -Region, -Scenario, -Variable, -Unit ) -> message_CO2.processed
message_CO2.processed$scenario <- "rcp85"
message_CO2.processed$IAM <- "MESSAGE"
message_CO2.processed$region <- "WORLD"
message_CO2.processed$unit <- "GtC/yr"
message_CO2.processed$year <- as.numeric( substr( message_CO2.processed$variable, 2, 5 ) )
message_CO2.processed$variable <- NULL
message_CO2.processed$Variable <- NULL
message_CO2.processed$Scenario <- NULL
message_CO2.processed$Region <- NULL
message_CO2.processed$Unit <- NULL
message_CO2.processed$feedbacks <- "NO"
message_CO2.processed$tax <- "NO"
message_CO2.processed$variant <- "default"
  
# Reformat GCAM Data into the right format; Add extra columns; Delete unneeded scenarios
gcam_co2 %>% gather( variable, value, -title, -scenario, -region, -Units ) -> gcam_CO2.processed
gcam_CO2.processed$year <- as.numeric( substr( gcam_CO2.processed$variable, 2, 5 ) )
gcam_CO2.processed$variable <- NULL
gcam_CO2.processed$Units <- NULL
gcam_CO2.processed$title <- NULL
gcam_CO2.processed$unit <- "GtC/yr"
gcam_CO2.processed$gcam_scen <- gcam_CO2.processed$scenario
gcam_CO2.processed$value <- gcam_CO2.processed$value / 1000
gcam_CO2.processed$IAM <- "GCAM"
gcam_CO2.processed$scenario <- scen_map$scenario[ match( gcam_CO2.processed$gcam_scen, scen_map$gcam_scenario )]
gcam_CO2.processed$feedbacks <- scen_map$feedbacks[ match( gcam_CO2.processed$gcam_scen, scen_map$gcam_scenario )]
gcam_CO2.processed$variant <- scen_map$variant[ match( gcam_CO2.processed$gcam_scen, scen_map$gcam_scenario )]
gcam_CO2.processed$tax <- scen_map$tax[ match( gcam_CO2.processed$gcam_scen, scen_map$gcam_scenario ) ]
gcam_CO2.processed <- subset( gcam_CO2.processed, scenario != "skip" ) 
gcam_CO2.processed$gcam_scen <- NULL
gcam_CO2.processed <- gcam_CO2.processed[ c( "year", "value", "scenario", "IAM", "region", "unit", "feedbacks", "variant", "tax")]

# Calculate global totals for GCAM
TEMP <- gcam_CO2.processed
TEMP %>% group_by( year, scenario, IAM, unit, feedbacks, variant, tax ) %>%
                          summarize( value=sum(value) ) ->  gcam_world 
gcam_world$region <- "WORLD"
gcam_world <- as.data.frame( gcam_world )

# Bind all data together
all_co2_data <- rbind( message_CO2.processed, gcam_CO2.processed, gcam_world )

# Print data into csv for use in future scripts.
write.table( all_co2_data, "3.all_co2_data.csv", sep=",", col.names=T, row.names=F, append=F )
  
  