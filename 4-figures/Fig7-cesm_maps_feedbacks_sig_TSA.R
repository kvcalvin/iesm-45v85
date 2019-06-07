# *************************************************
# * This script plots maps of the change in temperature due to coupling
# * Stippling is added to indicate signficant changes
# * 
# * Given the large file size, the raw data is stored on 
# * PIC. This script needs to be run there using R/3.2.3
# *************************************************

source( "header.R" )

print( "SET PATHS" )
curr_dir <- getwd()
case1_ref_path <- "/pic/projects/iESM/rcp85_results/diagnostics/b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001_2006-2090"
case1_impacts_path <-  "/pic/projects/iESM/rcp85_results/diagnostics/b.e11.BRCP85C5BPRP.f09_g16.iESM_coupled.001_2006-2088"
case2_ref_path <- "/pic/projects/iESM/rcp45_results/"
case2_impacts_path <-  "/pic/projects/iESM/rcp45_results/"
plot_dir <- "~/rslts/iESM"

print( "SET VARIABLES & YEARS" )
variables <- c("TSA")
years_to_avg_case1 <- seq( 65, 84, by=1 )
years_to_avg_case2 <- seq( 66, 85, by=1 )

print( "LOADING FILES" )
# iESM CASE 1 Reference
case1r_name <- "b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001"
case1r_plotname <- "Uncoupled85"
case1r_syear <- 2006
case1r_eyear <- 2090
case1r_fn <- paste( case1r_name, "_", case1r_syear, "-", case1r_eyear, "_ANN_ALL.nc", sep="" )

setwd( case1_ref_path )
case1r_climo <- nc_open( case1r_fn, write=FALSE, verbose=FALSE )

# iESM CASE 1 Impacts
case1i_name <- "b.e11.BRCP85C5BPRP.f09_g16.iESM_coupled.001"
case1i_plotname <- "Coupled85"
case1i_syear <- 2006
case1i_eyear <- 2088
case1i_fn <- paste( case1i_name, "_", case1i_syear, "-", case1i_eyear, "_ANN_ALL.nc", sep="" )

setwd( case1_impacts_path )
case1i_climo <- nc_open( case1i_fn, write=FALSE, verbose=FALSE )

# iESM CASE 2 Reference
case2r_name <- "b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.001"
case2r_plotname <- "Uncoupled45"
case2r_syear <- 2005
case2r_eyear <- 2094
case2r_fn <- paste( case2r_name, "_", case2r_syear, "-", case2r_eyear, "_ANN_ALL.nc", sep="" )

setwd( case2_ref_path )
case2r_climo <- nc_open( case2r_fn, write=FALSE, verbose=FALSE )

# iESM CASE 2 Impacts
case2i_name <- "b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.003"
case2i_plotname <- "Coupled45"
case2i_syear <- 2005
case2i_eyear <- 2094
case2i_fn <- paste( case2i_name, "_", case2i_syear, "-", case2i_eyear, "_ANN_ALL.nc", sep="" )

setwd( case2_impacts_path )
case2i_climo <- nc_open( case2i_fn, write=FALSE, verbose=FALSE )

print( "PROCESS iESM CASE 1 DATA" )
IESM_DF <- data.frame( SCENARIO = c( "DELETE" ),
                       VARIABLE = c( "DELETE" ),
                       X1 = c( 0 ),
                       X2 = c( 0 ),
                       value = c( 0 ))

for ( v in variables ){
  TEMP <- ncvar_get( case1r_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case1r_plotname
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case1 )
  TEMP_DF <- aggregate( TEMP_DF$value, by=as.list( TEMP_DF[ c( "SCENARIO", "VARIABLE", "X1", "X2" ) ] ), mean )
  names( TEMP_DF )[ names( TEMP_DF ) == "x" ] <- "value"
  IESM_DF <- rbind( IESM_DF, TEMP_DF )

  TEMP <- ncvar_get( case1i_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case1i_plotname
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case1 )
  TEMP_DF <- aggregate( TEMP_DF$value, by=as.list( TEMP_DF[ c( "SCENARIO", "VARIABLE", "X1", "X2" )  ] ), mean )
  names( TEMP_DF )[ names( TEMP_DF ) == "x" ] <- "value"
  IESM_DF <- rbind( IESM_DF, TEMP_DF )

  TEMP <- ncvar_get( case2r_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case2r_plotname
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case2 )
  TEMP_DF <- aggregate( TEMP_DF$value, by=as.list( TEMP_DF[ c( "SCENARIO", "VARIABLE", "X1", "X2" ) ] ), mean )
  names( TEMP_DF )[ names( TEMP_DF ) == "x" ] <- "value"
  IESM_DF <- rbind( IESM_DF, TEMP_DF )

  TEMP <- ncvar_get( case2i_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case2i_plotname
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case2 )
  TEMP_DF <- aggregate( TEMP_DF$value, by=as.list( TEMP_DF[ c( "SCENARIO", "VARIABLE", "X1", "X2" )  ] ), mean )
  names( TEMP_DF )[ names( TEMP_DF ) == "x" ] <- "value"
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
}

