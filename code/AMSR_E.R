library(rgdal)
library(gdalUtils)
library(raster)
library(terra)
library(mod)
library(data.table)
library(viridis)
library(ggplot2)
library(sf)
library(rhdf5)

m <- rast("./data/raw/AMSR/AMSR_E_L3_DailySnow_V09_20020619.hdf")
m24 <- rast("./data/raw/AMSR/AMSR_E_L3_DailySnow_V09_20020624.hdf")


cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")

plot(cz_shp)

plot(m)
plot(cz_shp, add = TRUE)

yalt <- crop(m, cz_shp)

rast_dt <- as.data.table(yalt, xy = TRUE)

cz_shp_sf <- st_as_sf(cz_shp)

ggplot(rast_dt) + 
  geom_tile(aes(x, y, fill = SWE_NorthernDaily)) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25)


rast_dt2 <- as.data.table(m, xy = TRUE)
# ggplot(rast_dt2) + 
#   geom_tile(aes(x, y, fill = SWE_NorthernDaily)) + 
#   geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25)


rast_dt24 <- as.data.table(m24, xy = TRUE)
summary(rast_dt24)

# swe <- subset(m, 1)
# plot(swe)
# rast_dt <- as.data.table(swe, xy = TRUE)
# writeRaster(swe, "swe_2019.tif")


ggplot(rast_dt2 [SWE_NorthernDaily <= 480]) + 
  geom_tile(aes(x, y, fill = SWE_NorthernDaily)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "red", size = 0.25)

#convert the shapefile into data's projection

cz_shp <- readOGR("./data/shape_file/Czech/Export_czwgs84.shp")

crs(m, proj=TRUE)

cz_lae <- spTransform(cz_shp, crs(m, proj=TRUE))

ggplot(rast_dt2 [SWE_NorthernDaily <= 480]) + 
  geom_tile(aes(x, y, fill = SWE_NorthernDaily)) + 
  scale_fill_viridis(direction = -1) + 
  geom_path(data = cz_sin, 
          aes(x = long, y = lat, group = group))