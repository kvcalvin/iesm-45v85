# *************************************************
# * This script plots the maps showing which land
# * type increases in response to cropland changes 
# * due to coupling.
# *************************************************
print("********* Plotting Figure 9 *******************")

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

# read in gcam data for all land
setwd( "../../4-figures/")
d.land <- read.csv( "../3-analyze/5.land_coupling_type.csv" )

#add region number and aez number
d.land$reg_ID <- reg_map$GCAM_region_ID[ match( d.land$region, reg_map$region ) ]

# Remove nonbio_crops since that is the category whose contraction is the focus of this figure
d.land <- subset(d.land, max_cat != "Non-Energy Crops")

# RCP45 - Land type that responds to cropland declines
map.data <- subset( d.land, scen_name == "RCP45_Coupled")
map.data <- na.omit( map.data )
GCAM_MAPDATA$rcp45_max <- map.data$max_cat[ match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                            paste( map.data$AEZ, map.data$reg_ID )) ] 
GCAM_MAPDATA45 <- subset(GCAM_MAPDATA, rcp45_max != "NA")
p1 <- ggplot( GCAM_MAPDATA45 ) + geom_polygon( aes(long, lat, group=group, fill=rcp45_max ) ) + landFillScale +
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
p1 <- p1 + ggtitle( "Coupled45 - Uncoupled45") + coord_equal()
plot(p1)

# RCP85 - Land type that responds to cropland declines
map.data <- subset( d.land, scen_name == "RCP85_Coupled")
map.data <- na.omit( map.data )
GCAM_MAPDATA$rcp85_max <- map.data$max_cat[match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                          paste( map.data$AEZ, map.data$reg_ID )) ] 
GCAM_MAPDATA85 <- subset(GCAM_MAPDATA, rcp85_max != "NA")
p2 <- ggplot( GCAM_MAPDATA85 ) + geom_polygon( aes(long, lat, group=group, fill=rcp85_max)) + landFillScale +
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
p2 <- p2 + ggtitle( "Coupled85 - Uncoupled85") + coord_equal()
plot(p2)

jpeg( "Figure9_Map_Land_Delta.jpg",  units="in", width = 12, height = 6, res=500)
multiplot( p1, p2, cols=1 )
dev.off()