library(ggplot2)
library(rgdal)
library(gdalUtils)
library(raster)
library(mod)
library(data.table)
library(viridis)

#To open a NASA HDF file, use get_subdatasets() with path to the file name.


sds <- get_subdatasets("./data/raw/MYD/MYD10A2.A2006017.h19v03.006.2016063041358.hdf")
str(sds)
a <- raster::brick(sds)
plot(a)




sr <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0' 

projected_raster <- projectRaster(a, crs = sr)

DF <-  as.data.frame(r, xy=TRUE)
DF

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



