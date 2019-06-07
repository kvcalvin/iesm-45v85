# *************************************************
# * This script calculates differences between different
# * simulations to decompose the contribution of 
# * socioeconomics, climate policy, and human-Earth system feedbacks
# * to changes in emissions and LULCC.
# *************************************************
print("********* Running 10-Decomposition.R *******************")

source( "../Header.R" )

# Read Data
co2_summary <- read.csv( "../3-analyze/3.co2_summary.csv" )
land_summary <- read.csv( "../3-analyze/4.land_summary.csv" )

# Filter for the right years
co2_summary %>%
  filter(year %in% IAM_years_to_plot) ->
  co2_summary

land_summary %>%
  filter(year %in% IAM_years_to_plot) ->
  land_summary

# Rename scenarios
co2_summary %>%
  filter(IAM == "GCAM") %>%
  rename(climate.policy = tax) %>%
  mutate(socioeconomics = scenario,
         scen_name = paste(socioeconomics, feedbacks, climate.policy),
         scen_name = if_else(scen_name == "rcp45 NO YES", "Uncoupled45", scen_name),
         scen_name = if_else(scen_name == "rcp45 YES YES", "Coupled45", scen_name),
         scen_name = if_else(scen_name == "rcp45 NO NO", "Socio45_noClimatePolicy", scen_name),
         scen_name = if_else(scen_name == "rcp85 NO YES", "Socio85_withClimatePolicy", scen_name),
         scen_name = if_else(scen_name == "rcp85 NO NO", "Uncoupled85", scen_name),
         scen_name = if_else(scen_name == "rcp85 YES NO", "Coupled85", scen_name)) ->
  co2_summary

land_summary %>%
  filter(region == "WORLD") %>%
  rename(climate.policy = tax) %>%
  mutate(socioeconomics = ref_scen,
         scen_name = paste(socioeconomics, feedbacks, climate.policy),
         scen_name = if_else(scen_name == "RCP45 NO YES", "Uncoupled45", scen_name),
         scen_name = if_else(scen_name == "RCP45 YES YES", "Coupled45", scen_name),
         scen_name = if_else(scen_name == "RCP45 NO NO", "RCP45 Socioeconomics without Climate Policy", scen_name),
         scen_name = if_else(scen_name == "RCP85 NO YES", "RCP85 Socioeconomics with Climate Policy", scen_name),
         scen_name = if_else(scen_name == "RCP85 NO NO", "Uncoupled85", scen_name),
         scen_name = if_else(scen_name == "RCP85 YES NO", "Coupled85", scen_name)) ->
  land_summary

# Calculate difference from certain baselines 
# First, calculate difference due to socioeconomics (remove feedbacks cases, as we don't have comparable comparisons)
co2_summary %>%
  filter(socioeconomics == "rcp85", feedbacks == "NO") %>%
  select(scen_name, feedbacks, climate.policy, year, value, unit) %>%
  rename(ref_co2 = value,
         ref_scenname = scen_name) ->
  co2_rcp85

co2_summary %>%
  filter(feedbacks == "NO") %>%
  select(socioeconomics, feedbacks, climate.policy, scen_name, year, value, unit) %>%
  left_join(co2_rcp85, by=c("year", "feedbacks", "climate.policy", "unit")) %>%
  mutate(delta_co2 = value - ref_co2,
         scenario = paste(scen_name, " - ", ref_scenname)) %>%
  select(-value, -ref_co2) ->
  co2_socio

land_summary %>%
  filter(socioeconomics == "RCP85", feedbacks == "NO") %>%
  select(scen_name, category, feedbacks, climate.policy, year, land) %>%
  rename(ref_land = land,
         ref_scenname = scen_name) ->
  land_rcp85

land_summary %>%
  filter(feedbacks == "NO") %>%
  select(category, socioeconomics, feedbacks, climate.policy, scen_name, year, land) %>%
  left_join(land_rcp85, by=c("category", "year", "feedbacks", "climate.policy")) %>%
  mutate(delta_land = land - ref_land,
         scenario = paste(scen_name, " - ", ref_scenname)) %>%
  select(-land, -ref_land) ->
  land_socio

# Next, calculate difference due to climate policy
co2_summary %>%
  filter(climate.policy == "NO", feedbacks == "NO") %>%
  select(scen_name, feedbacks, socioeconomics, year, value, unit) %>%
  rename(ref_co2 = value,
         ref_scenname = scen_name) ->
  co2_notax

