# *************************************************
# * This script calculates change from base       *
# * year for a variety of different variables.    *
# *************************************************
print("********* Running 0-CalcChange.R *******************")

source( "../Header.R" )

# Choose base years
base_years <- 2006
IAM_base_years <- 2005      # IAM data is only in five-year increments.

# Read Data
all_temp_data <- read.csv( "../2-process/8.all_temp_data.csv" )
all_carbon_data <- read.csv( "../2-process/7.all_carbon_data.csv" )
all_glm_data <- read.csv( "../2-process/4.all_glm_data.csv" )
all_co2_data <- read.csv( "../2-process/3.all_co2_data.csv" )
gcam_land_data <- read.csv( "../2-process/2.gcam_land_data.csv" )
message_land_data <- read.csv( "../2-process/4.all_glm_data.csv" )

# Calculate temperature change 
all_temp_data %>% filter( year %in% base_years ) %>%
            group_by( model, scenario, ens, feedbacks, IAM, driver ) %>% 
              summarize( base_temp=mean( temp ) ) %>%
            left_join( all_temp_data, by=c( "model", "scenario", "ens", "feedbacks", "IAM", "driver" ) ) -> all_temp_data
all_temp_data %>% mutate( change=( temp - base_temp ) ) -> all_temp_data

# Calculate Carbon change 
all_carbon_data %>% filter( year %in% base_years ) %>%
            group_by( model, scenario, ens, feedbacks, IAM, driver ) %>% 
              summarize( base_carbon=mean( carbon ) ) %>%
            left_join( all_carbon_data, by=c( "model", "scenario", "ens", "feedbacks", "IAM", "driver" ) ) -> all_carbon_data
all_carbon_data %>% mutate( change=( carbon - base_carbon ) ) -> all_carbon_data

# Calculate cropland area change 
all_glm_data %>% filter( year %in% base_years ) %>%
          group_by( scenario, feedbacks, IAM, region ) %>% 
            summarize( base_crop=mean( crop ) ) %>%
          left_join( all_glm_data, by=c( "scenario", "feedbacks", "IAM", "region" ) ) -> all_glm_data
all_glm_data %>% mutate( change=( crop - base_crop ) ) -> all_glm_data

# Calculate change in CO2 emissions 
all_co2_data %>% filter( year %in% IAM_base_years ) %>%
        group_by( scenario, feedbacks, variant, IAM, region, tax ) %>% 
            summarize( base_co2=mean( value ) )  %>%
        left_join( all_co2_data, by=c("scenario", "region", "feedbacks", "IAM", "variant", "tax") ) -> all_co2_data
all_co2_data %>% mutate( delta_co2=( value - base_co2 ) ) -> all_co2_data

# Calculate GCAM land area change 
gcam_land_data %>% 
  filter( year %in% IAM_base_years ) %>%
  group_by( region, category, scen_name, ref_scen, feedbacks, variant, tax ) %>% 
  summarize( base_land=mean( land ) ) %>%
  left_join( gcam_land_data, by=c("region", "category", "scen_name",
                                 "ref_scen", "feedbacks", "variant", "tax") ) %>% 
  mutate( delta_land=( land - base_land ) ) -> 
  gcam_land_data

# Calculate MESSAGE land area change 
message_land_data %>% 
  filter( IAM == "MESSAGE" ) %>%
  select(-scenario, -IAM) %>%
  rename(land = crop) %>%
  mutate( category = "cropland", scen_name = "MESSAGE_RCP85",
          ref_scen = "NA", variant = "IAM", tax = "NO") ->
  message_land_data

message_land_data %>%
  filter( year %in% IAM_base_years ) %>%
  group_by( region, category, scen_name, ref_scen, feedbacks, variant, tax ) %>% 
  summarize( base_land=mean( land ) ) %>%
  left_join( message_land_data, by=c("region", "category", "scen_name",
                                  "ref_scen", "feedbacks", "variant", "tax") ) %>% 
  mutate( delta_land=( land - base_land ) ) -> 
  message_land_data

# Print all data to file
write.table( all_temp_data, "0.all_temp_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( all_carbon_data, "0.all_carbon_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( all_glm_data, "0.all_glm_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( all_co2_data, "0.all_co2_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( gcam_land_data, "0.gcam_land_data.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( message_land_data, "0.message_land_data.csv", sep=",", col.names=T, row.names=F, append=F )

