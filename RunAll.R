# *************************************************
# * This script runs the entire system in the     *
# * correct order. All new files need to be       *
# * added here.                                   *
# *                                               *
# * Author: Kate Calvin                           *
# *************************************************

setwd( "./2-process/" )
source( "./1-Scaler_Process.R" )
source( "./2-Land-Process.R" )
source( "./3-CO2-Process.R" )
source( "./4-GLM-Process.R" )
source( "./5-RCP-Process.R" )
source( "./6-Yield_Process.R" )
source( "./7-Carbon-Process.R" )
source( "./8-T-Process.R" )

setwd( "../3-analyze/" )
source( "./0-CalcChange.R" )
source( "./0-Filter.R" )
source( "./1-Scaler-Analyze.R" )
source( "./2-Land-Compare.R" )
source( "./3-CO2-Analyze.R" )
source( "./4-Land-Analyze.R" )
source( "./5-Land-AEZ-Compare.R" )
source( "./7-Yield-Analyze.R" )
source( "./8-Carbon-Summarize.R" )
source( "./9-T-Summarize.R" )
source( "./10-Decomposition.R" )

setwd( "../4-figures/" )
source( "./Fig2-Scaler-Maps.R")
source( "./Fig3-Land-Figures.R" )
source( "./Fig4-Land-Maps.R" )
source( "./Fig5-CO2-Maps.R" )
# Note: Figures 6 & 7 need large files currently stored on PIC
source( "./Fig8-Decomposition.R" )
source( "./Fig9-OtherLand-Maps.R" )
source( "./FigS1-RCP85-Figures.R" )
source( "./FigS2-RCP-Figures.R" )
source( "./FigS3-Yield_v_Land.R" )
source( "./FigS4-Carbon-Figures.R" )
source( "./FigS5-All_land-Maps.R" )
# Note: Figure S6 needs large files currently stored on PIC
source( "./FigS7-T-Figures.R" )
source( "./FigS8-Uncoupled_v_Coupled.R" )

setwd( "..")