# *************************************************
# * This script plots key results from the official RCPs to 
# * provide context. Cropland area, CO2 emissions, 
# * CO2 concentrations, and total forcing are plotted.
# *************************************************
print("********* Plotting Figure S2 *******************")

source( "../Header.R" )

# Read Data
glm_summary <- read.csv( "../3-analyze/0.all_glm_data.csv" )
RCP_data <- read.csv( "../2-process/5.RCP_data.csv")

# Rename scenarios in RCP_data
RCP_data$Scenario <- gsub( "AIM - RCP 6.0", "RCP6.0", RCP_data$Scenario )
RCP_data$Scenario <- gsub( "MiniCAM - RCP 4.5", "RCP4.5", RCP_data$Scenario )
RCP_data$Scenario <- gsub( "MESSAGE - RCP 8.5", "RCP8.5", RCP_data$Scenario )
RCP_data$Scenario <- gsub( "IMAGE - RCP3-PD \\(2.6)", "RCP2.6", RCP_data$Scenario )

glm_summary$scenario <- gsub( "rcp26", "RCP2.6", glm_summary$scenario )
glm_summary$scenario <- gsub( "rcp45", "RCP4.5", glm_summary$scenario )
glm_summary$scenario <- gsub( "rcp60", "RCP6.0", glm_summary$scenario )
glm_summary$scenario <- gsub( "rcp85", "RCP8.5", glm_summary$scenario )

# CO2 Emissions
Fig.DAT <- subset( RCP_data, Variable == "CO2 emissions - Fossil fuels and Industry" )
y.lab <- "GtC/yr"
plot.title <- expression( bold(paste( "Global Fossil Fuel and Industrial ", CO[2], " Emissions", sep="" ) ))
p1 <- ggplot( ) + geom_line( data=Fig.DAT, aes( year, value, color=Scenario ), size=1.5 )
p1 <- p1 + theme(legend.title=element_blank()) + xlab( "" ) + ylab( y.lab ) + ggtitle( plot.title )
p1 <- p1 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 14), 
                  axis.text.x = element_text(size = 14), 
                  axis.text.y = element_text(size = 14),
                  axis.title = element_text(size = 16, face="bold") )
p1 <- p1 + theme(legend.position=c( 0.2, 0.8 ) ) + rcpColorScale
print( p1 )

# CO2 Concentration
Fig.DAT <- subset( RCP_data, Variable == "Concentration - CO2" )
y.lab <- "ppmv"
plot.title <- expression(bold(paste( CO[2], " Concentration", sep="" ) ))
max_y <- max( Fig.DAT$value )
p2 <- ggplot( ) + geom_line( data=Fig.DAT, aes( year, value, color=Scenario ), size=1.5 )
p2 <- p2 + theme(legend.title=element_blank()) + xlab( "" ) + ylab( y.lab ) + ggtitle( plot.title ) + ylim( 0, max_y )
p2 <- p2 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 14), 
                axis.text.x = element_text(size = 14), 
                axis.text.y = element_text(size = 14),
                axis.title = element_text(size = 16, face="bold") )
p2 <- p2 + theme(legend.position=c( 0.2, 0.8 ) ) + rcpColorScale
print( p2 )

# Radiative Forcing
Fig.DAT <- subset( RCP_data, Variable == "Forcing - Total" )
y.lab <- expression( bold(paste( "W/", m^2 ) ))
plot.title <- "Total Radiative Forcing"
max_y <- max( Fig.DAT$value )
p4 <- ggplot( ) + geom_line( data=Fig.DAT, aes( year, value, color=Scenario ), size=1.5 )
p4 <- p4 + theme(legend.title=element_blank()) + xlab( "" ) + ylab( y.lab ) + ggtitle( plot.title ) + ylim( 0, max_y )
p4 <- p4 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 14), 
                  axis.text.x = element_text(size = 14), 
                  axis.text.y = element_text(size = 14),
                  axis.title = element_text(size = 16, face="bold") )
p4 <- p4 + theme(legend.position=c( 0.2, 0.8 ) ) + rcpColorScale
print( p4 )

# Cropland
Fig.DAT <- subset( glm_summary, IAM %in% c( "IMAGE", "MESSAGE", "AIM", "MiniCAM") & region == "WORLD")
y.lab <- expression( bold(paste( "million ", km^2 ) ))
plot.title <- "Global Cropland Area"
max_y <- max( Fig.DAT$crop )
p3 <- ggplot( ) + geom_line( data=Fig.DAT, aes( year, crop, color=scenario ), size=1.5 )
p3 <- p3 + theme(legend.title=element_blank()) + xlab( "" ) + ylab( y.lab ) + ggtitle( plot.title ) + ylim( 0, max_y )
p3 <- p3 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 14), 
                  axis.text.x = element_text(size = 14), 
                  axis.text.y = element_text(size = 14),
                  axis.title = element_text(size = 16, face="bold") )
p3 <- p3 + theme(legend.position=c( 0.2, 0.2 ) ) + rcpColorScale
print( p3 )

jpeg( "FigureS2_RCP.jpg", units="in", width = 12, height = 8.5, res=500)
multiplot( p1, p2, p3, p4, cols=2 )
dev.off()
