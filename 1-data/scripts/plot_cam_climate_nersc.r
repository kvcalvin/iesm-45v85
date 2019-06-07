###########
#
# read and plot global cam climate variables
# standard cam h0 history files for two cases
# also plot the differences between cases
#  these are monthly files
#  read resolution from files
#   time = 1
#
# input values are monthly averages

# temperature; lon,lat,time; K:
# TREFHT - temp at ref height
# TS - radiative surface temp

# PRECT - total precip rate, lon,lat,time; m/s

# QREFHT - reference height humidity, lon,lat,time; kg/kgair (moist air)

# RHREFHT - reference height relative humidity, lon,lat,time; percent (file says fraction, but the data are in percent)

# LHFLX - surface latent heat flux, lon,lat,time; W/m2
# SHFLX - surface sensible heat flux, lon,lat,tkime; W/m2

# here define divergence as flux in minus flux out, so that positive values are "heating"
# the signs are directional, so boundary values have to be differenced because in and out are different directions at the surface and toa
# so use net surface minus net toa, with positive boundary values in the up direction
# (this divergence is opposite sign to AMS glossary that more strictly follows mathematical convention, but how Bill Collins originally described it)

# long wave divergence: FLNS - FLNT; negative, should increase in magnitude as co2 increases, "cooling"
#  FLNS: net longwave flux at surface lon,lat,time; W/m2; positive is up
#  FLNT: net longwave flux at top of model lon,lat,time; W/m2; positive is up

# short wave divergence: (-FSNS) - (-FSNT); positive, should increase in magnitude as co2 increases, "heating"
#  FSNS: net solar flux at surface lon,lat,time; W/m2; positive is down so first take the negative
#  FSNT: net solar flux at top of model lon,lat,time; W/m2; positive is down so first take the negative

# also calculate RESTOM:  net toa solar in (positive) - net toa longwave out (positive)
#  such that positive RESTOM means heating of the atmosphere

# output values are global average:
# temperature: K
# precip: mm/month or mm/year
# specific humidity: kg vapor / kg moist air
# relative humidity: percent
# radiative values: W/m^2

#
# can store only ~50 monthly grids, so store only one at a time
#
# also output a csv file of the plotted annual data
#
# cam landfrac data is the same as clm landfrac data
# do not need the land area of each grid cell
#  area(lat, lon) area of whole grid cell, km^2
#  landfrac(lat, lon) fraction of grid cell that is land
#  landmask(lat, lon) 1=land, 0=ocean
#  missing/fill value = 1.0E36f
#

# this takes ~40 seconds per year on edison login node

cat("started plot_cam_climate.r", date(), "\n\n")

library(ncdf4)

##### in file

#inname = "chronref_ft_bcase"
#inname = "ftrans_maxfor"
inname = "iESM45_coupled"

#base_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001.cam.h0."
#base_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_maxfor.001.cam.h0."
#base_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_maxfor.001.cam.h0."
base_name = "b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.003.cam.h0."

#casearch1 = "/glade/p/cesm/sdwg_dev/iESM_histlulcc/archive/b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001/"
casearch1 = "/global/project/projectdirs/m1204/shix/b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.003/"
#casearch1 = "/pic/projects/iESM/rcp85_results/b.e11.BRCP85C5BPRP.f09_g16.iESM_coupled.001/"

# the maxfor case is split into two directories, but the files names within are consistent with each other
# the non-cori directory includes 1850-1914, and the cori directory includes 1950-2004
# use MAXFOR = TRUE for the maxfor case, and MAXFOR = FALSE for any other cases
MAXFOR = FALSE
#casearch1 = "/global/project/projectdirs/m1204/shix/b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_maxfor.001/"
#casearch2 = "/global/project/projectdirs/m1204/shix/b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_maxfor.001_Cori/"
casearch2 = "TEMP"
last_year1 = 1914

