
# priorly projected to from LEAE to WGS84 using ArcGIS --------------------


source('./source/libs.R')

# import, crop and save into data.table formats ---------------------------


amsr_files <- list.files("./data/database/database/AMSR_monthly_projected/", pattern = ".tif$", full.names = TRUE) %>% as.list()
cz_shp <- readOGR("./data/shape_file/Czech/SPH_KRAJ.shp")

amsr <- lapply(amsr_files, sapply, rast)

amsr_cz <- lapply(amsr, sapply, function(x) crop(x, cz_shp))

unls_amsr_cz <- unlist(amsr_cz)
amsr_cz_dt <- lapply(unls_amsr_cz, function(a) as.data.table(a, xy = TRUE))

## create a time series (dates form the files)

date_dt <- ym(strapplyc(amsr_files[[1]], "(\\d+)\\.", simplify = TRUE))
dates <- lapply(amsr_files, function(x) ym(strapplyc(x, "(\\d+)\\.", simplify = TRUE)))
amsr_swe <- mapply(cbind, amsr_cz_dt, "date"=dates, SIMPLIFY=F)

amsr_swe_dt <- rbindlist(amsr_swe)

# SWE values are scaled down by a factor of 2 when stored in the HDF-EOS file (0-240). 
# Users must multiply the values by 2 to scale the data up to the correct range of 0-480 mm
# source file:///E:/UGC_project/UGC/docs/MULTI_AE_DySno-V002-UserGuide.pdf
# https://nsidc.org/data/AE_DySno/versions/2

amsr_swe_dt <- amsr_swe_dt[, .(x, y, z = date, value = AMSR_E_L3_MonthlySnow_V09_200206.hdf * 2, name = factor('amsr'))]

saveRDS(amsr_swe_dt, './data/database/amsr_swe_wgs84.Rds')


############################################################################################


# with the original projection(LAEA) --------------------------------------


source('./source/libs.R')

# import, crop and save into data.table formats ---------------------------


amsr_files <- list.files("./data/raw/AMRS_monthly/AMSR_E_L3/", pattern = ".hdf$", full.names = TRUE) %>% as.list()

#files <- file_name[1:3]

amsr <- lapply(amsr_files, sapply, rast)
amsr_nh <- lapply(amsr, sapply, function(x) subset(x, 1)) # subset the SWE only for Northern hemisphere

cz_shp <- readOGR("./data/shape_file/Czech/Export_czaele.shp")
amsr_cz <- lapply(amsr_nh, sapply, function(x) crop(x, cz_shp))

unls_amsr_cz <- unlist(amsr_cz)
amsr_cz_dt <- lapply(unls_amsr_cz, function(a) as.data.table(a, xy = TRUE))

## create a time series (dates form the files)

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
