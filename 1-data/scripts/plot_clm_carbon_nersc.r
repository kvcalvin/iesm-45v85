###########
#
# read and plot global clm carbon fluxes and stocks
# standard clm h0 history files for two cases
# also plot the differences between cases
#  these are monthly files
#  read resolution from files - both cases need to have the same resolution and extent
#   time = 1
#
# input values are monthly averages
#  fluxes: gC/m^2/s
#  stocks: gC/m^2
#
# output values are:
#  cumulative per month or year for fluxes (Pg/mm or Pg/yy)
#  monthly or annual average for stocks (Pg)
#
# can store only ~50 monthly grids, so store only one at a time
#
# also output a csv file of the plotted data
#
# need the land area of each grid cell (might eventually need pftmask)
#  area(lat, lon) area of whole grid cell, km^2
#  landfrac(lat, lon) fraction of grid cell that is land
#  landmask(lat, lon) 1=land, 0=ocean
#  missing/fill value = 1.0E36f
#

# this takes ~30 seconds per year on edison login node; and slightly longer on geyser?

cat("started plot_clm_carbon.r", date(), "\n\n")

library(ncdf4)

##### in file

#inname = "chronref_ft_bcase"
#inname = "ftrans_maxfor"
inname = "iesm45_coupled"

#base_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001.clm2.h0."
#base_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_maxfor.001.clm2.h0."
base_name = "b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.003.clm2.h0."

#casearch1 = "/glade/p/cesm/sdwg_dev/iESM_histlulcc/archive/b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001/"
casearch1 = "/global/project/projectdirs/m1204/shix/b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.003/"

# the maxfor case is split into two directories, but the files names within are consistent with each other
# the non-cori directory includes 1850-1914, and the cori directory includes 1950-2004
# use MAXFOR = TRUE for the maxfor case, and MAXFOR = FALSE for any other cases
MAXFOR = FALSE
#casearch1 = "/global/project/projectdirs/m1204/shix/b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_maxfor.001/"
#casearch2 = "/global/project/projectdirs/m1204/shix/b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_maxfor.001_Cori/"
casearch2 = "TEMP"
last_year1 = 1914

datadir1 = paste0(casearch1, "lnd/hist/")
datadir2 = paste0(casearch2, "lnd/hist/")

#datadir1 = "/Users/adivi/projects/iesm/diagnostics/hist_lulcc/chronref_fulltransient4_bcase/"

#outdir = "/glade/u/home/avdivitt/iesm/cesm1_1_iesm27/scripts/b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001/"
#outdir = "/global/u1/a/avdivitt/iesm/iesm_hist_ctrl2/"
#outdir = "/Users/adivi/projects/iesm/diagnostics/hist_lulcc/chronref_fulltransient4_bcase/"
outdir = "/global/cscratch1/sd/kcalvin/diag_test/"

ntag = ".nc"

start_year = 2005
end_year = 2094

##### reference file

#refname = "chronref_ft_bcase"
#refname = "iesm_hist_ctrl2"
#refname = "ftrans_minfor"
refname = "iESM45_uncoupled"

#ref_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001.clm2.h0."
#ref_name = "b.e11.B20TRBPRP.f09_g16.iESM_exp12_ctrl.002.clm2.h0."
#ref_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_minfor.001.clm2.h0."
ref_name = "b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.001.clm2.h0."

#refarch = "/glade/p/cesm/sdwg_dev/iESM_histlulcc/archive/b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001/"
#refarch = "/global/project/projectdirs/m1204/shix/b.e11.B20TRBPRP.f09_g16.iESM_exp12_ctrl.002/"
#refarch = "/scratch2/scratchdirs/avdivitt/b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_minfor.001/"
refarch = "/global/project/projectdirs/m1204/shix/b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.001/"
refdir = paste0(refarch, "lnd/hist/")
#refdir = "/Users/adivi/projects/iesm/diagnostics/hist_lulcc/chronref_fulltransient4_bcase/"

