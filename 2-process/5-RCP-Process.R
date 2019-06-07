# *************************************************
# * This script processes the RCP data            *
# * into something usable for further analysis    *
# * and comparison                                *
# *************************************************
print("********* Running 5-RCP-Process.R *******************")
source( "../Header.R" )

# Read Data
RCP_data <- read.csv( "../1-data/cmip5/RCP_data.csv")

# Reformat Data
RCP_data %>% gather( xyear, value, -Region, -Scenario, -Variable, -Unit ) %>%
                mutate( year=as.numeric( substr( xyear, 2, 5 ) ), Unit=NULL, xyear=NULL ) -> RCP_data

# Print data into csv for use in future scripts.
write.table( RCP_data, "5.RCP_data.csv", sep=",", col.names=T, row.names=F, append=F )
  
  