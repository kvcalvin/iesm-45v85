# *************************************************
# * This script plots annual and smoothed global mean temperature
# * in the coupled and uncoupled cases, as well
# * as the residual values.
# *************************************************
print("********* Plot Figure S7 *******************")

source( "../Header.R" )

# Read Data
iesm_data_smooth <- read.csv( "../3-analyze/9.iesm_smooth.csv" )

# Plot iESM Temperature Change, separating trends and variance
iesm_data_smooth %>%
  select(year, scenario, feedbacks, change, fitted, residual) %>%
  gather(type, value, -year, -scenario, -feedbacks) %>%
  mutate(scenario = if_else(scenario == "rcp45", "4.5", "8.5"),
         feedbacks = if_else(feedbacks == "NO", "Excluded", "Included"),
         type = if_else(type == "change", "Annual", type),
         type = if_else(type == "fitted", "Trend", type),
         type = if_else(type == "residual", "Residual", type)) ->
  Fig.DAT
Fig.DAT$type <- factor(Fig.DAT$type, levels=c("Annual", "Trend", "Residual"))
p <- ggplot( ) + geom_line(data=Fig.DAT, aes(x=year, y=value, color=scenario, lty=feedbacks), size=1)
p <- p + xlab( "Year" ) + ylab( "degrees C" )
p <- p + theme( axis.text.x = element_text(size = 14), 
                axis.text.y = element_text(size = 14),
                axis.title = element_text(size = 16, face="bold"), 
                strip.background = element_blank(),
                strip.text = element_text(size = 14, face="bold"),
                legend.position=c(0.8,0.15),
                legend.background = element_rect(fill="transparent") )
p <- p + scale_colour_manual(name="2100 Radiative Forcing", values = c("#0072B2", "#D55E00") )
p <- p + scale_linetype(name="Feedbacks")
p <- p + facet_wrap(~type, ncol=2, scales="free_y")
print( p )
ggsave( width=6, height=4, dpi=500, "FigureS7_iESMTemperature.jpg")
