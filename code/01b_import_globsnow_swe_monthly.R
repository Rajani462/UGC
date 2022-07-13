
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

########################################################################################
