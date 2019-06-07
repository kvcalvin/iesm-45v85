# *************************************************
# * This script combines the cropland related information
# * from GCAM & MESSAGE into a single file.
# *************************************************
print("********* Running 4-Land-Analyze.R *******************")

source( "../Header.R" )

# Read Data
gcam_land_data <- read.csv( "../3-analyze/0.gcam_land_data.csv" )
message_land_data <- read.csv( "../3-analyze/0.message_land_data.csv" )

# Also add message data as nonbio_crops since they only use woody biomass
TEMP <- message_land_data
TEMP$category <- "Non-Energy Crops"

# Bind data together
all_land_data <- rbind( gcam_land_data, message_land_data, TEMP )
all_land_data$id <- paste( all_land_data$region, all_land_data$category, all_land_data$scen_name)
names(all_land_data)[ names(all_land_data) == "delta_land"] <- "change"

# Print all data to file
write.table( all_land_data, "4.land_summary.csv", sep=",", col.names=T, row.names=F, append=F )
