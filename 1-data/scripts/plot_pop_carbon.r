###########
#
# read and plot global pop carbon fluxes and stocks
# standard pop.h history files for two cases
# also plot the differences between cases
#  these are monthly files
#  read resolution from files - both cases need to have same resolution and extent
#   time = 1
#

# NOTE: use only DIC to estimate total ocean carbon !!!!!!!!!!!!!!!!!!
#  the present day ecosystem carbon values do not match well with field estimates
#  in particular, the DOC is < 10 PgC globally, while estimates put it above 700 PgC
#  the biological carbon (~25 PgC) is much higher than estimates (~3 PgC)
#  the particulate accumulation rates may not be fully accounted for here (I may be missing variables, as no stock variables exist)
#  the particulate PIC total accumulation is slightly higher than the estimated settling rate
#  the particulate POC total accumulation is too high

# total ocean carbon should be the sum of carbon in:
#  spC, diatC, zooC, diazC, spCaCO3, DIC, DOC, and the estimated carbon stocks of particulate organic carbon and particulate caco3
#  but the particulates do not have stocks, and the rates are total accumulation, which would include settling into sediment
# independent estimates are about 38,000 PgC for DIC, ~700 PgC for deep ocean DOC (and ~25 PgC in the upper ocean), ~3 PgC for living and dead biomass and particles including CaCO3 (mostly biomass)
#  particles are thought to mostly cylce through with little accumulation in sediment and an unkown amount in the water
#   settling into sediment: PIC ~0.4 PgC per year, POC ~0.2 PgC per year

# this script accomodates only whole years

# variables
# these are all T grid variables
# also need:
# dz[z_t] (layer thickness, cm), TLONG[nlon,nlat] (degress east), TLAT[nlon,nlat] (degrees north), TAREA[nlon,nlat] (cm^2)
# z_t[60] - depth to midpoint of layer, cm
# z_t_150m[15] - depth to midpoint of layer, cm

# ecosystem organic carbon; nlon,nlat,z_t_150m,time; mmol/m3:
# spC, diatC, zooC, diazC, spCaCO3
# small phytoplanktion, diatoms, zooplankton, diazotrophs, small phytoplankton calcium carbonate
# assume that the eco caco3 formation is for particulates, and process it below as such

# particulate organic carbon has only flux and production/dissolve variables, but can calc stock from these:
# POC_FLUX_IN[nlon,nlat,z_t,time] mmol/m3 . cm/s (POC flux into cell)
# POC_PROD[nlon,nlat,z_t,time] mmol/m3/s (POC production)

# particulate calcium carbonate has flux and production/dissolve, and eco formation, calc a stock from these:
# CaCO3_FLUX_IN[nlon,nlat,z_t,time] mmol/m3 . cm/s (caco3 flux into cell)
# CaCO3_PROD[nlon,nlat,z_t,time] mmol/m3/s (caco3 production)
# CaCO3_form[nlon,nlat,z_t_150,time] mmol/m3/s (caco3 formation from eco - assume this is particulate)

# do not use these because they result in continual growth of the pool; I am not sure how to use the other two rate variables to balance these
# dissolved organic carbon has production and remineralization, nlon,nlat,z_t,time; mmol/m3/s
# DOC_prod[nlon,nlat,z_t,time] mmol/m3/s (DOC production)
# DOC_remin[nlon,nlat,z_t,time] mmol/m3/s (DOC remineralization)

# dissolved organic carbon has a stock variable (in addition to production and remineralization)
# DOC[nlon,nlat,z_t,time] mmol/m3

# inorganic carbon; nlon,nlat,z_t,time; mmol/m3:
# DIC, dissolved inorganic carbon, includes CO2STAR, HCO3, CO3)
# H2CO3 (carbonic acid), HCO3 (bicarbonate), CO3 (carbonate)
# total column (no z_t dim): CO2STAR (CO2 aq plus H2CO3), not sure what DCO2STAR is, other than maybe a derivative or difference

# DIC surface gas flux; nlon,nlat,time; mmol/m2 . cm/s
# FG_CO2

