source('./source/libs.R')
source('./source/themes.R')
source('./source/palettes.R')


# read the raw datasets ---------------------------------------------------


globsnow_swe_cz <- readRDS('./data/database/globsnow_swe_wgs84.Rds')
cz_shp <- readOGR("./data/shape_file/Czech/SPH_KRAJ.shp")

### temporal plot or time series plot

globsnow_mean <- globsnow_swe_cz[, .(mean_value = mean(value)), by = .(z)]

ggplot(globsnow_mean, aes(z, mean_value)) + 
  geom_line() + 
  labs(x = "Time", y = "SWE (mm)") + 
  theme_generic

ggsave("results/figures/swe_globsnow_timeseries_wgs84.png",
       width = 8.2, height = 5.3, units = "in", dpi = 600)

### spatial plot

globsnow_spatial <- globsnow_swe_cz[, .(mean_value = mean(value)), by = .(x, y)]

cz_shp_sf <- st_as_sf(cz_shp)

ggplot(globsnow_spatial) + 
#ggplot(globsnow_swe_cz[z == "2004-01-01"]) + 
  geom_tile(aes(x, y, fill = mean_value)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25) + 
  # geom_polygon(data = name_shp,
  #              aes(x = long, y = lat, group = group), fill = NA, colour = "blue", size = 0.25) + 
  labs(x = "Longitude", y = "Latitude", fill = "SWE (mm)") + 
  theme_small

ggsave("results/figures/swe_globsnow_spatil_wgs84.png",
       width = 8.2, height = 5.3, units = "in", dpi = 600)

##########################################################################################

