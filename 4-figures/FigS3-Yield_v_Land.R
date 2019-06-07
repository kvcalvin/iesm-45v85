# *************************************************
# * This script plots figures showing the correlation
# * between the change in land due to coupling and 
# * the change in yield due to coupling.
# *************************************************
print("********* Plotting Figure S3 *******************")

source( "../Header.R" )

# Read Data
gcam_aez_cropland_coupling <- read.csv("../3-analyze/7.gcam_aez_cropland_coupling.csv")
gcam_aez_cropland_coupling %>%
  mutate(scenario = if_else(scenario == "rcp45", "Coupled45", "Coupled85")) ->
  gcam_aez_cropland_coupling

# Plot Yield vs % change in land
max_y <- max(abs(gcam_aez_cropland_coupling$yield_pct.delta), abs(gcam_aez_cropland_coupling$land_pct.delta))
p1 <- ggplot( ) + geom_point(data=gcam_aez_cropland_coupling, 
                             aes( x=yield_pct.delta, y=land_pct.delta, color=scenario), size=1.5 )
p1 <- p1 + xlab( "% Change in Yield" ) + ylab( "% Change in Land Area" ) 
p1 <- p1 + theme( axis.text.x = element_text(size = 14), 
                  axis.text.y = element_text(size = 14),
                  axis.title = element_text(size = 16, face="bold") )
p1 <- p1 + ylim(-max_y, max_y) + xlim(-max_y, max_y)
p1 <- p1 + scale_color_manual(name="", values=cbPalette)
print( p1 )
ggsave( "FigureS3_Yield_v_Land.jpg", width = 10, height = 6, dpi = 500 )