# also atmospheric co2, ppmv:
# ATM_CO2[nlon, nlat, time]
#
# output values are:
#  cumulative per month or year for carbon fluxes (Pg/mm or Pg/yy) (just the carbon)
#  monthly or annual average for carbon stocks (Pg) (just the carbon)
#  monthly or annual average ocean surface global atmospheric co2 (ppmv)
#
# Note:
#  there is only one output each for the particulate organic carbon and caco3 variables
#   this is because the variables are fluxes that need to be combined to estimate a stock
#
# Note:
#  i do not think that the co2star outputs are correct/representative
#   co2star carbon is an order of magnitude smaller than the H2CO3 carbon, and the DIC carbon variables sum nearly to DIC carbon
#
# can store only ~50 monthly grids, so store only one at a time
#
# also output a csv file of the plotted annual data
#


# this takes ~35 minutes per year on edison login node

cat("started plot_pop_carbon.r", date(), "\n\n")

library(ncdf4)

MAXFOR <- FALSE

##### in file

# MONTHLY = TRUE means that there are monthly history files
# MONTHLY = FALSE means that there are history files every 3 months
MONTHLY = TRUE

inname = "iESM85_coupled"

base_name = "b.e11.BRCP85C5BPRP.f09_g16.iESM_coupled.001.pop.h."

casearch1 = "/pic/projects/iESM/rcp85_results/b.e11.BRCP85C5BPRP.f09_g16.iESM_coupled.001/"

datadir1 = paste0(casearch1, "ocn/hist/")

outdir = "/pic/scratch/d3x132/carbon_output/"

ntag = ".nc"

start_year = 2006
end_year = 2010

##### reference file

refname = "iesm85_uncoupled"

ref_name = "b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001.pop.h."

refarch = "/pic/projects/iESM/rcp85_results/b.e11.BRCP85C5BPRP.f09_g16.iESM_uncoupled.001/"
refdir = paste0(refarch, "ocn/hist/")

pdfout = paste(outdir, base_name, start_year, "-", end_year, "_vs_", refname, ".pdf", sep = "")
csvout = paste(outdir, base_name, start_year, "-", end_year, "_vs_", refname, ".csv", sep = "")

# this script accommodates only whole years
# files could be monthly or every 3 months
end_month = 12
if(MONTHLY) {
	start_month = 1
	num_files = 12
	# days per "month"
	dayspermonth = c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
	# seconds per "month"
	secpermonth = 86400 * dayspermonth
	ymlab = "month"
} else {
	start_month = 3
	num_files = 4
	# days per "month"
	dayspermonth = c(90, 91, 92, 92)
	# seconds per "month"
	secpermonth = 86400 * dayspermonth
	ymlab = "3 months"
}

num_years = end_year - start_year + 1
tot_months = num_years * num_files

# days per year
daysperyear = sum(dayspermonth)

# the variables have to be grouped

# ecosystem carbon and caco3, mmol/m3
var_names_eco = c("spC", "diatC", "zooC", "diazC", "spCaCO3")
num_eco_vars = 5
ind_eco_vars = c(1:num_eco_vars)

# particulate organic carbon process, mmol/m3 . cm/s (flux) and mmol/m3/s (prod)
var_names_part_c = c("POC_FLUX_IN", "POC_PROD")
num_part_c_vars = 2
ind_part_c_vars = c((num_eco_vars+1):(num_eco_vars+num_part_c_vars))
poc_flux_ind = num_eco_vars + 1
poc_prod_ind = num_eco_vars + 2

# calcium carbonate particulate process, mmol/m3 . cm/s (flux) and mmol/m3/s (prod and eco form)
var_names_part_caco3 = c("CaCO3_FLUX_IN", "CaCO3_PROD", "CaCO3_form")
num_part_caco3_vars = 3
ind_part_caco3_vars = c((num_eco_vars+num_part_c_vars+1):(num_eco_vars+num_part_c_vars+num_part_caco3_vars))
caco3_flux_ind = num_eco_vars + num_part_c_vars + 1
caco3_prod_ind = num_eco_vars + num_part_c_vars + 2
caco3_form_ind = num_eco_vars + num_part_c_vars + 3

# dissolved organic carbon stock, mmol/m3
var_names_doc = c("DOC")
num_doc_vars = 1
ind_doc_vars = c((num_eco_vars+num_part_c_vars+num_part_caco3_vars+1):(num_eco_vars+num_part_c_vars+num_part_caco3_vars+num_doc_vars))
#doc_remin_ind = num_eco_vars+num_part_c_vars+num_part_caco3_vars+2

