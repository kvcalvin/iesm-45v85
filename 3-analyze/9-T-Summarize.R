# *************************************************
# * This script calculates temperature change due to 
# * coupling, including annual temperatures, smoothed
# * temperatures, and the residual between the two
# *************************************************
print("********* Running 9-T-Summarize.R *******************")

source( "../Header.R" )

# Read Data
all_temp_data <- read.csv( "../3-analyze/0.all_temp_data.csv" )

# Filter iESM results which will be plotted separately
all_temp_data %>% filter( model == "iESM" ) -> iesm.t.data

# Calculate change in temperature due to coupling
iesm.t.data %>%
  select(-base_temp, -change) %>%
  spread(feedbacks, temp) %>%
  mutate(delta = YES - NO, pct_delta = 100 * delta / NO) %>%
  select(-YES, -NO) ->
  iesm.t.coupling.data

# Smooth iESM temperature data and calculate residual for plotting
iesm.t.data %>%
  group_by(scenario, feedbacks) %>%
  mutate(fitted = fitted(lm( change ~ poly(year, 4, raw=TRUE)))) %>%
  ungroup() %>%
  mutate(residual = change - fitted) ->
  iesm.t.data.smooth

# Print all data to file
write.table( iesm.t.data, "9.iesm.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( iesm.t.coupling.data, "9.iesm_coupling.csv", sep=",", col.names=T, row.names=F, append=F )
write.table( iesm.t.data.smooth, "9.iesm_smooth.csv", sep=",", col.names=T, row.names=F, append=F )

