
# priorly projected to from LEAE to WGS84 using ArcGIS --------------------

source('./source/libs.R')


globsnow_files <- list.files("./data/database/database/globswe_monthly_projected/", pattern = ".tif$", full.names = TRUE) %>% as.list()
cz_shp <- readOGR("./data/shape_file/Czech/SPH_KRAJ.shp")

globsnow <- lapply(globsnow_files, sapply, rast)

globsnow_cz <- lapply(globsnow, sapply, function(x) crop(x, cz_shp))

unls_globsnow_cz <- unlist(globsnow_cz)
globsnow_cz_dt <- lapply(unls_globsnow_cz, function(a) as.data.table(a, xy = TRUE))

## create a time series (dates form the files)

date_dt <- ym(strapplyc(globsnow_files[[1]], "(\\d+)\\_", simplify = TRUE))
dates <- lapply(globsnow_files, function(x) ym(strapplyc(x, "(\\d+)\\_", simplify = TRUE)))
globsnow_swe <- mapply(cbind, globsnow_cz_dt, "date"=dates, SIMPLIFY=F)

globsnow_swe_dt <- rbindlist(globsnow_swe)

# SWE values are scaled down by a factor of 2 when stored in the HDF-EOS file (0-240). 
# Users must multiply the values by 2 to scale the data up to the correct range of 0-480 mm
# source file:///E:/UGC_project/UGC/docs/MULTI_AE_DySno-V002-UserGuide.pdf
# https://nsidc.org/data/AE_DySno/versions/2

globsnow_swe_dt <- globsnow_swe_dt[, .(x, y, z = date, value = X197901_northern_hemisphere_monthly_swe_0.25grid, 
                                       name = factor('amsr'))]


saveRDS(globsnow_swe_dt, './data/database/globsnow_swe_wgs84.Rds')



########################################################################################


# with the original projection(LAEA) --------------------------------------

source('./source/libs.R')


# function to read and convert the nc files into data.table ---------------


data_swe <- function(file, shp){
  snow_dat <- rast(file)
  snow_dat <- subset(snow_dat, 1) #subset the North_SWE(first layer)
  snow_crop <- crop(snow_dat, shp)
  snow_dt <- as.data.table(snow_crop, xy = TRUE)
  
  dates <- ym(strapplyc(file, "[/](.*)[_]", simplify = TRUE)) #extract dates from file name in yearmonth format
  
  snow_dt <- cbind(snow_dt, dates)
  #colnames(snow_dt) <- c("lon", "lat", "swe", "date")
  snow_dt <- snow_dt[, .(x, y, z = dates, value = swe, name = factor("globsnow"))]
  
  return(snow_dt)
  
}

################

# read the raw nc files and save the output data.table as .RDS ------------


files <- list.files("./data/raw/global_swe/", pattern = ".nc$", full.names = TRUE)
cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")


swe_list <- lapply(files, function(i) data_swe(i, cz_shp))
globsnow_swe_dt <- rbindlist(swe_list)

saveRDS(globsnow_swe_dt, './data/database/globsnow_swe.Rds')