pdfout = paste(outdir, base_name, start_year, "-", end_year, "_vs_", refname, ".pdf", sep = "")
csvout = paste(outdir, base_name, start_year, "-", end_year, "_vs_", refname, ".csv", sep = "")

# this script accomodates only whole years

# variables
# the flux variables have to be listed completely before the stock variables
start_month = 1
end_month = 12
var_names = c("DWT_CLOSS", "WOOD_HARVESTC", "DWT_PROD10C_GAIN", "DWT_PROD100C_GAIN", "NEE", "NPP", "COL_FIRE_CLOSS", "PROD10C", "PROD100C", "TOTVEGC", "TOTSOMC", "TOTECOSYSC", "PBOT", "QBOT", "PCO2")
num_vars = 15
stock_start = 8		# the index of the first stock variable
stock_end = 12		# the index of the last stock variable
p_ind = 13
q_ind = 14
co2_ind = 15

plot_ylabs = c(rep("PgC per", 7), rep("PgC avg for", 5), "Pa avg for", "kg/kg moist air avg for", "ppmv avg for")

num_years = end_year - start_year + 1
tot_months = num_years * 12

# days per month
dayspermonth = c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

# days per year
daysperyear = sum(dayspermonth)

# seconds per month
secpermonth = 86400 * dayspermonth

# convert grams to Pg
g2Pg = 1E-15

# convert from km^2 to m^2
kmsq2msq = 1E6

# get some necessary info from the first file 
fname = paste(refdir, ref_name, start_year, "-01", ntag, sep = "")	
nc_id = nc_open(fname)
num_lon = nc_id$dim$lon$len
num_lat = nc_id$dim$lat$len
num_time = nc_id$dim$time$len
area = ncvar_get(nc_id, varid = "area", start = c(1,1), count = c(num_lon, num_lat))
landfrac = ncvar_get(nc_id, varid = "landfrac", start = c(1,1), count = c(num_lon, num_lat))
landmask = ncvar_get(nc_id, varid = "landmask", start = c(1,1), count = c(num_lon, num_lat))
nc_close(nc_id)

# convert this to m^2
landarea = area * landfrac * landmask * kmsq2msq

landarea_glb = sum(landarea, na.rm = TRUE)

# arrays for storing 1 month of time series of (time, lat, lon) variables
grid_vardata = array(dim=c(num_vars, num_lon, num_lat, 1))
grid_refdata = array(dim=c(num_vars, num_lon, num_lat, 1))
# arrays for storing monthly time series of global sums of (time, lat, lon) variables
glb_vardata = array(dim = c(num_vars, tot_months))
glb_refdata = array(dim = c(num_vars, tot_months))
glb_diffdata = array(dim = c(num_vars, tot_months))

# arrays for storing annual time series of global sums
glbann_vardata = array(dim = c(num_vars, num_years))
glbann_refdata = array(dim = c(num_vars, num_years))
glbann_diffdata = array(dim = c(num_vars, num_years))
glbann_vardata[,] = 0.0
glbann_refdata[,] = 0.0

