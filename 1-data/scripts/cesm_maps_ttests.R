source( "header.R" )

print( "SET PATHS" )
case1_ref_path <- "/pic/projects/iESM/rcp85_results/diagnostics/b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001_2006-2090"
case1_impacts_path <-  "/pic/projects/iESM/rcp85_results/diagnostics/b.e11.BRCP85C5BPRP.f09_g16.iESM_coupled.001_2006-2088"
case2_ref_path <- "/pic/projects/iESM/rcp45_results/"
case2_impacts_path <-  "/pic/projects/iESM/rcp45_results/"
plot_dir <- "~/rslts/iESM"

print( "SET VARIABLES & YEARS" )
variables <- c( "TSA" )
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
                       X3 = c( 0 ),
                       value = c( 0 ))

for ( v in variables ){ 
  TEMP <- ncvar_get( case1r_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case1r_plotname
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case1 )
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
  
  TEMP <- ncvar_get( case1i_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case1i_plotname
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case1 )
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
  
  TEMP <- ncvar_get( case2r_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case2r_plotname
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case2 )
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
  
  TEMP <- ncvar_get( case2i_climo, varid=v )
  TEMP_DF <- melt( TEMP )
  TEMP_DF$SCENARIO <- case2i_plotname
  TEMP_DF$VARIABLE <- v
  TEMP_DF <- subset( TEMP_DF, X3 %in% years_to_avg_case2 )
  IESM_DF <- rbind( IESM_DF, TEMP_DF )
}

print( "PERFORM PAIRED T-TEST, using year as pairing" )
IESM_DF <- subset(IESM_DF, SCENARIO != "DELETE")
IESM_DF.WIDE <- cast( IESM_DF, VARIABLE + X1 + X2 + X3 ~ SCENARIO, val.var=c( "value" ))
max_X1 <- max(IESM_DF.WIDE$X1)
max_X2 <- max(IESM_DF.WIDE$X2)
IESM_TTEST <- subset(IESM_DF.WIDE, X3 == 75)
IESM_TTEST <- IESM_TTEST[ names(IESM_TTEST) %in% c("VARIABLE", "X1", "X2")]
IESM_TTEST$RCP45 <- "NA"
IESM_TTEST$RCP85 <- "NA"

for( i in 1:max_X1 ) {
  for( j in 1:max_X2 ) {
    TEMP_DF <- subset(IESM_DF.WIDE, X1 == i & X2 == j)
    TEMP_DF <- na.omit(TEMP_DF)
    if( nrow(TEMP_DF) > 1 ) {
      TEMP <- with(TEMP_DF, t.test(Coupled45, Uncoupled45, paired = TRUE))
      IESM_TTEST$RCP45[IESM_TTEST$X1 == i & IESM_TTEST$X2 == j] <- as.numeric(TEMP$p.value)
      
      TEMP <- with(TEMP_DF, t.test(Coupled85, Uncoupled85, paired = TRUE))
      IESM_TTEST$RCP85[IESM_TTEST$X1 == i & IESM_TTEST$X2 == j] <- as.numeric(TEMP$p.value)
    } else {
      IESM_TTEST$RCP45[IESM_TTEST$X1 == i & IESM_TTEST$X2 == j] <- -1
      IESM_TTEST$RCP85[IESM_TTEST$X1 == i & IESM_TTEST$X2 == j] <- -1
    }
  }
}

print( "SAVE DATA FOR LATER" )
setwd( plot_dir )
write.csv(IESM_TTEST, "iESM_ttest_20yr.csv")
