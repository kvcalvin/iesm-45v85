# *************************************************
# * This script plots maps of regional crop and forest scalers.
# *************************************************
print("********* Plotting Figure 2 *******************")

# Load libraries
library(maptools)
library(ggmap)
library(maps)
library(rgdal)
library(grid)
source( "../Header.R")

# Read in shape file for mapping
GIS_DIR <- "../1-data/mappings/"
GIS_FILE <- "GCAM_region_AEZ"
setwd( GIS_DIR )
gcam <- readOGR( dsn=".", layer=GIS_FILE )
gcam@data$id <- rownames( gcam@data )
gcam.points <- fortify( gcam, region="id" )
GCAM_MAPDATA <<- merge( gcam.points, gcam@data, by="id" )
reg_map <- read.csv( "GCAM_region_names_14reg.csv" ) 

# Read in gcam scaler data
setwd( "../../4-figures/")
d.crops <- read.csv( "../3-analyze/1.gcam_scaler_crops.csv" )
d.forest <- read.csv( "../3-analyze/1.gcam_scaler_forest.csv" )

# Find maximum value on the scale
temp <- rbind(d.crops, d.forest)
temp <- na.omit(temp)
max_y <- max(temp$scaler)

# Add region number and aez number
d.crops$reg_ID <- reg_map$GCAM_region_ID[ match( d.crops$region, reg_map$region ) ]
d.forest$reg_ID <- reg_map$GCAM_region_ID[ match( d.forest$region, reg_map$region ) ]

# RCP45 Crop Scaler Map
map.data <- subset( d.crops, scenario == "rcp45")
GCAM_MAPDATA$rcp45_crop <- map.data[ match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                            paste( map.data$AEZ, map.data$reg_ID )), "scaler" ] 
map.data <- na.omit( map.data )
leg.title <- ""
p1 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp45_crop"])) + 
  scale_fill_gradient2(high = "#276419", mid = "white", low = "#8e0152", name=leg.title, midpoint = 1, limits=c(0,2) )  +
  theme( plot.title = element_text(face="bold", size=14), 
         axis.title.x = element_blank(),
         axis.title.y = element_blank(), 
         axis.ticks = element_blank(),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         legend.key.size = unit(1, "cm"),
         axis.text = element_text(size = 12),
         legend.text = element_text(size = 10),
         legend.title = element_text(size=12, face="bold"),
         panel.background = element_rect(fill = "transparent",colour = NA),
         plot.background = element_rect(fill = "transparent",colour = NA)  ) 
p1 <- p1 + ggtitle( "RCP45 Crops") + coord_equal()
plot(p1)

# RCP85 Crop Scaler Map
map.data <- subset( d.crops, scenario == "rcp85")
GCAM_MAPDATA$rcp85_crop <- map.data[match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                          paste( map.data$AEZ, map.data$reg_ID )), "scaler" ] 
map.data <- na.omit( map.data )
leg.title <- ""
p2 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp85_crop"])) + 
  scale_fill_gradient2(high = "#276419", mid = "white", low = "#8e0152", name=leg.title, midpoint = 1 , limits=c(0,2))  +
  theme( plot.title = element_text(face="bold", size=14), 
         axis.title.x = element_blank(),
         axis.title.y = element_blank(), 
         axis.ticks = element_blank(),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         legend.key.size = unit(1, "cm"),
         axis.text = element_text(size = 12),
         legend.text = element_text(size = 10),
         legend.title = element_text(size=12, face="bold"),
         panel.background = element_rect(fill = "transparent",colour = NA),
         plot.background = element_rect(fill = "transparent",colour = NA)  ) 
p2 <- p2 + ggtitle( "RCP85 Crops") + coord_equal()
plot(p2)

# RCP45 Forest scalar map
map.data <- subset( d.forest, scenario == "rcp45")
GCAM_MAPDATA$rcp45_forest <- map.data[ match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                           paste( map.data$AEZ, map.data$reg_ID )), "scaler" ] 
map.data <- na.omit( map.data )
my_colors <- c( '#8e0152','#c51b7d','#de77ae','#f1b6da','#fde0ef','#f7f7f7','#e6f5d0','#b8e186','#7fbc41','#4d9221','#276419' )
leg.title <- ""
p3 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp45_forest"])) + 
  scale_fill_gradient2(high = "#276419", mid = "white", low = "#8e0152", name=leg.title, midpoint = 1, limits=c(0,2) )  +
  theme( plot.title = element_text(face="bold", size=14), 
         axis.title.x = element_blank(),
         axis.title.y = element_blank(), 
         axis.ticks = element_blank(),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         legend.key.size = unit(1, "cm"),
         axis.text = element_text(size = 12),
         legend.text = element_text(size = 10),
         legend.title = element_text(size=12, face="bold"),
         panel.background = element_rect(fill = "transparent",colour = NA),
         plot.background = element_rect(fill = "transparent",colour = NA)  ) 
p3 <- p3 + ggtitle( "RCP45 Forest") + coord_equal()
plot(p3)

# RCP85 Forest scaler map
map.data <- subset( d.forest, scenario == "rcp85")
GCAM_MAPDATA$rcp85_forest <- map.data[match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                          paste( map.data$AEZ, map.data$reg_ID )), "scaler" ] 
map.data <- na.omit( map.data )
leg.title <- ""
p4 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp85_forest"])) + 
  scale_fill_gradient2(high = "#276419", mid = "white", low = "#8e0152", name=leg.title, midpoint = 1, limits=c(0,2) )  +
  theme( plot.title = element_text(face="bold", size=14), 
         axis.title.x = element_blank(),
         axis.title.y = element_blank(), 
         axis.ticks = element_blank(),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         legend.key.size = unit(1, "cm"),
         axis.text = element_text(size = 12),
         legend.text = element_text(size = 10),
         legend.title = element_text(size=12, face="bold"),
         panel.background = element_rect(fill = "transparent",colour = NA),
         plot.background = element_rect(fill = "transparent",colour = NA)  ) 
p4 <- p4 + ggtitle( "RCP85 Forest") + coord_equal()
plot(p4)

jpeg( paste("Figure2_Map_Scaler", map_year, ".jpg", sep=""), units="in", width = 12, height = 6, res=500)
multiplot( p3, p1, p4, p2, cols=2 )
dev.off()