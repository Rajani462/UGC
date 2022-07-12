
library(rgdal)
library(gdalUtils)
library(raster)
library(mod)
library(data.table)
library(viridis)
library(terra)
library(rhdf5)
library(data.table)

#To open a NASA HDF file, use get_subdatasets() with path to the file name.
gdal_translate("./data/raw/AMSR/AMSR_E_L3_DailySnow_V09_20020619.hdf", sds=TRUE, verbose=TRUE)

sds <- get_subdatasets("./data/raw/AMSR/AMSR_E_L3_DailySnow_V09_20020619.hdf")
str(sds)
a <- raster::brick(sds[1])
plot(a)

plot(sds)


# sr <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0' 
# 
# projected_raster <- projectRaster(a, crs = sr)
# 
# DF <-  as.data.frame(sds, xy=TRUE)
# DF

sp::proj4string(a) <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
raster::extent(a) <- c(-180, 180, -50, 50)

DF <-  as.data.frame(a, xy=TRUE, long = TRUE, na.rm = TRUE)
DF

DF2 <-  as.data.frame(projected_raster, xy=TRUE, long = TRUE, na.rm = TRUE)
DF2 <- as.data.table(DF2)

DF3 <- DF2[, .(x, y, value)]

DF2

require(maptools) 

myproj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
shape <- readShapeSpatial("./data/shape_file/Czech/SPH_KRAJ.shp", proj4string = CRS(sr))

#plot(r <- raster(listVI[200]))
plot(projected_raster)
plot(shape)

ggplot(DF3) +
  geom_raster(aes(x, y, fill = value)) + 
  coord_fixed(ratio = 1) + 
  scale_fill_viridis(direction = -1) + 
  labs(x = "Longitude", y = "Latitude", fill = "mm/yr") + 
  #facet_wrap(~name, ncol = 2) + 
  ggtitle("Annual total mean precipitation (mm/yr)") + 
  theme_bw() + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  geom_path(data = shape, 
            aes(x = long, y = lat, group = group))



