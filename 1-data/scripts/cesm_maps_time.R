source( "header.R" )

print( "SET PATHS" )
hist_ref_path <- "/pic/projects/iESM/hist_results/"
case1_ref_path <- "/pic/projects/iESM/rcp85_results/diagnostics/b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001_2006-2090"
case2_ref_path <- "/pic/projects/iESM/rcp45_results/"
plot_dir <- "~/rslts/iESM"

print( "SET VARIABLES & YEARS" )
variables <- c( "NPP" )
years_to_avg_hist <- seq( 135, 154, by=1 )
years_to_avg_case1_fy <- seq( 65, 84, by=1 )
years_to_avg_case2_fy <- seq( 66, 85, by=1 )

print( "LOADING FILES" )
# iESM HIST
hist_name <- "b.e11.B20TRBPRP.f09_g16.iESM_exp12_ctrl.001"
hist_syear <- 1850
hist_eyear <- 2004
hist_fn <- paste( hist_name, "_", hist_syear, "-", hist_eyear, "_ANN_ALL.nc", sep="" )

setwd( hist_ref_path )
hist_climo <- nc_open( hist_fn, write=FALSE, verbose=FALSE )

# iESM CASE 1 Reference
case1r_name <- "b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001"
case1r_plotname <- "Uncoupled85"
case1r_syear <- 2006
case1r_eyear <- 2090
case1r_fn <- paste( case1r_name, "_", case1r_syear, "-", case1r_eyear, "_ANN_ALL.nc", sep="" )

setwd( case1_ref_path )
case1r_climo <- nc_open( case1r_fn, write=FALSE, verbose=FALSE )

# iESM CASE 2 Reference
case2r_name <- "b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.001"
case2r_plotname <- "Uncoupled45"
case2r_syear <- 2005
case2r_eyear <- 2094
case2r_fn <- paste( case2r_name, "_", case2r_syear, "-", case2r_eyear, "_ANN_ALL.nc", sep="" )

setwd( case2_ref_path )
case2r_climo <- nc_open( case2r_fn, write=FALSE, verbose=FALSE )

print( "PROCESS DATA" )
IESM_DF <- data.frame( SCENARIO = c( "DELETE" ),
                       VARIABLE = c( "DELETE" ),
                       TIME = c( "DELETE" ),
                       X1 = c( 0 ),
                       X2 = c( 0 ),
                       value = c( 0 ))

for ( v in variables ){ 
  TEMP <- ncvar_get( hist_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case1r_plotname
  TEMP_DF$TIME <- "BASE"
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_hist )
  TEMP_DF <- aggregate( TEMP_DF$value, by=as.list( TEMP_DF[ c( "SCENARIO", "TIME", "VARIABLE", "X1", "X2" ) ] ), mean )
  names( TEMP_DF )[ names( TEMP_DF ) == "x" ] <- "value"
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
  
  TEMP <- ncvar_get( case1r_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case1r_plotname
  TEMP_DF$TIME <- "FUTURE"
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case1_fy )
  TEMP_DF <- aggregate( TEMP_DF$value, by=as.list( TEMP_DF[ c( "SCENARIO", "TIME", "VARIABLE", "X1", "X2" ) ] ), mean )
  names( TEMP_DF )[ names( TEMP_DF ) == "x" ] <- "value"
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
    
  TEMP <- ncvar_get( hist_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case2r_plotname
  TEMP_DF$TIME <- "BASE"
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_hist )
  TEMP_DF <- aggregate( TEMP_DF$value, by=as.list( TEMP_DF[ c( "SCENARIO",  "TIME", "VARIABLE", "X1", "X2" ) ] ), mean )
  names( TEMP_DF )[ names( TEMP_DF ) == "x" ] <- "value"
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
  
  TEMP <- ncvar_get( case2r_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case2r_plotname
  TEMP_DF$TIME <- "FUTURE"
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case2_fy )
  TEMP_DF <- aggregate( TEMP_DF$value, by=as.list( TEMP_DF[ c( "SCENARIO",  "TIME", "VARIABLE", "X1", "X2" ) ] ), mean )
  names( TEMP_DF )[ names( TEMP_DF ) == "x" ] <- "value"
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
  }

print( "CALCULATE DIFFERENCE" )
TEMP <- subset( IESM_DF, SCENARIO == case1r_plotname )
IESM_DIFF_DF <- cast( TEMP, SCENARIO + VARIABLE + X1 + X2 ~ TIME, val.var=c( "value" ))
IESM_DIFF_DF$DIFF <- IESM_DIFF_DF[ , "FUTURE" ] - IESM_DIFF_DF[ , "BASE" ]
IESM_DIFF_DF <- IESM_DIFF_DF[ names( IESM_DIFF_DF ) %in% c( "SCENARIO", "VARIABLE", "X1", "X2", "DIFF" ) ]

TEMP <- subset( IESM_DF, SCENARIO == case2r_plotname )
TEMP <- cast( TEMP, SCENARIO + VARIABLE + X1 + X2 ~ TIME, val.var=c( "value" ))
TEMP$DIFF <- TEMP[ , "FUTURE" ] - TEMP[ , "BASE" ]
TEMP <- TEMP[ names( TEMP ) %in% c( "SCENARIO", "VARIABLE", "X1", "X2", "DIFF" ) ]
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

print( "PLOT MAPS" )
setwd( plot_dir )
my_colors <- c( '#8e0152','#c51b7d','#de77ae','#f1b6da','#fde0ef','#f7f7f7','#e6f5d0','#b8e186','#7fbc41','#4d9221','#276419' )
for ( v in variables ) { 
  Fig.DAT <- subset(IESM_DIFF_DF, VARIABLE == v)
  Fig.DAT$scen_plot = factor(Fig.DAT$SCENARIO, levels=c('Uncoupled45','Uncoupled85'))
  max_y <- max( abs(Fig.DAT$DIFF) )
  p1 <- ggplot(aes(x = lon, y = lat, fill = DIFF ), data = Fig.DAT ) + geom_raster() + coord_equal() 
  p1 <- p1 + scale_fill_gradientn(colours = my_colors, na.value = "transparent", name="", limits=c(-max_y, max_y))
  p1 <- p1 + ylab( "" ) + xlab( "" ) 
  p1 <- p1 + facet_wrap( ~scen_plot )
  print( p1 )

  ggsave( width=10, height=5, paste( v, "_MAP_TIME_2071to2090avg.png", sep=""))
}