co2_summary %>%
  filter(feedbacks == "NO") %>%
  select(socioeconomics, feedbacks, climate.policy, scen_name, year, value, unit) %>%
  left_join(co2_notax, by=c("year", "feedbacks", "socioeconomics", "unit")) %>%
  mutate(delta_co2 = value - ref_co2,
         scenario = paste(scen_name, " - ", ref_scenname)) %>%
  select(-value, -ref_co2) ->
  co2_tax

land_summary %>%
  filter(climate.policy == "NO", feedbacks == "NO") %>%
  select(scen_name, category, feedbacks, socioeconomics, year, land) %>%
  rename(ref_land = land,
         ref_scenname = scen_name) ->
  land_notax

land_summary %>%
  filter(feedbacks == "NO") %>%
  select(category, socioeconomics, feedbacks, climate.policy, scen_name, year, land) %>%
  left_join(land_notax, by=c("category", "year", "feedbacks", "socioeconomics")) %>%
  mutate(delta_land = land - ref_land,
         scenario = paste(scen_name, " - ", ref_scenname)) %>%
  select(-land, -ref_land) ->
  land_tax

# Next, calculate difference due to human-Earth feedbacks
co2_summary %>%
  filter(feedbacks == "NO", variant == "default") %>%
  select(scen_name, climate.policy, socioeconomics, year, value, unit) %>%
  rename(ref_co2 = value,
         ref_scenname = scen_name) ->
  co2_nofdbks

co2_summary %>%
  filter(variant == "default") %>%
  select(socioeconomics, feedbacks, climate.policy, scen_name, year, value, unit) %>%
  left_join(co2_nofdbks, by=c("year", "climate.policy", "socioeconomics", "unit")) %>%
  mutate(delta_co2 = value - ref_co2,
         scenario = paste(scen_name, " - ", ref_scenname)) %>%
  select(-value, -ref_co2) ->
  co2_feedbacks

land_summary %>%
  filter(feedbacks == "NO", variant == "default") %>%
  select(scen_name, category, climate.policy, socioeconomics, year, land) %>%
  rename(ref_land = land,
         ref_scenname = scen_name) ->
  land_nofdbks

land_summary %>%
  filter(variant == "default") %>%
  select(category, socioeconomics, feedbacks, climate.policy, scen_name, year, land) %>%
  left_join(land_nofdbks, by=c("category", "year", "climate.policy", "socioeconomics")) %>%
  mutate(delta_land = land - ref_land,
         scenario = paste(scen_name, " - ", ref_scenname)) %>%
  select(-land, -ref_land) ->
  land_feedbacks

# Remove cases where ref_scen = scen
co2_socio %>%
  filter(scen_name != ref_scenname) ->
  co2_socio
land_socio %>%
  filter(scen_name != ref_scenname) ->
  land_socio
co2_tax %>%
  filter(scen_name != ref_scenname) ->
  co2_tax
land_tax %>%
  filter(scen_name != ref_scenname) ->
  land_tax
co2_feedbacks %>%
  filter(scen_name != ref_scenname) ->
  co2_feedbacks
land_feedbacks %>%
  filter(scen_name != ref_scenname) ->
  land_feedbacks

# Separate cropland and forest
crop_socio <- land_socio %>% filter(category == "Cropland")
forest_socio <- land_socio %>% filter(category == "Non-commercial Forest")
crop_tax <- land_tax %>% filter(category == "Cropland")
forest_tax <- land_tax %>% filter(category == "Non-commercial Forest")
crop_feedbacks <- land_feedbacks %>% filter(category == "Cropland")
forest_feedbacks <- land_feedbacks %>% filter(category == "Non-commercial Forest")

# Print all data to file
write.table( crop_socio, "10.crop_socio.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( crop_tax, "10.crop_tax.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( crop_feedbacks, "10.crop_feedbacks.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( forest_socio, "10.forest_socio.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( forest_tax, "10.forest_tax.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( forest_feedbacks, "10.forest_feedbacks.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( co2_socio, "10.co2_socio.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( co2_tax, "10.co2_tax.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( co2_feedbacks, "10.co2_feedbacks.csv", sep=",", col.names=T, row.names=F, append=F )