print( "CALCULATE DIFFERENCE" )
TEMP <- subset( IESM_DF, SCENARIO %in% c( case1i_plotname, case1r_plotname ))
IESM_DIFF_DF <- cast( TEMP, VARIABLE + X1 + X2 ~ SCENARIO, val.var=c( "value" ))
IESM_DIFF_DF$DIFF <- IESM_DIFF_DF[ , case1i_plotname ] - IESM_DIFF_DF[ , case1r_plotname ]
IESM_DIFF_DF <- IESM_DIFF_DF[ names( IESM_DIFF_DF ) %in% c( "SCENARIO", "VARIABLE", "X1", "X2", "DIFF" ) ]
IESM_DIFF_DF$SCENARIO <- paste( case1i_plotname, "-", case1r_plotname )

TEMP <- subset( IESM_DF, SCENARIO %in% c( case2i_plotname, case2r_plotname ))
TEMP <- cast( TEMP, VARIABLE + X1 + X2 ~ SCENARIO, val.var=c( "value" ))
TEMP$DIFF <- TEMP[ , case2i_plotname ] - TEMP[ , case2r_plotname ]
TEMP <- TEMP[ names( TEMP ) %in% c( "SCENARIO", "VARIABLE", "X1", "X2", "DIFF" ) ]
TEMP$SCENARIO <- paste( case2i_plotname, "-", case2r_plotname )
IESM_DIFF_DF <- rbind( IESM_DIFF_DF, TEMP )

print( "ADD Lat & Lon" )
LAT <- ncvar_get( case1r_climo, varid="lat" )
LAT_DF <- melt( LAT )
IESM_DIFF_DF$lat <- LAT_DF$value[match(IESM_DIFF_DF$X2, LAT_DF$indices)]
LON <- ncvar_get( case1r_climo, varid="lon" )
LON_DF <- melt(LON)
IESM_DIFF_DF$lon <- LON_DF$value[match(IESM_DIFF_DF$X1, LON_DF$indices)]

print( "SHIFT LON SO USA IS ON THE LEFT" )
IESM_DIFF_DF$lon[ IESM_DIFF_DF$lon > 180 ] <- IESM_DIFF_DF$lon[ IESM_DIFF_DF$lon > 180 ] - 360

print( "READ IN SIGNIFICANCE" )
setwd( curr_dir )
TTEST <- read.csv("iESM_ttest_20yr.csv")
TTEST <- TTEST[ names(TTEST) %in% c("VARIABLE", "X1", "X2", "RCP45", "RCP85")]
TTEST <- melt(TTEST, id.vars=c("VARIABLE", "X1", "X2"))
TTEST$SCENARIO <- TTEST$variable
TTEST$SCENARIO <- gsub("RCP45", paste( case2i_plotname, "-", case2r_plotname ), TTEST$SCENARIO)
TTEST$SCENARIO <- gsub("RCP85", paste( case1i_plotname, "-", case1r_plotname ), TTEST$SCENARIO)
IESM_DIFF_DF$ttest <- TTEST$value[match(paste(IESM_DIFF_DF$X1, IESM_DIFF_DF$X2, IESM_DIFF_DF$SCENARIO),
                                        paste(TTEST$X1, TTEST$X2, TTEST$SCENARIO))]

print( "PLOT MAPS" )
setwd( plot_dir )
for ( v in variables ) {
  Fig.DAT <- subset(IESM_DIFF_DF, VARIABLE == v)

  # Set plot order
  Fig.DAT$scen_plot = factor(Fig.DAT$SCENARIO, levels=c('Uncoupled45','Uncoupled85'))

  if ( v == "TSA" ) {
    # Use a different color scheme for temperature
    my_colors <- c('#67001f','#b2182b','#d6604d','#f4a582','#fddbc7','#f7f7f7','#d1e5f0','#92c5de','#4393c3','#2166ac','#053061')
    my_colors <- rev(my_colors)
  } else {
    my_colors <- c( '#8e0152','#c51b7d','#de77ae','#f1b6da','#fde0ef','#f7f7f7','#e6f5d0','#b8e186','#7fbc41','#4d9221','#276419' )
  }

  # Set limits on scales
  temp <- subset(Fig.DAT, !is.na(Fig.DAT$DIFF)) # Need to remove NAs for this
  max_y <- max( abs(temp$DIFF) )

  # Plot figure
  p1 <- ggplot( ) + geom_raster(data = Fig.DAT, aes(x = lon, y = lat, fill = DIFF )) + coord_equal()
  p1 <- p1 + geom_point(data = subset(Fig.DAT, ttest != -1 & ttest <= 0.05), aes(x = lon, y = lat), shape = "+", size = 1)
  p1 <- p1 + scale_fill_gradientn(colours = my_colors, na.value = "transparent", name="", limits=c( -max_y, max_y ))
  p1 <- p1 + ylab( "" ) + xlab( "" )
  p1 <- p1 + facet_wrap( ~SCENARIO )
  p1 <- p1 + theme( legend.text = element_text(size = 12),
                    strip.background = element_blank(),
                    strip.text = element_text(size = 14, face="bold"),
                    axis.text.x = element_text(size = 12), 
                    axis.text.y = element_text(size = 12),
                    axis.title = element_text(size = 12, face="bold") )
  print( p1 )

  ggsave( width=10, height=5, dpi=500, paste( v, "_COUPLING_MAP_2071to2090sig.jpg", sep=""))
}
