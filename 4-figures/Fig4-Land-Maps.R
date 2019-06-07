# *************************************************
# * This script plots maps of changes in cropland
# * and forest due to coupling.
# *************************************************
print("********* Plotting Figure 4 *******************")

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

# read in gcam data for forest and crops
setwd( "../../4-figures/")
d.land <- read.csv( "../2-process/2.gcam_land_aez_data.csv" )

# calculate difference due to coupling
TEMP <- d.land
d.land$ref_value <- TEMP$land[ match( vecpaste( d.land[ c( "ref_scen", "region", "AEZ", "category")]),
                                          vecpaste( TEMP[ c( "scen_name", "region", "AEZ", "category")]))]
d.land$difference <- d.land$land - d.land$ref_value

# Add region number and aez number
d.land$reg_ID <- reg_map$GCAM_region_ID[ match( d.land$region, reg_map$region ) ]

# find scale for Non-commercial Forest
temp <- subset( d.land, category == "Non-commercial Forest" & scen_name %in% c("RCP45_Coupled", "RCP85_Coupled") )
max_y <- max( abs( temp$difference ) )
temp <- subset( d.land, category == "Non-Energy Crops" & scen_name %in% c("RCp35_Coupled", "RCP85_Coupled"))
max_y_crops <- max( abs( temp$difference ) )

# RCP45 Forest Maps
map.data <- subset( d.land, category == "Non-commercial Forest" & scen_name == "RCP45_Coupled")
GCAM_MAPDATA$rcp45_difference <- map.data[ match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                            paste( map.data$AEZ, map.data$reg_ID )), "difference" ] 
map.data <- na.omit( map.data )
my_colors <- c( '#8e0152','#c51b7d','#de77ae','#f1b6da','#fde0ef','#f7f7f7','#e6f5d0','#b8e186','#7fbc41','#4d9221','#276419' )
leg.title <- expression( paste( "million ", km^2, sep="" ))
p1 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp45_difference"])) + 
  scale_fill_gradientn( colours = my_colors, limits=c( -max_y, max_y ),
                        na.value="white", name=leg.title )  +
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
p1 <- p1 + ggtitle( "Forest (Coupled45 - Uncoupled45)") + coord_equal()
plot(p1)

# RCP85 Forest Maps
map.data <- subset( d.land, category == "Non-commercial Forest" & scen_name == "RCP85_Coupled")
GCAM_MAPDATA$rcp85_difference <- map.data[match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                          paste( map.data$AEZ, map.data$reg_ID )), "difference" ] 
map.data <- na.omit( map.data )
leg.title <- expression( paste( "million ", km^2, sep="" ))
p2 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp85_difference"])) + 
  scale_fill_gradientn( colours = my_colors, limits=c( -max_y, max_y ),
                        na.value="white", name=leg.title )  +
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
p2 <- p2 + ggtitle( "Forest (Coupled85 - Uncoupled85)") + coord_equal()
plot(p2)

# RCP45 Cropland Maps
map.data <- subset( d.land, category == "Non-Energy Crops" & scen_name == "RCP45_Coupled")
GCAM_MAPDATA$rcp35_difference <- map.data[ match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                                 paste( map.data$AEZ, map.data$reg_ID )), "difference" ] 
map.data <- na.omit( map.data )
my_colors <- c( '#8e0152','#c51b7d','#de77ae','#f1b6da','#fde0ef','#f7f7f7','#e6f5d0','#b8e186','#7fbc41','#4d9221','#276419' )
leg.title <- expression( paste( "million ", km^2, sep="" ))
p3 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp45_difference"])) + 
  scale_fill_gradientn( colours = my_colors, limits=c( -max_y_crops, max_y_crops ),
                        na.value="white", name=leg.title )  +
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
p3 <- p3 + ggtitle( "Crops (Coupled45 - Uncoupled45)") + coord_equal()
plot(p3)

# RCP85 Cropland Maps
map.data <- subset( d.land, category == "Non-Energy Crops" & scen_name == "RCP85_Coupled")
GCAM_MAPDATA$rcp85_difference <- map.data[match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                                paste( map.data$AEZ, map.data$reg_ID )), "difference" ] 
map.data <- na.omit( map.data )
leg.title <- expression( paste( "million ", km^2, sep="" ))
p4 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp85_difference"])) + 
  scale_fill_gradientn( colours = my_colors, limits=c( -max_y_crops, max_y_crops ),
                        na.value="white", name=leg.title )  +
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
p4 <- p4 + ggtitle( "Crops (Coupled85 - Uncoupled85)") + coord_equal()
plot(p4)

jpeg( paste("Figure4_Map_Land_Delta_", map_year, ".jpg", sep=""), units="in", width = 12, height = 6, res=500)
multiplot( p1, p2, p3, p4, cols=2 )
dev.off()