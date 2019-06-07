# *************************************************
# * This script calculates the change in land area
# * due to coupling.
# *************************************************
print("********* Running 2-Land-Compare.R *******************")

source( "../Header.R" )

# Read Data
gcam_land_data <- read.csv( "../2-process/2.gcam_land_data.csv" )

# Filter for relevant years (we don't want to look at 1990) 
gcam_land_data %>% filter( year > 1990 ) -> gcam_land_data

#Step 1: Calculate difference between coupled & uncoupled
land_coupling_summary <- subset( gcam_land_data, scen_name %in% c( "RCP45_Coupled", "RCP85_Coupled" ) )
land_coupling_summary$ref_land <- gcam_land_data$land[ match( vecpaste( land_coupling_summary[ c( "region", "category", "year", "ref_scen" )] ),
                                                              vecpaste( gcam_land_data[ c( "region", "category", "year", "scen_name" )]))]
land_coupling_summary$delta_land <- land_coupling_summary$land - land_coupling_summary$ref_land
land_coupling_summary$land <- NULL
land_coupling_summary$ref_land <- NULL

# Print all data to file
write.table( land_coupling_summary, "2.land_coupling_summary.csv", sep=",", col.names=T, row.names=F, append=F )
