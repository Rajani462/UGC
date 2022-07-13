library(rgdal)
library(gdalUtils)
library(raster)
library(terra)
library(data.table)
library(viridis)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(sf)
library(gsubfn)


# import, crop and save into data.table formats ---------------------------


amsr_files <- list.files("./data/raw/AMRS_monthly/AMSR_E_L3/", pattern = ".hdf$", full.names = TRUE) %>% as.list()

#files <- file_name[1:3]

amsr <- lapply(amsr_files, sapply, rast)
amsr_nh <- lapply(amsr, sapply, function(x) subset(x, 1)) # subset the SWE only for Northern hemisphere

cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")
amsr_cz <- lapply(amsr_nh, sapply, function(x) crop(x, cz_shp))

unls_amsr_cz <- unlist(amsr_cz)
amsr_cz_dt <- lapply(unls_amsr_cz, function(a) as.data.table(a, xy = TRUE))

#date

date_dt <- ym(strapplyc(amsr_files[[1]], "(\\d+)\\.", simplify = TRUE))
dates <- lapply(amsr_files, function(x) ym(strapplyc(x, "(\\d+)\\.", simplify = TRUE)))
amsr_swe <- mapply(cbind, amsr_cz_dt, "date"=dates, SIMPLIFY=F)

amsr_swe_dt <- rbindlist(amsr_swe)

# SWE values are scaled down by a factor of 2 when stored in the HDF-EOS file (0-240). 
# Users must multiply the values by 2 to scale the data up to the correct range of 0-480 mm
# source file:///E:/UGC_project/UGC/docs/MULTI_AE_DySno-V002-UserGuide.pdf
# https://nsidc.org/data/AE_DySno/versions/2

amsr_swe_dt <- amsr_swe_dt[, .(x, y, z = date, value = SWE_NorthernMonth * 2, name = factor('amsr'))]

saveRDS(amsr_swe_dt, './data/database/amsr_swe.Rds')


############################################################################################


# spatial mean

amsr_swe_cz <- readRDS('./data/database/amsr_swe.Rds')
cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")

### temporal plot ot time series plot

amsr_mean <- amsr_swe_cz[, .(mean_value = mean(value)), by = .(z)]

ggplot(amsr_mean, aes(z, mean_value)) + 
  geom_line()


### spatial plot

amsr_spatial <- amsr_swe_cz[, .(mean_value = mean(value)), by = .(x, y)]

cz_shp_sf <- st_as_sf(cz_shp)

ggplot(amsr_spatial) + 
#ggplot(amsr_swe_cz[z == "2004-01-01"]) + 
  geom_tile(aes(x, y, fill = mean_value)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25)




# import and ploting single file over Czech Repubic -----------------------


mon <- rast("./data/raw/AMRS_monthly/AMSR_E_L3/AMSR_E_L3_MonthlySnow_V09_200206.hdf")

swe_nh <- subset(mon, 1)
swe_nh_dt <- as.data.table(swe_nh, xy = TRUE)

cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")

plot(cz_shp)

plot(mon)
plot(cz_shp, add = TRUE)

yalt <- crop(mon, cz_shp)

rast_dt <- as.data.table(yalt, xy = TRUE)
summary(rast_dt)

cz_shp_sf <- st_as_sf(cz_shp)

ggplot(rast_dt) + 
  geom_tile(aes(x, y, fill = SWE_NorthernMonth)) + 
  scale_fill_viridis(direction = -1) #+ 
#geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25)


rast_dtmon <- as.data.table(mon, xy = TRUE)

rast_dt24 <- as.data.table(m24, xy = TRUE)
summary(rast_dt24)



summary(rast_dtmon)

ggplot(rast_dtmon[SWE_NorthernMonth <= 240]) + 
  geom_tile(aes(x, y, fill = SWE_NorthernMonth)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "red", size = 0.25)



# tryiing tp convert projection from LEAE to Geographic lon lat

yalt
yalt_rast <- raster(yalt)
r <-projectRaster(yalt_rast,
                  crs=crs("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
mon_rast <- raster(mon)

crs(mon_rast)
projection(mon_rast)
newproj <- "+proj=longlat +datum=WGS84"
pr2 <- projectRaster(mon_rast, crs=newproj)

project(mon, "EPSG:4326", method = "near", gdal = FALSE)


new = st_crs(4326)
mon_star <- st_as_stars(mon_rast)
y <- st_transform(mon_star, new)