# inorganic carbon stocks, mmol/m3
var_names_dic = c("DIC", "H2CO3", "HCO3", "CO3", "CO2STAR", "DCO2STAR")
num_dic_vars = 6
ind_dic_vars = c((num_eco_vars+num_part_c_vars+num_part_caco3_vars+num_doc_vars+1):(num_eco_vars+num_part_c_vars+num_part_caco3_vars+num_doc_vars+num_dic_vars))
co2star_ind = num_eco_vars + num_part_c_vars + num_part_caco3_vars + num_doc_vars + 5
dco2star_ind = num_eco_vars + num_part_c_vars + num_part_caco3_vars + num_doc_vars + 6

# surface co2 flux, mmol/m2 . cm/s
var_names_surface = c("FG_CO2")
num_surf_vars = 1
ind_surf_vars = c((num_eco_vars+num_part_c_vars+num_part_caco3_vars+num_doc_vars+num_dic_vars+1):(num_eco_vars+num_part_c_vars+num_part_caco3_vars+num_doc_vars+num_dic_vars+num_surf_vars))

# atmos co2 concentration, ppmv
var_names_atmos = c("ATM_CO2")
num_atmos_vars = 1
ind_atmos_vars = c((num_eco_vars+num_part_c_vars+num_part_caco3_vars+num_doc_vars+num_dic_vars+num_surf_vars+1):(num_eco_vars+num_part_c_vars+num_part_caco3_vars+num_doc_vars+num_dic_vars+num_surf_vars+num_atmos_vars))

num_vars = num_eco_vars + num_part_c_vars + num_part_caco3_vars + num_doc_vars + num_dic_vars + num_surf_vars + num_atmos_vars
var_names = c(var_names_eco, var_names_part_c, var_names_part_caco3, var_names_doc, var_names_dic, var_names_surface, var_names_atmos)

# the particulate and doc variables are summed and stored in their last variable slot
num_plot_vars = num_eco_vars + 1 + 1 + num_doc_vars + num_dic_vars + num_surf_vars + num_atmos_vars
ind_plot_vars = c(ind_eco_vars, poc_prod_ind, caco3_form_ind, num_doc_vars, ind_dic_vars, ind_surf_vars, ind_atmos_vars)
plot_var_names = c(var_names_eco, "particulate_org_C", "particulate_CaCO3", var_names_doc, var_names_dic, var_names_surface, var_names_atmos)

# most are stock outputs
ylabs = c(rep("PgC avg for",num_eco_vars+2), rep("PgC avg for",num_doc_vars+num_dic_vars), "PgC flux per", "ppmv avg for")

# convert grams to Pg
g2Pg = 1E-15

# convert kilograms to Pg
kg2Pg = 1E-12

# convert from km^2 to m^2
kmsq2msq = 1E6

# convert from cm^2 to m^2
cmsq2msq = 0.0001

# convert from cm to m
cm2m = 0.01

# convert from mmol to mol
mmol2mol = 1E-3

# convert from Kelvin to Celsius
K2C = -273.15

# convert from vmr to ppmv
vmr2ppmv = 1E6

# surface area of earth in m^2
# based on authalic radius, which is spherical radius that have same surface area as the reference ellipsoid, which is wgs84
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
num_lon = nc_id$dim$nlon$len
num_lat = nc_id$dim$nlat$len
num_time = nc_id$dim$time$len
num_z_t = nc_id$dim$z_t$len
num_z_t_150m = nc_id$dim$z_t_150m$len
dz = ncvar_get(nc_id, varid = "dz", start = c(1), count = c(num_z_t))
TLONG = ncvar_get(nc_id, varid = "TLONG", start = c(1,1), count = c(num_lon,num_lat))
TLAT = ncvar_get(nc_id, varid = "TLAT", start = c(1,1), count = c(num_lon,num_lat))
TAREA = ncvar_get(nc_id, varid = "TAREA", start = c(1,1), count = c(num_lon,num_lat))
z_t = ncvar_get(nc_id, varid = "z_t", start = c(1), count = c(num_z_t))
z_t_150m = ncvar_get(nc_id, varid = "z_t_150m", start = c(1), count = c(num_z_t_150m))
nc_close(nc_id)