datadir1 = paste0(casearch1, "atm/hist/")
datadir2 = paste0(casearch2, "atm/hist/")

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

#ref_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001.cam.h0."
ref_name = "b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.001.cam.h0."
#ref_name = "b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_minfor.001.cam.h0."
#ref_name = "b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001.cam.h0."

#refarch = "/glade/p/cesm/sdwg_dev/iESM_histlulcc/archive/b.e11.B20TRBPRP.f09_g16.iESM_chronref_fulltransient.001/"
refarch = "/global/project/projectdirs/m1204/shix/b.e11.BRCP45C5BPRP.f09_g16.iESM_exp2.001/"
#refarch = "/scratch2/scratchdirs/avdivitt/b.e11.B20TRBPRP.f09_g16.iESM_chronref_ftrans_minfor.001/"
#refarch = "/pic/projects/iESM/rcp85_results/b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001/"
refdir = paste0(refarch, "atm/hist/")
#refdir = "/Users/adivi/projects/iesm/diagnostics/hist_lulcc/chronref_fulltransient4_bcase/"

pdfout = paste(outdir, base_name, start_year, "-", end_year, "_vs_", refname, "_clim.pdf", sep = "")
csvout = paste(outdir, base_name, start_year, "-", end_year, "_vs_", refname, "_clim.csv", sep = "")

# this script accomodates only whole years
start_month = 1
end_month = 12

# variables, these have to be grouped by units

# temperature - lon,lat,time; K:
# TREFHT - temp at ref height
# TS - radiative surface temp
var_names_temp = c("TREFHT", "TS")
num_temp_vars = 2
ind_temp_vars = c(1:num_temp_vars)

# PRECT - total precip rate, lon,lat,time; m/s (convert to mm per month or year)
var_names_precip = c("PRECT")
num_precip_vars = 1
ind_precip_vars = c((num_temp_vars+1):(num_temp_vars+num_precip_vars))

# QREFHT - reference height specific humidity, lon,lat,time; kg/kgair (moist)
var_names_q = c("QREFHT")
num_q_vars = 1
ind_q_vars = c((num_temp_vars+num_precip_vars+1):(num_temp_vars+num_precip_vars+num_q_vars))

# RHREFHT - reference height relative humidity, lon,lat,time; percent
var_names_rh = c("RHREFHT")
num_rh_vars = 1
ind_rh_vars = c((num_temp_vars+num_precip_vars+num_q_vars+1):(num_temp_vars+num_precip_vars+num_q_vars+num_rh_vars))

# radiative flux variables

# LHFLX - surface latent heat flux, lon,lat,time; W/m2
# SHFLX - surface sensible heat flux, lon,lat,time; W/m2

#  FLNS: net longwave flux at surface, lon,lat,time; W/m2
#  FLNT: net longwave flux at top of model, lon,lat,time; W/m2

#  FSNS: net solar flux at surface, lon,lat,time; W/m2
#  FSNT: net solar flux at top of model, lon,lat,time; W/m2

var_names_rad = c("LHFLX", "SHFLX", "FLNS", "FLNT", "FSNS", "FSNT")
num_rad_vars = 6
ind_rad_vars = c((num_temp_vars+num_precip_vars+num_q_vars+num_rh_vars+1):(num_temp_vars+num_precip_vars+num_q_vars+num_rh_vars+num_rad_vars))
flns_ind = num_temp_vars + num_precip_vars + num_q_vars + num_rh_vars + 3
flnt_ind = num_temp_vars + num_precip_vars + num_q_vars + num_rh_vars + 4
fsns_ind = num_temp_vars + num_precip_vars + num_q_vars + num_rh_vars + 5
fsnt_ind = num_temp_vars + num_precip_vars + num_q_vars + num_rh_vars + 6

num_in_vars = num_temp_vars+num_precip_vars+num_q_vars+num_rh_vars+ num_rad_vars

