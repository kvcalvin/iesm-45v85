# *************************************************
# * This script plots the GCAM 8.5 results alongside
# * the official RCP8.5 results from the MESSAGE model
# *************************************************
print("********* Plotting Figure S1 *******************")

source( "../Header.R" )

# Read Data
MESSAGE_land <- read.csv( "../3-analyze/0.all_glm_data.csv" )
MESSAGE_CO2 <- read.csv( "../2-process/5.RCP_data.csv")
GCAM_CO2 <- read.csv( "../3-analyze/3.co2_summary.csv" )
GCAM_land <- read.csv( "../3-analyze/4.land_summary.csv" )

# Subset for RCP8.5
MESSAGE_land <- subset(MESSAGE_land, scenario == "rcp85"  & IAM == "MESSAGE" &
                         year %in% years_to_plot & region == "WORLD")
MESSAGE_CO2 <- subset(MESSAGE_CO2, Scenario == "MESSAGE - RCP 8.5" & 
                        Variable == "CO2 emissions - Fossil fuels and Industry" &
                        year %in% years_to_plot)
GCAM_CO2 <- subset(GCAM_CO2, region == "WORLD" & variant == "default" 
                   & feedbacks == "NO" & IAM == "GCAM" & scenario == "rcp85" &
                     year %in% years_to_plot)
GCAM_land <- subset(GCAM_land, region == "WORLD" & variant == "default" &
                      ref_scen == "RCP85" & feedbacks == "NO" & 
                      category %in% c("Cropland", "Non-Energy Crops") &
                      year %in% years_to_plot)

# Rename scenarios in RCP_data
MESSAGE_CO2$Scenario <- gsub( "MESSAGE - RCP 8.5", "MESSAGE RCP8.5", MESSAGE_CO2$Scenario )
MESSAGE_land$scenario <- gsub( "rcp85", "MESSAGE RCP8.5", MESSAGE_land$scenario )
GCAM_CO2$Scenario <- "Uncoupled85"
GCAM_land$scenario <- "Uncoupled85"

# CO2 Emissions
y.lab <- "GtC/yr"
y.max <- max(MESSAGE_CO2$value, GCAM_CO2$value)
plot.title <- expression( bold(paste("Global Fossil Fuel and Industrial ", CO[2], " Emissions", sep="" )))
p1 <- ggplot( ) + geom_line( data=MESSAGE_CO2, aes( year, value, color=Scenario ), size=1.5 )
p1 <- p1 + geom_line( data=GCAM_CO2, aes( year, value, color=Scenario ), size=1.5 )
p1 <- p1 + theme(legend.title=element_blank()) + xlab( "" ) + ylab( y.lab ) + ggtitle( plot.title )
p1 <- p1 + ylim(0, y.max)
p1 <- p1 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 14), 
                  axis.text.x = element_text(size = 14), 
                  axis.text.y = element_text(size = 14),
                  axis.title = element_text(size = 16, face="bold") )
p1 <- p1 + theme(legend.position=c( 0.25, 0.85 ) ) + rcp85ColorScale
print( p1 )

# Cropland
y.lab <- expression( paste( "million ", km^2 ) )
plot.title <- "Global Cropland Area"
max_y <- max( MESSAGE_land$crop, GCAM_land$land )
p3 <- ggplot( ) + geom_line( data=MESSAGE_land, aes( year, crop, color=scenario ), size=1.5 )
p3 <- p3 + geom_line( data=GCAM_land, aes( year, land, color=scenario, lty=category ), size=1.5 )
p3 <- p3 + theme(legend.title=element_blank()) + xlab( "" ) + ylab( y.lab ) 
p3 <- p3 + ggtitle( plot.title ) + ylim( 0, max_y )
p3 <- p3 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 14), 
                  axis.text.x = element_text(size = 14), 
                  axis.text.y = element_text(size = 14),
                  axis.title = element_text(size = 16, face="bold") )
p3 <- p3 + theme(legend.position=c( 0.3, 0.3 ) ) + rcp85ColorScale
print( p3 )

jpeg( "FigureS1_RCP85.jpg", units="in", width = 12, height = 6, res=500)
multiplot( p1, p3, cols=2 )
dev.off()
