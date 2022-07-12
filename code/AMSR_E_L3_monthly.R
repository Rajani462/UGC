library(rgdal)
library(gdalUtils)
library(raster)
library(terra)
library(mod)
library(data.table)
library(viridis)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(sf)
library(stars)
library(gsubfn)

install.packages("remotes")
remotes::install_github("decisionpatterns/lubridate.tools")
library(lubridate.tools)

#library(rhdf5)

mon <- rast("./data/raw/AMRS_monthly/AMSR_E_L3/AMSR_E_L3_MonthlySnow_V09_200206.hdf")

gg <- ym(strapplyc(files[[1]], "(\\d+)\\.", simplify = TRUE))

time(mon) <- as.Date(gg)

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
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "blue", size = 0.25)


rast_dtmon <- as.data.table(mon, xy = TRUE)

rast_dt24 <- as.data.table(m24, xy = TRUE)
summary(rast_dt24)



summary(rast_dtmon)

ggplot(rast_dtmon[SWE_NorthernMonth <= 240]) + 
  geom_tile(aes(x, y, fill = SWE_NorthernMonth)) + 
  scale_fill_viridis(direction = -1) + 
  geom_sf(data = cz_shp_sf, fill = NA, colour = "red", size = 0.25)


############################################################################################

file_name <- list.files("./data/raw/AMRS_monthly/AMSR_E_L3/", pattern = ".hdf$", full.names = TRUE) %>% as.list()

files <- file_name[1:3]
#list_file <- tapply(files, rep(1:(length(files)/4), each = 4), list)


dat1 <- lapply(files, sapply, rast)

dat2 <- lapply(dat1, sapply, function(x) subset(x, 1)) #collect the spatRaster prior to mosaic

cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")

dat_crop <- lapply(dat2, sapply, function(x) crop(x, cz_shp))

# dat_as_dt <- lapply(dat_crop, function(a) unlist(as.data.table(a, xy = TRUE)))
# 
# lapply(dat_crop, sapply, as.data.table(i))
# 
# aa <- function(a){
#   class(a) <- "data.table"
#   as.data.table(a, xy = TRUE)
# }
# 
# lapply(dat_crop, aa)
# 
# lapply(dat_crop, function(i) as.data.table(i, xy = TRUE))
# 
# sapply(dat_crop, function(i) {i <- as.data.table(i)})
# 
# 
# as.data.table(rrapply(dat_crop, xy = TRUE, how = "list"))

unls_dat <- unlist(dat_crop)
dat_dt <- lapply(unls_dat, function(a) as.data.table(a, xy = TRUE))

#date

library(lubridate)
date_dt <- ym(strapplyc(files[[1]], "(\\d+)\\.", simplify = TRUE))

dates <- lapply(files, function(x) ym(strapplyc(x, "(\\d+)\\.", simplify = TRUE)))


lapply(dat_dt, function(i) setDT(i) [, date := ym(strapplyc(i, "(\\d+)\\.", simplify = TRUE))])

ex <- dat_dt[1]

cbind(dat_dt, dates)

dat_dt_list <- list(dat_dt)
unlis_dates <- unlist(dates)
mapply(cbind, dat_dt, dates)



#########################