# extra output vars
# long wave divergence: FLNS - FLNT; negative, should increase in magnitude as co2 increases
# short wave divergence: FSNS - FSNT; positive, should increase in magnitude as co2 increases
# RESTOM:  net toa solar in - net toa longwave out (residual top of atmosphere radiative flux)
var_names_extra = c("FLDVG", "FSDVG", "RESTOM")
num_extra_vars = 3
ind_extra_vars = c((num_temp_vars+num_precip_vars+num_q_vars+num_rh_vars+num_rad_vars+1):(num_temp_vars+num_precip_vars+num_q_vars+num_rh_vars+num_rad_vars+num_extra_vars))
fldvg_ind = num_temp_vars + num_precip_vars + num_q_vars + num_rh_vars + num_rad_vars + 1
fsdvg_ind = num_temp_vars + num_precip_vars + num_q_vars + num_rh_vars + num_rad_vars + 2
restom_ind = num_temp_vars + num_precip_vars + num_q_vars + num_rh_vars + num_rad_vars + 3

num_vars = num_temp_vars + num_precip_vars + num_q_vars + num_rh_vars + num_rad_vars + num_extra_vars
var_names = c(var_names_temp, var_names_precip, var_names_q, var_names_rh, var_names_rad, var_names_extra)

num_plot_vars = num_vars
ind_plot_vars = c(ind_temp_vars, ind_precip_vars, ind_q_vars, ind_rh_vars, ind_rad_vars, ind_extra_vars)
plot_var_names = c(var_names_temp, var_names_precip, var_names_q, var_names_rh, var_names_rad, var_names_extra)

ylabs = c(rep("K avg for",num_temp_vars), rep("mm per",num_precip_vars), rep("kg/kg moist air, avg for",num_q_vars), rep("percent avg for",num_rh_vars), rep("W/m^2 avg for",num_rad_vars), rep("W/m^2 avg for",num_extra_vars))

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

# convert kilograms to Pg
kg2Pg = 1E-12

# convert from km^2 to m^2
kmsq2msq = 1E6

# convert from m to mm
m2mm = 1000

# convert from Kelvin to Celsius
K2C = -273.15

# convert from vmr to ppmv
vmr2ppmv = 1E6

# surface area of earth in m^2
# based on authalic radius, which is spherical radius that gives same surface area as the reference ellipsoid, which is wgs84
surfarea = 4 * (4.0 * atan(1.0)) * 6371007 * 6371007

# total avg mass of atmosphere (kg)
mass_atm_avg = 5.1480E18

# molecular mass of carbon (g/mol)
mm_c = 12.01

# molecular mass of CO2 (g/mol)
mm_co2 = 44.01

# molecualar mass of CH4 (g/mol)
mm_ch4 = 16.04

# molar mass of atmosphere avg (g/mol) (dry?)
mm_atm = 28.97

# get some necessary info from the first file 
fname = paste(refdir, ref_name, start_year, "-01", ntag, sep = "")	
nc_id = nc_open(fname)
num_lon = nc_id$dim$lon$len
num_lat = nc_id$dim$lat$len
num_time = nc_id$dim$time$len
landfrac_cam = ncvar_get(nc_id, varid = "LANDFRAC", start = c(1,1,1), count = c(num_lon, num_lat, num_time))
gw = ncvar_get(nc_id, varid = "gw", start = c(1), count = c(num_lat))
gw_sum = sum(gw)
gw_glb_sum = gw_sum * num_lon
nc_close(nc_id)

