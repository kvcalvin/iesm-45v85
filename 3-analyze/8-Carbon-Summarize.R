# *************************************************
# * This script calculates the change in carbon
# * pools due to coupling.
# *************************************************
print("********* Running 8-Carbon-Summarize.R *******************")

source( "../Header.R" )

print( "Read data" )
all_carbon_data <- read.csv( "../3-analyze/0.all_carbon_data.csv" )
atm_carbon_data <- read.csv( "../2-process/7.atm_carbon_data.csv" )
ocn_carbon_data <- read.csv( "../2-process/7.ocn_carbon_data.csv" )

print( "Compute difference due to coupling" )
all_carbon_data %>% filter( model == "iESM" ) %>% 
  mutate( base_carbon = NULL, change = NULL ) %>%
  spread( feedbacks, carbon ) %>%
  mutate( coupling_change = YES - NO, YES = NULL, NO = NULL ) -> iesm.coupling.c.data

atm_carbon_data %>% spread( feedbacks, carbon ) %>%
  mutate( coupling_change = YES - NO, YES = NULL, NO = NULL ) -> iesm.coupling.atm.c.data

ocn_carbon_data %>% spread( feedbacks, carbon ) %>%
  mutate( coupling_change = YES - NO, YES = NULL, NO = NULL ) -> iesm.coupling.ocn.c.data

print( "Write all data to csv files" )
write.table( iesm.coupling.c.data, "8.iesm_coupling_c.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( iesm.coupling.atm.c.data, "8.iesm_coupling_atm_c.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( iesm.coupling.ocn.c.data, "8.iesm_coupling_ocn_c.csv", sep=",", col.names=T, row.names=F, append=F )

