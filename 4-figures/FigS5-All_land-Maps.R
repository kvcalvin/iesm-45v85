# *************************************************
# * This script plots maps of the change in land area
# * due to coupling with separate panels for each 
# * land type and scenario.
# *************************************************
print("********* Plotting Figure S5 *******************")

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

# read in gcam data for all land types
setwd( "../../4-figures/")
d.land <- read.csv( "../2-process/2.gcam_land_aez_data.csv" )

# Aggregate some categories together since they are treated alike in CESM
d.land$category <- gsub("Non-commercial Forest", "Forest", d.land$category)
d.land$category <- gsub("Commercial Forest", "Forest", d.land$category)
d.land$category <- gsub("Bioenergy", "Crops", d.land$category)
d.land$category <- gsub("Non-Energy Crops", "Crops", d.land$category)
d.land <- aggregate(d.land$land, by=as.list(d.land[c("scen_name", "feedbacks", "variant", "tax",
                                                     "ref_scen", "region", "AEZ", "category")]), sum)
names(d.land)[ names(d.land) == "x"] <- "land"

# calculate difference due to coupling
TEMP <- d.land
d.land$ref_value <- TEMP$land[ match( vecpaste( d.land[ c( "ref_scen", "region", "AEZ", "category")]),
                                          vecpaste( TEMP[ c( "scen_name", "region", "AEZ", "category")]))]
d.land$difference <- d.land$land - d.land$ref_value

# add region number and aez number
d.land$reg_ID <- reg_map$GCAM_region_ID[ match( d.land$region, reg_map$region ) ]

# loop through scenarios and land types and create a massive df
scenarios <- c("RCP45_Coupled", "RCP85_Coupled")
categories <- c("Forest", "Grassland", "Crops", "Pasture", "Shrubland")
i <- 0
for(s in scenarios) {
  for(c in categories) {
    print(paste(s, c))
    map.data <- subset(d.land, category == c & scen_name == s) 
    map.data <- na.omit( map.data )
    GCAM_MAPDATA$difference <- map.data[ match(paste( GCAM_MAPDATA$GRIDCODE, GCAM_MAPDATA$GCAM_reg_3 ),
                                                     paste( map.data$AEZ, map.data$reg_ID )), "difference" ] 
    GCAM_MAPDATA$category <- c
    if(s == "RCP45_Coupled") {
      GCAM_MAPDATA$scenario <- "Coupled45 - Uncoupled45"
    } else {
      GCAM_MAPDATA$scenario <- "Coupled85 - Uncoupled85"
    }
    if(i == 0) {
      all.data <- GCAM_MAPDATA
    } else{
      all.data <- rbind(all.data, GCAM_MAPDATA)
    }
    i <- i + 1
  }
}

# find scale for maps
temp <- subset(d.land, scen_name %in% scenarios)
max_y <- max( abs( temp$difference ) )

# plot maps
my_colors <- c( '#8e0152','#c51b7d','#de77ae','#f1b6da','#fde0ef','#f7f7f7','#e6f5d0','#b8e186','#7fbc41','#4d9221','#276419' )
leg.title <- expression( paste( "million ", km^2, sep="" ))
p <- ggplot( all.data ) + geom_polygon( aes(long, lat, group=group, fill=difference)) + 
  scale_fill_gradientn( colours = my_colors, # limits=c( -max_y, max_y ),
                        na.value="white", name=leg.title )  +
  theme( plot.title = element_text(lineheight=.8, face="bold", size=20), 
         axis.title.x = element_blank(),
         axis.title.y = element_blank(), 
         axis.ticks = element_blank(),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         strip.background = element_blank(),
         strip.text = element_text(size = 14, face="bold"),
         legend.key.size = unit(1, "cm"),
         legend.text = element_text(size = 14),
         legend.title = element_text(size=16, face="bold"),
         panel.background = element_rect(fill = "transparent",colour = NA),
         plot.background = element_rect(fill = "transparent",colour = NA)  ) 
p <- p + facet_grid(category~scenario) + coord_equal()
plot(p)
ggsave("FigureS5_LandChangeMaps.jpg", units="in", width = 8.5, height = 11, dpi=500)