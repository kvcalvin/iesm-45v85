# *************************************************
# * This script plots changes in global carbon pools
# * due to coupling.
# *************************************************
print("********* Plotting Figure S4 *******************")

source( "../Header.R" )

print( "Read Data" )
iesm_couping_data <- read.csv( "../3-analyze/8.iesm_coupling_c.csv" )
iesm_couping_atm_data <- read.csv( "../3-analyze/8.iesm_coupling_atm_c.csv" )
iesm_couping_ocn_data <- read.csv( "../3-analyze/8.iesm_coupling_ocn_c.csv" )

print( "Plot iESM Coupling Effects on Carbon" )
iesm_couping_data$domain <- "Land"
iesm_couping_atm_data$domain <- "Atmosphere"
iesm_couping_ocn_data$domain <- "Ocean"
iesm_couping_data <- rbind( iesm_couping_data, iesm_couping_atm_data, iesm_couping_ocn_data)
iesm_couping_data$scenario <- gsub( "rcp85", "Coupled85 - Uncoupled85", iesm_couping_data$scenario )
iesm_couping_data$scenario <- gsub( "rcp45", "Coupled45 - Uncoupled45", iesm_couping_data$scenario )
p <- ggplot( ) + geom_line( data=iesm_couping_data, aes( x=year, y=coupling_change, color=domain ), size=1 )
p <- p + xlab( "Year" ) + ylab( "PgC/yr" )
p <- p + theme( legend.title=element_blank(), 
                legend.text = element_text(size = 12), 
                strip.background = element_blank(),
                strip.text = element_text(size = 14, face="bold"),
                axis.text.x = element_text(size = 12), 
                axis.text.y = element_text(size = 12),
                axis.title = element_text(size = 12, face="bold") )
p <- p + facet_wrap( ~scenario )
p <- p + scale_color_manual(values=c("#fc8d62", "#66c2a5", "#8da0cb"))
print( p )
ggsave( width=8, height=4, dpi = 500, "FigureS4_iESM_Carbon_Coupling.jpg")