# arrays for storing 1 month of time series of (time, lat, lon) variables
grid_vardata = array(dim=c(num_in_vars, num_lon, num_lat, 1))
grid_refdata = array(dim=c(num_in_vars, num_lon, num_lat, 1))
# arrays for storing monthly time series of global sums of (time, lat, lon) variables
glb_vardata = array(dim = c(num_vars, tot_months))
glb_refdata = array(dim = c(num_vars, tot_months))
glb_diffdata = array(dim = c(num_vars, tot_months))
glb_vardata[,] = 0.0
glb_refdata[,] = 0.0

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
		
		# loop over temp variables, K
		for (vind in ind_temp_vars) {
			grid_vardata[vind,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			
			# multiply by gauss weights and sum the globe to prepare for calculating the global values
			for (lonind in 1:num_lon) {
				glb_vardata[vind, totmind] = glb_vardata[vind, totmind] + sum(grid_vardata[vind,lonind,,1] * gw, na.rm = TRUE)
				glb_refdata[vind, totmind] = glb_refdata[vind, totmind] + sum(grid_refdata[vind,lonind,,1] * gw, na.rm = TRUE)
			}
			
			# complete global average
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] / gw_glb_sum
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] / gw_glb_sum
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]

			# sum for averaging
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			
			# complete annual average at end of each year
			# get the annual difference at the end of each year
			if (mind == end_month) {
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
		} # end loop over temp vars
		
		# loop over precip stock variables, m/s, convert to mm per period
		for (vind in ind_precip_vars) {
			grid_vardata[vind,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			
			# multiply by gauss weights and sum the globe to prepare for calculating the global values
			for (lonind in 1:num_lon) {
				glb_vardata[vind, totmind] = glb_vardata[vind, totmind] + sum(grid_vardata[vind,lonind,,1] * gw, na.rm = TRUE)
				glb_refdata[vind, totmind] = glb_refdata[vind, totmind] + sum(grid_refdata[vind,lonind,,1] * gw, na.rm = TRUE)
			}
			
			# complete global average and convert to mm per month
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] / gw_glb_sum * secpermonth[mind] * m2mm
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] / gw_glb_sum * secpermonth[mind] * m2mm
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]

			# sum monthly values for annual total mm
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind]
			
			# and get the annual difference at the end of each year
			if (mind == end_month) {
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
		} # end loop over precip vars
		
		# loop over specific humidity variables, kg/kg moist air
		for (vind in ind_q_vars) {
			grid_vardata[vind,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			
			# multiply by gauss weights and sum the globe to prepare for calculating the global values
			for (lonind in 1:num_lon) {
				glb_vardata[vind, totmind] = glb_vardata[vind, totmind] + sum(grid_vardata[vind,lonind,,1] * gw, na.rm = TRUE)
				glb_refdata[vind, totmind] = glb_refdata[vind, totmind] + sum(grid_refdata[vind,lonind,,1] * gw, na.rm = TRUE)
			}
			
			# complete the global average
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] / gw_glb_sum
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] / gw_glb_sum

			# monthly difference
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
				
			# sum the values for averaging
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]

			# calc the annual average at the end of each year,
			# and get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
		} # end loop over specific humidity vars
		
		# loop over relative humidity variables, percent
		for (vind in ind_rh_vars) {
			grid_vardata[vind,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			
			# multiply by gauss weights and sum the globe to prepare for calculating the global values
			for (lonind in 1:num_lon) {
				glb_vardata[vind, totmind] = glb_vardata[vind, totmind] + sum(grid_vardata[vind,lonind,,1] * gw, na.rm = TRUE)
				glb_refdata[vind, totmind] = glb_refdata[vind, totmind] + sum(grid_refdata[vind,lonind,,1] * gw, na.rm = TRUE)
			}
			
			# complete the global average
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] / gw_glb_sum
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] / gw_glb_sum

			# monthly difference
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
				
			# sum the values for averaging
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]

			# calc the annual average at the end of each year,
			# and get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
		} # end loop over relative humidity vars
		
		# loop over radiative variables, W/m2
		# fill the three extra variables here
		for (vind in ind_rad_vars) {
			grid_vardata[vind,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			
			# multiply by gauss weights and sum the globe to prepare for calculating the global values
			for (lonind in 1:num_lon) {
				glb_vardata[vind, totmind] = glb_vardata[vind, totmind] + sum(grid_vardata[vind,lonind,,1] * gw, na.rm = TRUE)
				glb_refdata[vind, totmind] = glb_refdata[vind, totmind] + sum(grid_refdata[vind,lonind,,1] * gw, na.rm = TRUE)
			}
			
			# complete the global average
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] / gw_glb_sum
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] / gw_glb_sum

			# divergence is net surface minus net toa when these values have positive signs for upward direction
			# restom is net solar in minus net longwave out
			if (vind == flns_ind) {
				# add to fldvg
				glb_vardata[fldvg_ind, totmind] = glb_vardata[fldvg_ind, totmind] + glb_vardata[vind, totmind]
				glb_refdata[fldvg_ind, totmind] = glb_refdata[fldvg_ind, totmind] + glb_refdata[vind, totmind]
			}
			if (vind == flnt_ind) {
				# subtract from fldvg
				glb_vardata[fldvg_ind, totmind] = glb_vardata[fldvg_ind, totmind] - glb_vardata[vind, totmind]
				glb_refdata[fldvg_ind, totmind] = glb_refdata[fldvg_ind, totmind] - glb_refdata[vind, totmind]
				# subtract from restom
				glb_vardata[restom_ind, totmind] = glb_vardata[restom_ind, totmind] - glb_vardata[vind, totmind]
				glb_refdata[restom_ind, totmind] = glb_refdata[restom_ind, totmind] - glb_refdata[vind, totmind]
			}
			if (vind == fsns_ind) {
				# subtract from fsdvg because sign needs to be flipped
				glb_vardata[fsdvg_ind, totmind] = glb_vardata[fsdvg_ind, totmind] - glb_vardata[vind, totmind]
				glb_refdata[fsdvg_ind, totmind] = glb_refdata[fsdvg_ind, totmind] - glb_refdata[vind, totmind]
			}
			if (vind == fsnt_ind) {
				# add to fsdvg because sign needs to be flipped
				glb_vardata[fsdvg_ind, totmind] = glb_vardata[fsdvg_ind, totmind] + glb_vardata[vind, totmind]
				glb_refdata[fsdvg_ind, totmind] = glb_refdata[fsdvg_ind, totmind] + glb_refdata[vind, totmind]
				# add to restom
				glb_vardata[restom_ind, totmind] = glb_vardata[restom_ind, totmind] + glb_vardata[vind, totmind]
				glb_refdata[restom_ind, totmind] = glb_refdata[restom_ind, totmind] + glb_refdata[vind, totmind]
			}

			# monthly difference
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
				
			# sum the values for averaging
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]

			# calc the annual average at the end of each year,
			# and get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
		} # end loop over radiative vars
		
		# loop over extra vars; one loop for both types because they aggregate the same way
		# the values have been filled above, but diffs and aggregation have to happen
		for (vind in ind_extra_vars) {
			# monthly difference
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
				
			# sum the values for averaging
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]

			# calc the annual average at the end of each year,
			# and get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
		} # end loop over extra vars
		
		nc_close(nc_id)
		nc_close(nc_id_ref)
	} # end for mind loop over months
	
} # end for y loop over years