# loop over year
yind = 0
for (y in start_year:end_year) {
	yind = yind + 1
	cat("starting year", y, date(), "\n")
	# loop over month
	for (mind in start_month:end_month) {
		if(mind > 9) {
			mtag = mind
		}else {
			mtag = paste(0, mind, sep = "")
		}
		# need to read the maxfor files from different directories, based on year
                if(MAXFOR){
                        if(y <= last_year1){
                                fname = paste(datadir1, base_name, y, "-", mtag, ntag, sep = "")
                        } else {
                                fname = paste(datadir2, base_name, y, "-", mtag, ntag, sep = "")
                        }
                } else {
                        fname = paste(datadir1, base_name, y, "-", mtag, ntag, sep = "")
                }
		rname = paste(refdir, ref_name, y, "-", mtag, ntag, sep = "")		
		nc_id = nc_open(fname)
		nc_id_ref = nc_open(rname)
		totmind = (y - start_year) * 12 + mind
		# loop over land variables
		for (vind in 1:stock_end) {
			grid_vardata[vind,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			if (vind < stock_start) {
				# convert to Pg C per month
				grid_vardata[vind,,,1] = grid_vardata[vind,,,1] * landarea * secpermonth[mind] * g2Pg
				grid_refdata[vind,,,1] = grid_refdata[vind,,,1] * landarea * secpermonth[mind] * g2Pg
			} else {
				# convert to Pg C
				grid_vardata[vind,,,1] = grid_vardata[vind,,,1] * landarea * g2Pg
				grid_refdata[vind,,,1] = grid_refdata[vind,,,1] * landarea * g2Pg
			}
			
			# sum to globe
			glb_vardata[vind, totmind] = sum(grid_vardata[vind,,,1], na.rm = TRUE)
			glb_refdata[vind, totmind] = sum(grid_refdata[vind,,,1], na.rm = TRUE)
			# calculate differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]

			# sum to get total annual fluxes and the sum of monthly stock values (weight the stocks by days for averaging)
			if (vind < stock_start) {
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] 
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind]
			} else {
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			}
			
			# calc the annual stock average at the end of each year,
			# and get the difference at the end of each year
			if (mind == end_month) { 
				if (vind >= stock_start) {
					glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
					glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				}
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind] 
			}

		} # end for vind loop over land variables
		
		# deal with the atmosphere variables to get global avg co2 concentration over land
		for (vind in p_ind:co2_ind) {
			grid_vardata[vind,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			
			if (vind == co2_ind) {
				# convert to ppmv; use 0.662 as MM water / MM dry air
				grid_vardata[vind,,,1] = 1E6 * grid_vardata[vind,,,1] /
					(grid_vardata[p_ind,,,1] - (grid_vardata[q_ind,,,1] * grid_vardata[p_ind,,,1]) / (0.622 + grid_vardata[q_ind,,,1] * 0.378))
				grid_refdata[vind,,,1] = 1E6 * grid_refdata[vind,,,1] /
					(grid_refdata[p_ind,,,1] - (grid_refdata[q_ind,,,1] * grid_refdata[p_ind,,,1]) / (0.622 + grid_refdata[q_ind,,,1] * 0.378)) 
			}
			
			# calc global average
			glb_vardata[vind, totmind] = sum(grid_vardata[vind,,,1] * landarea, na.rm = TRUE) / landarea_glb
			glb_refdata[vind, totmind] = sum(grid_refdata[vind,,,1] * landarea, na.rm = TRUE) / landarea_glb
			
			# calculate differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]

			# sum for annual average
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			
			# calc the annual average at the end of each year,
			# and get the difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind] 
			}
		} # end for loop over atmos vars
		
		nc_close(nc_id)
		nc_close(nc_id_ref)
		
	} # end for mind loop over months
	
} # end for y loop over years

# plot the variables in one file
pdf(file = pdfout, paper = "letter")

stitle = paste(inname, "-", refname)

