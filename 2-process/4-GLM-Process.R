# *************************************************
# * This script processes the glm cropland data   *
# * into something usable for further analysis    *
# * and comparison                                *
# *************************************************
print("********* Running 4-GLM-Process.R *******************")

source( "../Header.R" )

# Read Data
message_cropland <- read.csv( "../1-data/glm/message_crop.csv" ) 
aim_cropland <- read.csv( "../1-data/glm/aim_crop.csv" ) 
image_cropland <- read.csv( "../1-data/glm/image_crop.csv" ) 
minicam_cropland <- read.csv( "../1-data/glm/minicam_crop.csv" ) 
gcam85_coupled <- read.csv( "../1-data/glm/gcam85_coupled_crop.csv")
gcam85_uncoupled <- read.csv( "../1-data/glm/gcam85_uncoupled_crop.csv")
gcam45_coupled <- read.csv( "../1-data/glm/gcam45_coupled2_crop.csv")
gcam45_uncoupled <- read.csv( "../1-data/glm/gcam45_uncoupled_crop.csv")

# Reformat MESSAGE Data into the right format; Add extra columns
message_cropland$crop <- message_cropland$x / 1e6
message_cropland$x <- NULL
message_cropland$IAM <- "MESSAGE"
message_cropland$scenario <- "rcp85"
message_cropland$feedbacks <- "NO"

# Reformat IMAGE Data into the right format; Add extra columns
image_cropland$crop <- image_cropland$x / 1e6
image_cropland$x <- NULL
image_cropland$IAM <- "IMAGE"
image_cropland$scenario <- "rcp26"
image_cropland$feedbacks <- "NO"

# Reformat MINICAM Data into the right format; Add extra columns
minicam_cropland$crop <- minicam_cropland$x / 1e6
minicam_cropland$x <- NULL
minicam_cropland$IAM <- "MiniCAM"
minicam_cropland$scenario <- "rcp45"
minicam_cropland$feedbacks <- "NO"

# Reformat AIM Data into the right format; Add extra columns
aim_cropland$crop <- aim_cropland$x / 1e6
aim_cropland$x <- NULL
aim_cropland$IAM <- "AIM"
aim_cropland$scenario <- "rcp60"
aim_cropland$feedbacks <- "NO"

# Reformat GCAM RCP8.5 Data into the right format; Add extra columns
gcam85_uncoupled$crop <- gcam85_uncoupled$x / 1e6
gcam85_uncoupled$x <- NULL
gcam85_uncoupled$IAM <- "GCAM"
gcam85_uncoupled$scenario <- "rcp85"
gcam85_uncoupled$feedbacks <- "NO"

# Reformat GCAM RCP8.5 Coupled Data into the right format; Add extra columns
gcam85_coupled$crop <- gcam85_coupled$x / 1e6
gcam85_coupled$x <- NULL
gcam85_coupled$IAM <- "GCAM"
gcam85_coupled$scenario <- "rcp85"
gcam85_coupled$feedbacks <- "YES"

# Reformat GCAM RCP4.5 Data into the right format; Add extra columns
gcam45_uncoupled$crop <- gcam45_uncoupled$x / 1e6
gcam45_uncoupled$x <- NULL
gcam45_uncoupled$IAM <- "GCAM"
gcam45_uncoupled$scenario <- "rcp45"
gcam45_uncoupled$feedbacks <- "NO"

# Reformat GCAM RC48.5 Coupled Data into the right format; Add extra columns
gcam45_coupled$crop <- gcam45_coupled$x / 1e6
gcam45_coupled$x <- NULL
gcam45_coupled$IAM <- "GCAM"
gcam45_coupled$scenario <- "rcp45"
gcam45_coupled$feedbacks <- "YES"

# Bind all data together
all_glm_data <- rbind( message_cropland, image_cropland, aim_cropland, minicam_cropland,
                       gcam85_uncoupled, gcam85_coupled, gcam45_uncoupled, gcam45_coupled )

# Print data into csv for use in future scripts.
write.table( all_glm_data, "4.all_glm_data.csv", sep=",", col.names=T, row.names=F, append=F )
  
  