# arrays for storing 1 month of time series of (time, lat, lon) variables
grid_vardata = array(dim=c(num_vars, num_lon, num_lat, num_z_t, 1))
grid_refdata = array(dim=c(num_vars, num_lon, num_lat, num_z_t, 1))
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

# arrays for storing the particulate stocks
grid_part_c_vardata = array(dim=c(num_lon, num_lat, num_z_t))
grid_part_c_refdata = array(dim=c(num_lon, num_lat, num_z_t))
grid_part_caco3_vardata = array(dim=c(num_lon, num_lat, num_z_t))
grid_part_caco3_refdata = array(dim=c(num_lon, num_lat, num_z_t))
grid_doc_vardata = array(dim=c(num_lon, num_lat, num_z_t))
grid_doc_refdata = array(dim=c(num_lon, num_lat, num_z_t))
grid_part_c_vardata[,,] = 0.0
grid_part_c_refdata[,,] = 0.0
grid_part_caco3_vardata[,,] = 0.0
grid_part_caco3_refdata[,,] = 0.0
grid_doc_vardata[,,] = 0.0
grid_doc_refdata[,,] = 0.0

# loop over year
yind = 0
for (y in start_year:end_year) {
	yind = yind + 1
	cat("starting year", y, date(), "\n")
	# loop over month
	for (mind in 1:num_files) {
		mlabs = start_month * c(1:num_files)
		if(mlabs[mind] > 9) {
			mtag = mlabs[mind]
		}else {
			mtag = paste(0, mlabs[mind], sep = "")
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
		totmind = (y - start_year) * num_files + mind
		
		# loop over eco variables, mmol/m3
		for (vind in ind_eco_vars) {
			
			grid_vardata[vind,,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t_150m, num_time))
			grid_refdata[vind,,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t_150m, num_time))
			
			# vertical integration - replace layer 1 with the column value
			for (i in 1:num_lon) {
				for (j in 1:num_lat) {
					grid_vardata[vind,i,j,1,1] = TAREA[i,j] * cmsq2msq * sum(grid_vardata[vind,i,j,,1] * dz * cm2m, na.rm = TRUE)
					grid_refdata[vind,i,j,1,1] = TAREA[i,j] * cmsq2msq * sum(grid_refdata[vind,i,j,,1] * dz * cm2m, na.rm = TRUE)
				}
			}
			
			# sum for global value
			glb_vardata[vind, totmind] = sum(grid_vardata[vind,,,1,1], na.rm = TRUE)
			glb_refdata[vind, totmind] = sum(grid_refdata[vind,,,1,1], na.rm = TRUE)
			
			# convert to Pg C
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] * mmol2mol * g2Pg * mm_c
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] * mmol2mol * g2Pg * mm_c
			
			# sum montlhy values to calc annual average stock
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			
			# calc the annual stock/temperature averages at the end of each year,
			# and get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
			
		} # end loop over eco variables
		
		# loop over particulate orgainic carbon variables, mmol/m3 . cm/s (flux) and mmol/m3/s (prod)
		for (vind in ind_part_c_vars) {

			grid_vardata[vind,,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
			grid_refdata[vind,,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
			
			# convert each value to the molar rate per month
			if (vind == poc_flux_ind) {
				for (i in 1:num_lon) {
					for (j in 1:num_lat) {
						grid_vardata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_vardata[vind,i,j,,1] * cm2m * secpermonth[mind]
						grid_refdata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_refdata[vind,i,j,,1] * cm2m * secpermonth[mind]
					}
				}
				# update the current state of particulate carbon amount per cell, mmol
				grid_part_c_vardata[,,] = grid_part_c_vardata[,,] + grid_vardata[vind,,,,1]
				grid_part_c_refdata[,,] = grid_part_c_refdata[,,] + grid_refdata[vind,,,,1]
				# subtract the flux into the cell below (flux out), as these are sinking particles
				# need to deal with the bottom layer; and set NA fluxes to zero for the flux out to include the lowest valid level in the calcs
				temp_grid_vardata = grid_vardata[vind,,,,1]
				temp_grid_refdata = grid_refdata[vind,,,,1]
				temp_grid_vardata[,,1:(num_z_t-1)] = temp_grid_vardata[,,2:num_z_t]
				temp_grid_refdata[,,1:(num_z_t-1)] = temp_grid_refdata[,,2:num_z_t]
				temp_grid_vardata[,,num_z_t] = 0.0
				temp_grid_refdata[,,num_z_t] = 0.0
				temp_na_inds = which(is.na(temp_grid_vardata))
				temp_grid_vardata[temp_na_inds] = 0.0
				temp_na_inds = which(is.na(temp_grid_refdata))
				temp_grid_refdata[temp_na_inds] = 0.0
				grid_part_c_vardata[,,] = grid_part_c_vardata[,,] - temp_grid_vardata[,,]
				grid_part_c_refdata[,,] = grid_part_c_refdata[,,] - temp_grid_refdata[,,]
			}
			
			# this is the last variable so complete the calcs here
			if (vind == poc_prod_ind) {
				for (i in 1:num_lon) {
					for (j in 1:num_lat) {
						grid_vardata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_vardata[vind,i,j,,1] * dz * cm2m * secpermonth[mind]
						grid_refdata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_refdata[vind,i,j,,1] * dz * cm2m * secpermonth[mind]
					}
				}
				
				# update the current state of particulate carbon stock per cell, mmol
				grid_part_c_vardata[,,] = grid_part_c_vardata[,,] + grid_vardata[vind,,,,1]
				grid_part_c_refdata[,,] = grid_part_c_refdata[,,] + grid_refdata[vind,,,,1]
			
				# sum for global value
				glb_vardata[vind, totmind] = sum(grid_part_c_vardata[,,], na.rm = TRUE)
				glb_refdata[vind, totmind] = sum(grid_part_c_refdata[,,], na.rm = TRUE)
			
				# convert to Pg C
				glb_vardata[vind, totmind] = glb_vardata[vind, totmind] * mmol2mol * g2Pg * mm_c
				glb_refdata[vind, totmind] = glb_refdata[vind, totmind] * mmol2mol * g2Pg * mm_c
				
				# sum montlhy values to calc annual average stock
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			
				# calc the annual stock/temperature averages at the end of each year,
				# and get the annual difference at the end of each year
				if (mind == end_month) { 
					glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
					glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
					glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
				}
			} # end if last part c var
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
			
		} # end loop over particulate organic carbon variables
			
		# loop over particulate caco3 variables, mmol/m3 . cm/s (flux) and mmol/m3/s (prod and eco form)
		for (vind in ind_part_caco3_vars) {

			# convert each value to the molar rate per month
			if (vind == caco3_flux_ind) {
				grid_vardata[vind,,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
				grid_refdata[vind,,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
				for (i in 1:num_lon) {
					for (j in 1:num_lat) {
						grid_vardata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_vardata[vind,i,j,,1] * cm2m * secpermonth[mind]
						grid_refdata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_refdata[vind,i,j,,1] * cm2m * secpermonth[mind]
					}
				}
				# update the current state of particulate carbon amount per cell, mmol
				grid_part_caco3_vardata[,,] = grid_part_caco3_vardata[,,] + grid_vardata[vind,,,,1]
				grid_part_caco3_refdata[,,] = grid_part_caco3_refdata[,,] + grid_refdata[vind,,,,1]
				# subtract the flux into the cell below (flux out), as these are sinking particles
				# need to deal with the bottom layer; and set NA fluxes to zero for the flux out to include the lowest valid level in the calcs
				temp_grid_vardata = grid_vardata[vind,,,,1]
				temp_grid_refdata = grid_refdata[vind,,,,1]
				temp_grid_vardata[,,1:(num_z_t-1)] = temp_grid_vardata[,,2:num_z_t]
				temp_grid_refdata[,,1:(num_z_t-1)] = temp_grid_refdata[,,2:num_z_t]
				temp_grid_vardata[,,num_z_t] = 0.0
				temp_grid_refdata[,,num_z_t] = 0.0
				temp_na_inds = which(is.na(temp_grid_vardata))
				temp_grid_vardata[temp_na_inds] = 0.0
				temp_na_inds = which(is.na(temp_grid_refdata))
				temp_grid_refdata[temp_na_inds] = 0.0				
				grid_part_caco3_vardata[,,] = grid_part_caco3_vardata[,,] - temp_grid_vardata[,,]
				grid_part_caco3_refdata[,,] = grid_part_caco3_refdata[,,] - temp_grid_refdata[,,]
			}
			
			if (vind == caco3_prod_ind) {
				grid_vardata[vind,,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
				grid_refdata[vind,,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
				for (i in 1:num_lon) {
					for (j in 1:num_lat) {
						grid_vardata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_vardata[vind,i,j,,1] * cm2m * secpermonth[mind]
						grid_refdata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_refdata[vind,i,j,,1] * cm2m * secpermonth[mind]
					}
				}
				# update the current state of particulate carbon amount per cell, mmol
				grid_part_caco3_vardata[,,] = grid_part_caco3_vardata[,,] + grid_vardata[vind,,,,1]
				grid_part_caco3_refdata[,,] = grid_part_caco3_refdata[,,] + grid_refdata[vind,,,,1]
			}
			
			# this is the last variable so complete the calcs here
			if (vind == caco3_form_ind) {
				grid_vardata[vind,,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t_150m, num_time))
				grid_refdata[vind,,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t_150m, num_time))
				for (i in 1:num_lon) {
					for (j in 1:num_lat) {
						grid_vardata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_vardata[vind,i,j,,1] * dz * cm2m * secpermonth[mind]
						grid_refdata[vind,i,j,,1] = TAREA[i,j] * cmsq2msq * grid_refdata[vind,i,j,,1] * dz * cm2m * secpermonth[mind]
					}
				}
				
				# update the current state of particulate carbon amount per cell, mmol
				grid_part_caco3_vardata[,,1:num_z_t_150m] = grid_part_caco3_vardata[,,1:num_z_t_150m] + grid_vardata[vind,,,1:num_z_t_150m,1]
				grid_part_caco3_refdata[,,1:num_z_t_150m] = grid_part_caco3_refdata[,,1:num_z_t_150m] + grid_refdata[vind,,,1:num_z_t_150m,1]
			
				# sum for global value
				glb_vardata[vind, totmind] = sum(grid_part_caco3_vardata[,,], na.rm = TRUE)
				glb_refdata[vind, totmind] = sum(grid_part_caco3_refdata[,,], na.rm = TRUE)
			
				# convert to Pg C
				glb_vardata[vind, totmind] = glb_vardata[vind, totmind] * mmol2mol * g2Pg * mm_c
				glb_refdata[vind, totmind] = glb_refdata[vind, totmind] * mmol2mol * g2Pg * mm_c
				
				# sum montlhy values to calc annual average stock
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			
				# calc the annual stock/temperature averages at the end of each year,
				# and get the annual difference at the end of each year
				if (mind == end_month) { 
					glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
					glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
					glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
				}
			} # end if last part caco3 var
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
			
		} # end loop over particulate caco3 variables
		
		# loop over dissolved orgainic carbon variables, mmol/m3
		for (vind in ind_doc_vars) {

			grid_vardata[vind,,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
			grid_refdata[vind,,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
			
			# vertical integration - replace layer 1 with the column molar content value
			for (i in 1:num_lon) {
				for (j in 1:num_lat) {
					grid_vardata[vind,i,j,1,1] = TAREA[i,j] * cmsq2msq * sum(grid_vardata[vind,i,j,,1] * dz * cm2m, na.rm = TRUE)
					grid_refdata[vind,i,j,1,1] = TAREA[i,j] * cmsq2msq * sum(grid_refdata[vind,i,j,,1] * dz * cm2m, na.rm = TRUE)
				}
			}
			
			# sum for global value
			glb_vardata[vind, totmind] = sum(grid_vardata[vind,,,1,1], na.rm = TRUE)
			glb_refdata[vind, totmind] = sum(grid_refdata[vind,,,1,1], na.rm = TRUE)
			
			# convert to Pg C
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] * mmol2mol * g2Pg * mm_c
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] * mmol2mol * g2Pg * mm_c
			
			# sum montlhy values to calc annual average stock
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			
			# calc the annual stock/temperature averages at the end of each year,
			# and get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
			
		} # end loop over dissolved organic carbon variables
		
		# loop over inorganic carbon variables, mmol/m3
		for (vind in ind_dic_vars) {
			
			if (vind != co2star_ind && vind != dco2star_ind) {
				grid_vardata[vind,,,,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
				grid_refdata[vind,,,,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1,1), count = c(num_lon, num_lat, num_z_t, num_time))
			
				# vertical integration - replace layer 1 with the column molar content value
				for (i in 1:num_lon) {
					for (j in 1:num_lat) {
						grid_vardata[vind,i,j,1,1] = TAREA[i,j] * cmsq2msq * sum(grid_vardata[vind,i,j,,1] * dz * cm2m, na.rm = TRUE)
						grid_refdata[vind,i,j,1,1] = TAREA[i,j] * cmsq2msq * sum(grid_refdata[vind,i,j,,1] * dz * cm2m, na.rm = TRUE)
					}
				}
			} else { # end vertically resolved dic
				# co2star and dco2star
				grid_vardata[vind,,,1,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
				grid_refdata[vind,,,1,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
				# calc the molar content
				grid_vardata[vind,,,1,1] = grid_vardata[vind,,,1,1] * TAREA[i,j] * cmsq2msq * sum(dz * cm2m, na.rm = TRUE)
				grid_refdata[vind,,,1,1] = grid_refdata[vind,,,1,1] * TAREA[i,j] * cmsq2msq * sum(dz * cm2m, na.rm = TRUE)
			} # end total column co2star
			
			# sum for global value
			glb_vardata[vind, totmind] = sum(grid_vardata[vind,,,1,1], na.rm = TRUE)
			glb_refdata[vind, totmind] = sum(grid_refdata[vind,,,1,1], na.rm = TRUE)
			
			# convert to Pg C
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] * mmol2mol * g2Pg * mm_c
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] * mmol2mol * g2Pg * mm_c
			
			# sum montlhy values to calc annual average stock
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			
			# calc the annual stock/temperature averages at the end of each year,
			# and get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
			
		} # end loop over inorganic carbon variables
		
		# loop over surface flux variables, mmol/m3 . cm/s (flux)
		for (vind in ind_surf_vars) {

			grid_vardata[vind,,,1,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			
			# convert each value to the molar rate per month
			for (i in 1:num_lon) {
				for (j in 1:num_lat) {
					grid_vardata[vind,i,j,1,1] = TAREA[i,j] * cmsq2msq * grid_vardata[vind,i,j,1,1] * cm2m * secpermonth[mind]
					grid_refdata[vind,i,j,1,1] = TAREA[i,j] * cmsq2msq * grid_refdata[vind,i,j,1,1] * cm2m * secpermonth[mind]
				}
			}
			
			# sum for global value
			glb_vardata[vind, totmind] = sum(grid_vardata[vind,,,1,1], na.rm = TRUE)
			glb_refdata[vind, totmind] = sum(grid_refdata[vind,,,1,1], na.rm = TRUE)
			
			# convert to Pg C
			glb_vardata[vind, totmind] = glb_vardata[vind, totmind] * mmol2mol * g2Pg * mm_c
			glb_refdata[vind, totmind] = glb_refdata[vind, totmind] * mmol2mol * g2Pg * mm_c
			
			# sum for annual flux
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] 
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind]
			
			# get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
			
		} # end loop over surface flux variables
		
		# loop over atmosphere conc variables, ppmv
		for (vind in ind_atmos_vars) {

			grid_vardata[vind,,,1,1] = ncvar_get(nc_id, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			grid_refdata[vind,,,1,1] = ncvar_get(nc_id_ref, varid = var_names[vind], start = c(1,1,1), count = c(num_lon, num_lat, num_time))
			
			# calc global ocean average
			valid_varinds = which(!is.na(grid_vardata[vind,,,1,1]))
			valid_refinds = which(!is.na(grid_refdata[vind,,,1,1]))
			glb_vardata[vind, totmind] = sum(grid_vardata[vind,,,1,1] * TAREA[,], na.rm = TRUE) / sum(TAREA[valid_varinds], na.rm = TRUE)
			glb_refdata[vind, totmind] = sum(grid_refdata[vind,,,1,1] * TAREA[,], na.rm = TRUE) / sum(TAREA[valid_refinds], na.rm = TRUE)
			
			# sum montlhy values to calc annual average value
			glbann_vardata[vind, yind] = glbann_vardata[vind, yind] + glb_vardata[vind, totmind] * dayspermonth[mind]
			glbann_refdata[vind, yind] = glbann_refdata[vind, yind] + glb_refdata[vind, totmind] * dayspermonth[mind]
			
			# calc the annual average at the end of each year,
			# and get the annual difference at the end of each year
			if (mind == end_month) { 
				glbann_vardata[vind, yind] = glbann_vardata[vind, yind] / daysperyear
				glbann_refdata[vind, yind] = glbann_refdata[vind, yind] / daysperyear
				glbann_diffdata[vind, yind] = glbann_vardata[vind, yind] - glbann_refdata[vind, yind]
			}
			
			# calculate monthly differences
			glb_diffdata[vind, totmind] = glb_vardata[vind, totmind] - glb_refdata[vind, totmind]
			
		} # end loop over atmos conc variables
		
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
		xlab = "Month", ylab = paste(ylabs[plotind], ymlab),
		ylim = c(ymin,ymax), mgp = c(2, 1, 0),
		type = "n")
	lines(x = c(1:tot_months), y = glb_vardata[vind,], lty = 1, col = "black")
	lines(x = c(1:tot_months), y = glb_refdata[vind,], lty = 2, col = "gray50")
	legend(x = "bottomleft", lty = c(1,2), col = c("black", "gray50"), legend = c(inname, refname))
	# month diff
	ptitle = paste(plot_var_names[plotind], "diff")
	plot(x = c(1:tot_months), y = glb_diffdata[vind,], xlab = "Month", ylab = paste(ylabs[plotind], ymlab), main = ptitle, sub = stitle, type = "l")

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

# particulatge organic carbon and CaCO3 stocks are stored in the last variable of their respective group

# write the global annual values to a csv file, via a data frame table
case = c(rep(inname, num_years), rep(refname, num_years))
year = rep(c(start_year:end_year), 2)
spC_PgC_avg = c(glbann_vardata[1,], glbann_refdata[1,])
diatC_PgC_avg = c(glbann_vardata[2,], glbann_refdata[2,])
zooC_PgC_avg = c(glbann_vardata[3,], glbann_refdata[3,])
diazC_PgC_avg = c(glbann_vardata[4,], glbann_refdata[4,])
spCaCO3C_PgC_avg = c(glbann_vardata[5,], glbann_refdata[5,])
particulate_oC_PgC_avg = c(glbann_vardata[7,], glbann_refdata[7,])
particulate_CaCO3_PgC_avg = c(glbann_vardata[10,], glbann_refdata[10,])
DOC_PgC_avg = c(glbann_vardata[11,], glbann_refdata[11,])
DIC_PgC_avg = c(glbann_vardata[12,], glbann_refdata[12,])
H2CO3_PgC_avg = c(glbann_vardata[13,], glbann_refdata[13,])
HCO3_PgC_avg = c(glbann_vardata[14,], glbann_refdata[14,])
CO3_PgC_avg = c(glbann_vardata[15,], glbann_refdata[15,])
CO2STAR_PgC_avg = c(glbann_vardata[16,], glbann_refdata[16,])
DCO2STAR_PgC_avg = c(glbann_vardata[17,], glbann_refdata[17,])
FG_CO2_PgCperyr_avg = c(glbann_vardata[18,], glbann_refdata[18,])
ATM_CO2_ppmv_avg = c(glbann_vardata[19,], glbann_refdata[19,])

df = data.frame(case, year, spC_PgC_avg, diatC_PgC_avg, zooC_PgC_avg, diazC_PgC_avg, spCaCO3C_PgC_avg, particulate_oC_PgC_avg, particulate_CaCO3_PgC_avg, DOC_PgC_avg, DIC_PgC_avg, H2CO3_PgC_avg, HCO3_PgC_avg, CO3_PgC_avg, CO2STAR_PgC_avg, DCO2STAR_PgC_avg, FG_CO2_PgCperyr_avg, ATM_CO2_ppmv_avg, stringsAsFactors=FALSE)
write.csv(df, csvout, row.names=FALSE)

cat("finished plot_pop_carbon.r", date(), "\n\n")
