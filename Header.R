# Load Libraries
library( tidyr )
library( dplyr )
library( ggplot2 )
library( reshape2 )
library( broom )
library( grid )
library( gridExtra )
theme_set( theme_bw() )

# -----------------------------------------------------------------------------
# GLOBAL VARIABLES
PLOT_MAPS <- TRUE
years_to_plot <- 2006:2090
IAM_years_to_plot <- seq(2010, 2090, by=5)
map_year <- 2080
avg_period <- 20

# -----------------------------------------------------------------------------
#Function "is not an element of" (opposite of %in%)
'%!in%' <- function( x, y ) !( '%in%'( x, y ) )

# -----------------------------------------------------------------------------
#vecpaste: this is a function for pasting together any number of variables to be used as unique identifiers in a lookup
vecpaste <- function (x) {
  y <- x[[1]]
  if (length(x) > 1) {
    for (i in 2:length(x)) {
      y <- paste(y, x[[i]] )
    }
  }
  y
}

# -----------------------------------------------------------------------------
# Fill scales.
lty.fill <- c( "Bioenergy" = "#CC79A7", "Non-Energy Crops" = "black", "Non-commercial Forest" = "#E69F00",
                  "Pasture" = "#56B4E9", "Shrubland" = "#009E73", "Tundra" = "deeppink", "Urban" = "white", "Rock, Ice, Desert" = "purple",
               "Commercial Forest" = "#D55E00", "Grassland" = "#F0E442" )
landFillScale <- scale_fill_manual(name = "Land Type", values = lty.fill )

rcp.fill <- c( "RCP2.6" = "#009E73", "RCP4.5" = "#0072B2", "RCP6.0" = "#CC79A7", "RCP8.5" = "#D55E00" )
rcpColorScale <- scale_colour_manual(name = "id", values = rcp.fill )

rcp85.col <- c( "Uncoupled85" = "#009E73", "MESSAGE RCP8.5" = "#D55E00" )
rcp85ColorScale <- scale_colour_manual(name = "scenario", values = rcp85.col )

# Colorblind palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}