# plot the variables in one file
pdf(file = pdfout, paper = "letter")

stitle = paste(inname, "-", refname)

plotind = 0
for(vind in ind_plot_vars) {
	
	plotind = plotind + 1
	
	# months
	ymin = min(glb_vardata[vind,], glb_refdata[vind,], na.rm = TRUE)
	ymax = max(glb_vardata[vind,], glb_refdata[vind,], na.rm = TRUE)
	ymin = ymin - 0.15 * (ymax - ymin)
	plot.default(x = c(1:tot_months), y = glb_vardata[vind,], main = plot_var_names[plotind],
		xlab = "Month", ylab = paste(ylabs[plotind], "month"),
		ylim = c(ymin,ymax), mgp = c(2, 1, 0),
		type = "n")
	lines(x = c(1:tot_months), y = glb_vardata[vind,], lty = 1, col = "black")
	lines(x = c(1:tot_months), y = glb_refdata[vind,], lty = 2, col = "gray50")
	legend(x = "bottomleft", lty = c(1,2), col = c("black", "gray50"), legend = c(inname, refname))
	# month diff
	ptitle = paste(plot_var_names[plotind], "diff")
	plot(x = c(1:tot_months), y = glb_diffdata[vind,], xlab = "Month", ylab = paste(ylabs[plotind], "month"), main = ptitle, sub = stitle, type = "l")

	# years
	ymin = min(glbann_vardata[vind,], glbann_refdata[vind,], na.rm = TRUE)
    ymax = max(glbann_vardata[vind,], glbann_refdata[vind,], na.rm = TRUE)
	ymin = ymin - 0.15 * (ymax - ymin)
	plot.default(x = c(start_year:end_year), y = glbann_vardata[vind,], main = plot_var_names[plotind],
		xlab = "Year", ylab = paste(ylabs[plotind], "year"),
		ylim = c(ymin,ymax), mgp = c(2, 1, 0),
		type = "n")
	lines(x = c(start_year:end_year), y = glbann_vardata[vind,], lty = 1, col = "black")
	lines(x = c(start_year:end_year), y = glbann_refdata[vind,], lty = 2, col = "gray50")
	legend(x = "bottomleft", lty = c(1,2), col = c("black", "gray50"), legend = c(inname, refname))	
	# year diff
	ptitle = paste(plot_var_names[plotind], "diff")
	plot(x = c(start_year:end_year), y = glbann_diffdata[vind,], xlab = "Year", ylab = paste(ylabs[plotind], "year"), main = ptitle, sub = stitle, type = "l")
		
} # end for vind loop over plots

