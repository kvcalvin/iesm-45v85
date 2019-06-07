# *************************************************
# * This script plots figures decomposing the 
# * effects of socioeconomics, climate policy, and
# * human-Earth system feedbacks.
# *************************************************
print("********* Plotting Figure 8 *******************")

source( "../Header.R" )

# Read Data
crop_socio <- read.csv("../3-analyze/10.crop_socio.csv")
crop_tax <- read.csv("../3-analyze/10.crop_tax.csv")
crop_feedbacks <- read.csv("../3-analyze/10.crop_feedbacks.csv")
forest_socio <- read.csv("../3-analyze/10.forest_socio.csv")
forest_tax <- read.csv("../3-analyze/10.forest_tax.csv")
forest_feedbacks <- read.csv("../3-analyze/10.forest_feedbacks.csv")
co2_socio <- read.csv("../3-analyze/10.co2_socio.csv")
co2_tax <- read.csv("../3-analyze/10.co2_tax.csv")
co2_feedbacks <- read.csv("../3-analyze/10.co2_feedbacks.csv")

# Plot Row #1: Effects of socioeconomic changes
title <- "Socioeconomic Effects"
y.label <- "GtC/yr"
co2_socio$variable <- "CO[2]~' Emissions'"
p1 <- ggplot() + geom_line(data=co2_socio, aes(year, delta_co2, color=scenario), size=1.5)
p1 <- p1 + xlab( "" ) + ylab( y.label ) + ylim( -20, 1 ) + ggtitle(title)
p1 <- p1 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p1 <- p1 + facet_wrap(~variable, nrow = 1, labeller = label_parsed)
p1 <- p1 + scale_color_manual(name="", values=c("#E69F00", "#56B4E9"))
p1 <- p1 + guides(color = guide_legend(nrow = 2))
my_legend <- g_legend( p1 )
print( p1 )

title <- ""
y.label <- expression(bold(paste("million ", km^2)))
crop_socio$variable <- "Cropland Area"
p2 <- ggplot() + geom_line(data=crop_socio, aes(year, delta_land, color=scenario), size=1.5)
p2 <- p2 + xlab( "" ) + ylab( y.label ) + ylim( -4, 0.25 ) + ggtitle(title)
p2 <- p2 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p2 <- p2 + facet_wrap(~variable, nrow = 1)
p2 <- p2 + scale_color_manual(name="", values=c("#E69F00", "#56B4E9"))
print( p2 )

title <- ""
y.label <- expression(bold(paste("million ", km^2)))
forest_socio$variable <- "Non-commercial Forest Area"
p3 <- ggplot() + geom_line(data=forest_socio, aes(year, delta_land, color=scenario), size=1.5)
p3 <- p3 + xlab( "" ) + ylab( y.label ) + ylim( 0, 12 ) + ggtitle(title)
p3 <- p3 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p3 <- p3 + facet_wrap(~variable, nrow = 1)
p3 <- p3 + scale_color_manual(name="", values=c("#E69F00", "#56B4E9"))
print( p3 )

# Plot Row #2: Effects of climate policy
title <- "Climate Policy"
y.label <- "GtC/yr"
co2_tax$variable <- "CO[2]~' Emissions'"
p4 <- ggplot() + geom_line(data=co2_tax, aes(year, delta_co2, color=scenario), size=1.5)
p4 <- p4 + xlab( "" ) + ylab( y.label ) + ylim( -20, 1 ) + ggtitle(title)
p4 <- p4 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p4 <- p4 + facet_wrap(~variable, nrow = 1, labeller = label_parsed)
p4 <- p4 + scale_color_manual(name="", values=c("#009E73", "#F0E442"))
my_legend2 <- g_legend( p4 )
print( p4 )