for(vind in 1:num_vars) {
		
		# months
		ymin = min(glb_vardata[vind,], glb_refdata[vind,], na.rm = TRUE)
		ymax = max(glb_vardata[vind,], glb_refdata[vind,], na.rm = TRUE)
		ymin = ymin - 0.15 * (ymax - ymin)
		plot.default(x = c(1:tot_months), y = glb_vardata[vind,], main = var_names[vind],
			xlab = "Month", ylab = paste(plot_ylabs[vind], "month"),
			ylim = c(ymin,ymax), mgp = c(2, 1, 0),
			type = "n")
		lines(x = c(1:tot_months), y = glb_vardata[vind,], lty = 1, col = "black")
		lines(x = c(1:tot_months), y = glb_refdata[vind,], lty = 2, col = "gray50")
		legend(x = "bottomleft", lty = c(1,2), col = c("black", "gray50"), legend = c(inname, refname))
		# month diff
		ptitle = paste(var_names[vind], "diff")
		plot(x = c(1:tot_months), y = glb_diffdata[vind,], xlab = "Month", ylab = paste(plot_ylabs[vind], "month"), main = ptitle, sub = stitle, type = "l")

		# years
		ymin = min(glbann_vardata[vind,], glbann_refdata[vind,], na.rm = TRUE)
        ymax = max(glbann_vardata[vind,], glbann_refdata[vind,], na.rm = TRUE)
		ymin = ymin - 0.15 * (ymax - ymin)
        plot.default(x = c(start_year:end_year), y = glbann_vardata[vind,], main = var_names[vind],
			xlab = "Year", ylab = paste(plot_ylabs[vind], "year"),
			ylim = c(ymin,ymax), mgp = c(2, 1, 0),
			type = "n")
		lines(x = c(start_year:end_year), y = glbann_vardata[vind,], lty = 1, col = "black")
		lines(x = c(start_year:end_year), y = glbann_refdata[vind,], lty = 2, col = "gray50")
		legend(x = "bottomleft", lty = c(1,2), col = c("black", "gray50"), legend = c(inname, refname))	
		# year diff
		ptitle = paste(var_names[vind], "diff")
        plot(x = c(start_year:end_year), y = glbann_diffdata[vind,], xlab = "Year", ylab = paste(plot_ylabs[vind], "year"), main = ptitle, sub = stitle, type = "l")
		
} # end for vind loop over plots

dev.off()

# write the global annual values to a csv file, via a data frame table
case = c(rep(inname, num_years), rep(refname, num_years))
year = rep(c(start_year:end_year), 2)
DWT_CLOSS_PgCperyr = c(glbann_vardata[1,], glbann_refdata[1,])
WOOD_HARVESTC_PgCperyr = c(glbann_vardata[2,], glbann_refdata[2,])
DWT_PROD10C_GAIN_PgCperyr = c(glbann_vardata[3,], glbann_refdata[3,])
DWT_PROD100C_GAIN_PgCperyr = c(glbann_vardata[4,], glbann_refdata[4,])
NEE_PgCperyr = c(glbann_vardata[5,], glbann_refdata[5,])
NPP_PgCperyr = c(glbann_vardata[6,], glbann_refdata[6,])
COL_FIRE_CLOSS_PgCperyr = c(glbann_vardata[7,], glbann_refdata[7,])
PROD10C_PgC_avg = c(glbann_vardata[8,], glbann_refdata[8,])
PROD100C_PgC_avg = c(glbann_vardata[9,], glbann_refdata[9,])
TOTVEGC_PgC_avg = c(glbann_vardata[10,], glbann_refdata[10,])
TOTSOMC_PgC_avg = c(glbann_vardata[11,], glbann_refdata[11,])
TOTECOSYSC_PgC_avg = c(glbann_vardata[12,], glbann_refdata[12,])
PBOT_Pa = c(glbann_vardata[13,], glbann_refdata[13,])
QBOT_massfrac = c(glbann_vardata[14,], glbann_refdata[14,])
co2_ppmv = c(glbann_vardata[15,], glbann_refdata[15,])

df = data.frame(case, year, DWT_CLOSS_PgCperyr, WOOD_HARVESTC_PgCperyr, DWT_PROD10C_GAIN_PgCperyr, DWT_PROD100C_GAIN_PgCperyr, NEE_PgCperyr, NPP_PgCperyr, COL_FIRE_CLOSS_PgCperyr, PROD10C_PgC_avg, PROD100C_PgC_avg, TOTVEGC_PgC_avg, TOTSOMC_PgC_avg, TOTECOSYSC_PgC_avg, PBOT_Pa, QBOT_massfrac, co2_ppmv, stringsAsFactors=FALSE)
write.csv(df, csvout, row.names=FALSE)

cat("finished plot_clm_carbon.r", date(), "\n\n")
