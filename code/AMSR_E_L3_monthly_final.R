#lod the libraries
library(rgdal)
library(gdalUtils)
library(raster)
library(terra)
library(mod)
library(data.table)
library(viridis)
library(ggplot2)
library(sf)
library(gsubfn)
library(lubridate)

######################

data_swe <- function(file, shp){
  snow_dat <- rast(file)
  snow_dat <- subset(snow_dat, 1) #subset the North_SWE(first layer)
  snow_crop <- crop(snow_dat, shp)
  snow_dt <- as.data.table(snow_crop, xy = TRUE)
  
  dates <- ym(strapplyc(file, "(\\d+)\\.", simplify = TRUE)) #extract dates from file name in yearmonth format
    
  snow_dt <- cbind(snow_dt, dates)
  colnames(snow_dt) <- c("lon", "lat", "swe", "date")
  
  return(snow_dt)
  
}

################

files <- list.files("./data/raw/AMRS_monthly/AMSR_E_L3/", pattern = ".hdf$", full.names = TRUE)

#files <- file_name[1:3]
cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")


swe_list <- lapply(files, function(i) data_swe(i, cz_shp))
swe_dt <- rbindlist(swe_list)

swe_plot <- swe_dt[, .(sum_swe = sum(swe), month = month(date)), by = date]


ggplot(swe_plot, aes(factor(month), sum_swe, group = month)) + 
  geom_boxplot()

ggplot(swe_plot, aes(date, sum_swe)) + 
  geom_line() + 
  geom_point()