title <- ""
y.label <- expression(bold(paste("million ", km^2)))
crop_tax$variable <- "Cropland Area"
p5 <- ggplot() + geom_line(data=crop_tax, aes(year, delta_land, color=scenario), size=1.5)
p5 <- p5 + xlab( "" ) + ylab( y.label ) + ylim( -4, 0.25 ) + ggtitle(title)
p5 <- p5 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p5 <- p5 + facet_wrap(~variable, nrow = 1)
p5 <- p5 + scale_color_manual(name="", values=c("#009E73", "#F0E442"))
print( p5 )

title <- ""
y.label <- expression(bold(paste("million ", km^2)))
forest_tax$variable <- "Non-commercial Forest Area"
p6 <- ggplot() + geom_line(data=forest_tax, aes(year, delta_land, color=scenario), size=1.5)
p6 <- p6 + xlab( "" ) + ylab( y.label ) + ylim( 0, 12 ) + ggtitle(title)
p6 <- p6 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p6 <- p6 + facet_wrap(~variable, nrow = 1)
p6 <- p6 + scale_color_manual(name="", values=c("#009E73", "#F0E442"))
print( p6 )

# Plot Row #3: Effects of feedbacks
title <- "Human-Earth Feedbacks Effects"
y.label <- "GtC/yr"
co2_feedbacks$variable <- "CO[2]~' Emissions'"
p7 <- ggplot() + geom_line(data=co2_feedbacks, aes(year, delta_co2, color=scenario), size=1.5)
p7 <- p7 + xlab( "" ) + ylab( y.label ) + ylim( -20, 1 ) + ggtitle(title)
p7 <- p7 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p7 <- p7 + facet_wrap(~variable, nrow = 1, labeller = label_parsed)
p7 <- p7 + scale_color_manual(name="", values=c("#0072B2", "#D55E00"))
my_legend3 <- g_legend( p7 )
print( p7 )

title <- ""
y.label <- expression(bold(paste("million ", km^2)))
crop_feedbacks$variable <- "Cropland Area"
p8 <- ggplot() + geom_line(data=crop_feedbacks, aes(year, delta_land, color=scenario), size=1.5)
p8 <- p8 + xlab( "" ) + ylab( y.label ) + ylim( -4, 0.25 ) + ggtitle(title)
p8 <- p8 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p8 <- p8 + facet_wrap(~variable, nrow = 1)
p8 <- p8 + scale_color_manual(name="", values=c("#0072B2", "#D55E00"))
print( p8 )

title <- ""
y.label <- expression(bold(paste("million ", km^2)))
forest_feedbacks$variable <- "Non-commercial Forest Area"
p9 <- ggplot() + geom_line(data=forest_feedbacks, aes(year, delta_land, color=scenario), size=1.5)
p9 <- p9 + xlab( "" ) + ylab( y.label ) + ylim( 0, 12 ) + ggtitle(title)
p9 <- p9 + theme( plot.title = element_text(face="bold", size=14), 
                  legend.text = element_text(size = 12),
                  strip.background = element_blank(),
                  strip.text = element_text(size = 14),
                  axis.text.x = element_text(size = 12), 
                  axis.text.y = element_text(size = 12),
                  axis.title = element_text(size = 12, face="bold") )
p9 <- p9 + facet_wrap(~variable, nrow = 1)
p9 <- p9 + scale_color_manual(name="", values=c("#0072B2", "#D55E00"))
print( p9 )

# Remove legends
p1 <- p1 + theme(legend.position = "none")
p2 <- p2 + theme(legend.position = "none")
p3 <- p3 + theme(legend.position = "none")
p4 <- p4 + theme(legend.position = "none")
p5 <- p5 + theme(legend.position = "none")
p6 <- p6 + theme(legend.position = "none")
p7 <- p7 + theme(legend.position = "none")
p8 <- p8 + theme(legend.position = "none")
p9 <- p9 + theme(legend.position = "none")

jpeg( "Figure8_Decomposition.jpg", units="in", width = 15, height = 8.5, res=500)
grid.arrange( arrangeGrob( p1, p2, p3, my_legend, p4, p5, p6, my_legend2, p7, p8, p9, my_legend3, ncol=4) )
dev.off()


