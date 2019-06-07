# *************************************************
# * This script plots maps of regional CO2 emissions
# *************************************************
print("********* Plotting Figure 5 *******************")

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

# read in gcam data for crops
setwd( "../../4-figures/")
d.CO2 <- read.csv( "../3-analyze/3.regional_co2_change.csv" )

# Add region number
d.CO2$reg_ID <- reg_map$GCAM_region_ID[ match( d.CO2$region, reg_map$region ) ]

# Find scale for % change in CO2
max_y <- max( abs( d.CO2$pct_delta ) )

# RCP45 CO2 maps
map.data <- subset( d.CO2, scenario == "rcp45")
GCAM_MAPDATA$rcp45_difference <- map.data[ match(GCAM_MAPDATA$GCAM_reg_3, map.data$reg_ID ), "pct_delta" ] 
map.data <- na.omit( map.data )
my_colors <- c('#67001f','#b2182b','#d6604d','#f4a582','#fddbc7','#f7f7f7','#d1e5f0','#92c5de','#4393c3','#2166ac','#053061')
leg.title <- "%"
p1 <- ggplot( GCAM_MAPDATA ) + geom_polygon( aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp45_difference"])) + 
  scale_fill_gradientn( colours = rev(my_colors), limits=c( -max_y, max_y ),
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
p1 <- p1 + ggtitle( "Coupled45 - Uncoupled45") + coord_equal()
plot(p1)

# RCP85 CO2 Maps
map.data <- subset( d.CO2, scenario == "rcp85")
GCAM_MAPDATA$rcp85_difference <- map.data[ match(GCAM_MAPDATA$GCAM_reg_3, map.data$reg_ID ), "pct_delta" ] 
map.data <- na.omit( map.data )
leg.title <- "%"
p2 <- ggplot( ) + geom_polygon(data=GCAM_MAPDATA, aes(long, lat, group=group, fill=GCAM_MAPDATA[,"rcp85_difference"])) + 
  scale_fill_gradientn( colours = rev(my_colors), limits=c( -max_y, max_y ),
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
p2 <- p2 + ggtitle( "Coupled85 - Uncoupled85") + coord_equal()
plot(p2)

jpeg( paste("Figure5_Map_CO2_Delta_", map_year, ".jpg", sep=""), units="in", width = 12, height = 3, res=500)
multiplot( p1, p2, cols=2 )
dev.off()