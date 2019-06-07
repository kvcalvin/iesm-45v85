# *************************************************
# * This script filters data to remove extra years, 
# * and other problematic values.
# *************************************************
print("********* Running 0-Filter.R *******************")

source( "../Header.R" )

# Read Data
all_temp_data <- read.csv( "../3-analyze/0.all_temp_data.csv" )
all_carbon_data <- read.csv( "../3-analyze/0.all_carbon_data.csv" )
all_glm_data <- read.csv( "../3-analyze/0.all_glm_data.csv" )
all_co2_data <- read.csv( "../3-analyze/0.all_co2_data.csv" )

# Filter for years
all_temp_data %>% filter( year %in% years_to_plot ) -> all_temp_data
all_carbon_data %>% filter( year %in% years_to_plot ) -> all_carbon_data
all_glm_data %>% filter( year %in% years_to_plot ) -> all_glm_data
all_co2_data %>% filter( year %in% years_to_plot ) -> all_co2_data

# Print all data to file
write.table( all_temp_data, "0.all_temp_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( all_carbon_data, "0.all_carbon_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( all_glm_data, "0.all_glm_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( all_co2_data, "0.all_co2_data.csv", sep=",", col.names=T, row.names=F, append=F )


