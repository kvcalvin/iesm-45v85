library( ncdf4 )
library( ggplot2 )
library( reshape )
library( plyr )
library( grid )
library( gridExtra )
library( maptools )
theme_set( theme_bw() )

# -----------------------------------------------------------------------------
# printlog: time-stamped output
# params: msg (message", " can be many items); ts (add timestamp?), cr (print CR?)
printlog <- function( msg, ..., ts=TRUE, cr=TRUE ) {
  if( ts ) cat( date(), " " )
  cat( msg, ..., sep=" " )
  if( cr ) cat( "\n")
}

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
# repeat_and_add_vector: function for repeating a dataframe in order to add a new vector
repeat_and_add_vector <- function( data, vector, vector_values ) {
  data_new <- data[ rep( 1:nrow( data ), times = length( vector_values ) ), ]
  data_new[[vector]] <- sort( rep( vector_values, length.out = nrow( data_new ) ) )
  return( data_new )
}

# -----------------------------------------------------------------------------
#Function "is not an element of" (opposite of %in%)
'%!in%' <- function( x, y ) !( '%in%'( x, y ) )

heat_colors <- c( '#330000','#660000','#990000','#CC0000','#FF0000','#FF3300','#FF6600','#FF9900','#FFCC00', '#FFFF00',
                '#FFFF33', '#FFFF66', '#FFFF99', '#FFFFCC', '#FFFFFF')

div_colors <- c( '#67001f','#b2182b','#d6604d','#f4a582','#fddbc7','#f7f7f7','#d1e5f0','#92c5de','#4393c3','#2166ac','#053061')


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
