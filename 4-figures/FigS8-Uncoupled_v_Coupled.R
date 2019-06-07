# *************************************************
# * This script plots cropland, forest, and CO2 emissions
# * in both the coupled and uncoupled simulations.
# *************************************************
print("********* Plotting Figure S8 *******************")

source( "../Header.R" )

# Read Data
read.csv( "../3-analyze/3.co2_summary.csv" ) %>%
  mutate(scenario = if_else(scenario == "rcp45", "4.5", "8.5"),
         feedbacks = if_else(feedbacks == "NO", "Excluded", "Included")) -> 
  co2_summary
read.csv( "../3-analyze/4.land_summary.csv" ) %>%
  mutate(scenario = if_else(ref_scen == "RCP45", "4.5", "8.5"),
         feedbacks = if_else(feedbacks == "NO", "Excluded", "Included")) -> 
  land_summary

# Plot Global CO2, cropland and forestland systematically in coupled and uncoupled cases
Fig.DAT <- subset( co2_summary, region == "WORLD" & year %in% years_to_plot & IAM == "GCAM" & variant == "default")
y.label <- "GtC/yr"
max_y <- max(Fig.DAT$value)
title <- expression(bold(paste("Fossil Fuel & Industrial ", CO[2], " Emissions")))
p1 <- ggplot( ) + geom_line( data=Fig.DAT, aes( x=year, y=value, color=scenario, linetype=feedbacks), size=1.5 )
p1 <- p1 + xlab( "Year" ) + ylab( y.label ) + ylim( 0, max_y ) + ggtitle(title)
p1 <- p1 + theme( plot.title = element_text(face="bold", size=14), 
                  axis.text.x = element_text(size = 12), 
                axis.text.y = element_text(size = 12),
                axis.title = element_text(size = 12, face="bold") )
p1 <- p1 + scale_colour_manual(name="2100 Radiative Forcing", values = c("#0072B2", "#D55E00") )
p1 <- p1 + scale_linetype(name="Feedbacks")
print( p1 )
my_legend <- g_legend( p1 )

Fig.DAT <- subset( land_summary, region == "WORLD" & category == "Cropland" & year %in% years_to_plot & variant == "default")
y.label <- expression( bold( paste( "Area (million ", km^2, ")" )))
max_y <- max(Fig.DAT$land)
p2 <- ggplot( ) + geom_line( data=Fig.DAT, aes( x=year, y=land, color=scenario, linetype=feedbacks ), size=1.5 )
p2 <- p2 + xlab( "Year" ) + ylab( y.label ) + ylim( 0, max_y ) + ggtitle("Cropland Area")
p2 <- p2 + theme( plot.title = element_text(face="bold", size=14), 
                  axis.text.x = element_text(size = 14), 
                axis.text.y = element_text(size = 14),
                axis.title = element_text(size = 16, face="bold") )
p2 <- p2 + scale_colour_manual(name="2100 Radiative Forcing", values = c("#0072B2", "#D55E00") )
p2 <- p2 + scale_linetype(name="Feedbacks")
print( p2 )

Fig.DAT <- subset( land_summary, region == "WORLD" & category == "Non-commercial Forest" & year %in% years_to_plot & variant == "default")
y.label <- expression( bold(paste( "Area (million ", km^2, ")" )))
max_y <- max(Fig.DAT$land)
p3 <- ggplot( ) + geom_line( data=Fig.DAT, aes( x=year, y=land, color=scenario, linetype=feedbacks ), size=1.5 )
p3 <- p3 + xlab( "Year" ) + ylab( y.label ) + ylim( 0, max_y ) + ggtitle("Non-Commercial Forest Area")
p3 <- p3 + theme( plot.title = element_text(face="bold", size=14), 
                  axis.text.x = element_text(size = 14), 
                  axis.text.y = element_text(size = 14),
                  axis.title = element_text(size = 16, face="bold") )
p3 <- p3 + scale_colour_manual(name="2100 Radiative Forcing", values = c("#0072B2", "#D55E00") )
p3 <- p3 + scale_linetype(name="Feedbacks")
print( p3 )

# Remove legends
p1 <- p1 + theme(legend.position = "none")
p2 <- p2 + theme(legend.position = "none")
p3 <- p3 + theme(legend.position = "none")

jpeg( "FigureS8_Coupled_v_Uncoupled.jpg", units="in", width = 8.5, height = 6, res=500)
grid.arrange( arrangeGrob( p1, p2, p3, my_legend, ncol=2) )
dev.off()


