# ****************************************************************
# * This script plots figures for global land area changes due to coupling
# ****************************************************************
print("********* Plotting Figure 3 *******************")

source( "../Header.R" )

# Read Data
land_coupling_summary <- read.csv( "../3-analyze/2.land_coupling_summary.csv" )

# Plot change in land area due to climate feedbacks
Fig.DAT <- subset( land_coupling_summary, region == "WORLD" & category %!in% c( "Cropland", "Urban", "Tundra", "Rock, Ice, Desert" )
                   & year %in% 2010:2090 )
Fig.DAT$title <- Fig.DAT$ref_scen
Fig.DAT$title <- gsub( "RCP45", "Coupled45 - Uncoupled45", Fig.DAT$title )
Fig.DAT$title <- gsub( "RCP85", "Coupled85 - Uncoupled85", Fig.DAT$title )
y.lab <- expression( paste( "million ", km^2 ))
p <- ggplot( Fig.DAT ) + geom_line( aes( year, delta_land, color=category ), size=1.5 ) 
p <- p + theme(legend.title=element_blank()) + xlab( "Year" ) + ylab( y.lab ) 
p <- p + theme( legend.text = element_text(size = 12),
                strip.background = element_blank(),
                strip.text = element_text(size = 14, face="bold"),
                axis.text.x = element_text(size = 12), 
                axis.text.y = element_text(size = 12),
                axis.title = element_text(size = 12, face="bold") )
p <- p + facet_wrap( ~title)
p <- p + scale_color_manual(values=cbPalette)
print( p )
ggsave( width=8, height=4, dpi=500, "Figure3_Global_Land_Change_Coupling.jpg" )

