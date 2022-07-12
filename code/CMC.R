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

######################

data <- fread("./data/raw/cmc_swe_mly_1998to2020_v01.2/cmc_swe_mly_1998to2020_v01.2.txt")

data_dt <- as.data.table(data)














cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")




read.table("F:/UGC_project/Marketa/CMC/sddepth_monthly/cmc_sdepth_mly_1998_v01.2.txt")

read.table("F:/UGC_project/Marketa/CMC/sddepth_monthly/cmc_sdepth_mly_1998_v01.2/cmc_sdepth_mly_1998_v01.2.txt",  
           header = TRUE)
