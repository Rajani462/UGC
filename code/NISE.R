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

m <- rast("./data/raw/NISE/NISE_SSMISF18_20161201.HDFEOS")


cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")

plot(cz_shp)

plot(m)
plot(cz_shp, add = TRUE)

north_hemisp <- m[[1:2]] #subset the northen hemisphere
plot(north_hemisp)

north_hemisp_dt <- as.data.table(north_hemisp, xy = TRUE)
summary(north_hemisp_dt)
##  crop to Czech Repubic

yalt <- crop(north_hemisp, cz_shp)

# yalt_ext <- crop(north_hemisp$Extent, cz_shp)
# yalt_ext_dt <- as.data.table(yalt_ext, xy = TRUE)
# 
# yalt_age <- crop(north_hemisp$Age, cz_shp)
# as.data.table(yalt_age, xy = TRUE)

rast_dt <- as.data.table(yalt, xy = TRUE)
summary(rast_dt)

cz_shp_sf <- st_as_sf(cz_shp)

ggplot(rast_dt) + 
  geom_tile(aes(x, y, fill = Age)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25)

ggplot(rast_dt) + 
  geom_tile(aes(x, y, fill = Extent)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25)

####################################################################################


rast_dtmon <- as.data.table(mon, xy = TRUE)

rast_dt24 <- as.data.table(m24, xy = TRUE)
summary(rast_dt24)

swe <- subset(m, 1)
plot(swe)
rast_dt <- as.data.table(swe, xy = TRUE)
writeRaster(swe, "swe_2019.tif")

summary(rast_dtmon)

ggplot(rast_dtmon[SWE_NorthernMonth <= 240]) + 
  geom_tile(aes(x, y, fill = SWE_NorthernMonth)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "red", size = 0.25)