dev.off()

# write the global annual values to a csv file, via a data frame table
case = c(rep(inname, num_years), rep(refname, num_years))
year = rep(c(start_year:end_year), 2)
TREFHT_K = c(glbann_vardata[1,], glbann_refdata[1,])
TS_K = c(glbann_vardata[2,], glbann_refdata[2,])
PRECT_mmperyr = c(glbann_vardata[3,], glbann_refdata[3,])
QREFHT_massfrac = c(glbann_vardata[4,], glbann_refdata[4,])
RHREFHT_percent = c(glbann_vardata[5,], glbann_refdata[5,])
LHFLX_Wperm2 = c(glbann_vardata[6,], glbann_refdata[6,])
SHFLX_Wperm2 = c(glbann_vardata[7,], glbann_refdata[7,])
FLNS_Wperm2 = c(glbann_vardata[8,], glbann_refdata[8,])
FLNT_Wperm2 = c(glbann_vardata[9,], glbann_refdata[9,])
FSNS_Wperm2 = c(glbann_vardata[10,], glbann_refdata[10,])
FSNT_Wperm2 = c(glbann_vardata[11,], glbann_refdata[11,])
FLDVG_Wperm2 = c(glbann_vardata[12,], glbann_refdata[12,])
FSDVG_Wperm2 = c(glbann_vardata[13,], glbann_refdata[13,])
RESTOM_Wperm2 = c(glbann_vardata[14,], glbann_refdata[14,])

df = data.frame(case, year, TREFHT_K, TS_K, PRECT_mmperyr, QREFHT_massfrac, RHREFHT_percent, LHFLX_Wperm2, SHFLX_Wperm2, FLNS_Wperm2, FLNT_Wperm2, FSNS_Wperm2, FSNT_Wperm2, FLDVG_Wperm2, FSDVG_Wperm2, RESTOM_Wperm2, stringsAsFactors=FALSE)
write.csv(df, csvout, row.names=FALSE)

cat("finished plot_cam_climate.r", date(), "\n\n")
