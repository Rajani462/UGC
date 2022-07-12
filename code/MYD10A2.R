library(rgdal)
library(gdalUtils)
library(raster)
library(terra)
library(mod)
library(data.table)
library(viridis)
library(ggplot2)
library(sf)
#library(rhdf5)

h19 <- rast("./data/raw/MYD/MYD10A2.A2006017.h19v03.006.2016063041358.hdf")
h18 <- rast("./data/raw/MYD/MYD10A2.A2002185.h18v03.006.2016153165752.hdf")
h18v4 <- rast("./data/raw/MYD/MYD10A2.A2002185.h18v04.006.2016153165752.hdf")



mos <- mosaic(h18, h19, h18v4)

plot(mos)

cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")

plot(cz_shp)

plot(h18)
plot(cz_shp, add = TRUE)

yalt <- crop(mos, cz_shp)

rast_dt <- as.data.table(yalt, xy = TRUE)

cz_shp_sf <- st_as_sf(cz_shp)

ggplot(rast_dt) + 
  geom_tile(aes(x, y, fill = SWE_NorthernMonth)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25)

######################################################################################

file_name <- list.files("D:/UGC_project/Marketa/MYD/", pattern = ".hdf$", full.names = TRUE) %>% as.list()

files <- file_name[1:12]
list_file <- tapply(files, rep(1:(length(files)/4), each = 4), list)


dat1 <- lapply(list_file, sapply, rast)

dat2 <- lapply(dat1, sprc) #collect the spatRaster prior to mosaic

dat_mos <- lapply(dat2, mosaic)

to_plt <- dat_mos[[1]]

plot(to_plt)


#read the shapefile
cz_shp <- readOGR("./data/shape_file/Czech/Export_czwgs84.shp")

crs(to_plt, proj=TRUE)

cz_sin <- spTransform(cz_shp, crs(to_plt, proj=TRUE))

#plot togethr
plot(to_plt[[1]]) # plot first layer
plot(cz_sin, add = TRUE)

#crop
yalt <- crop(to_plt, cz_sin)

plot(yalt[[2]]) # plot first layer
plot(cz_sin, add = TRUE)
#convert into data.table and plot
snw_ext <- as.data.frame(yalt$Maximum_Snow_Extent, xy = TRUE)
summary(snw_ext)
table(snw_ext$Maximum_Snow_Extent)

snw_ext_dt <- as.data.table(snw_ext, xy = TRUE)

ggplot(snw_ext_dt) + 
  geom_tile(aes(x, y, fill = factor(Maximum_Snow_Extent))) + 
  scale_colour_discrete() + 
  #scale_fill_viridis(direction = -1) + 
  geom_path(data = cz_sin, 
            aes(x = long, y = lat, group = group)) + 
  theme_bw()


snw_cov <- as.data.frame(yalt$Eight_Day_Snow_Cover, xy = TRUE)
summary(snw_cov)
table(snw_cov$Eight_Day_Snow_Cover)

ggplot(snw_cov) + 
  geom_tile(aes(x, y, fill = factor(Eight_Day_Snow_Cover))) + 
  scale_colour_discrete() + 
  #scale_fill_viridis(direction = -1) + 
  geom_path(data = cz_sin, 
            aes(x = long, y = lat, group = group)) + 
  theme_bw()


###############################################################################################

