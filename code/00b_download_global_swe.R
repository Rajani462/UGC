###########################
library(getPass)
library(dplyr)
library(stringr)
library(xml2)
library(RCurl)
library(XML)
library(stringr)
library(plyr)
library(rvest)
library(curl)
###############


# download global snow (snow water equivalent) products(version 2.1) in nc.gz format -----------------------------

download_swe_v2 <- function(destination, start_year, end_year){
  if (!is.character(destination)) stop ("destination should be a character string.")
  if (!(is.numeric(start_year) & is.numeric(end_year))) stop ("start_year and end_year should be numeric.")
  if ((!any(start_year == 1979:2016)) | (!any(end_year == 1979:2016)) | !(end_year >= start_year)){
    stop("Error: start_year and end_year should be between 2000-2020, and end_year should be greater or equal to start_year")
  }
  # username <- getPass("Enter the username: ") %>% URLencode(reserved = TRUE)
  # password <- getPass("Enter the password: ") %>% URLencode(reserved = TRUE)
  for (year in start_year:end_year){
    
      base_url <- paste0("https://www.globsnow.info/swe/archive_v2.0/", year, "/L3B_monthly_SWE/")
      page <- read_html(base_url)
      raw_list <- page
      links <- html_nodes(raw_list, "a") %>% 
        html_attr("href") %>% 
        str_subset("\\.gz")
  
      file_url_base <- paste0("https://www.globsnow.info/swe/archive_v2.0/", year, "/L3B_monthly_SWE/")
      
      url_download <- str_c(file_url_base, links)
      for (i in seq_along(url_download)) {
        fname <- str_c(destination, links[i])
        if (!file.exists(fname)) {
          download.file(url_download[i], fname, mode = "wb")
          #Sys.sleep(1)
        }
      }
  }
  
}

## For vesrsion_3

download_swe_v3 <- function(destination, start_year, end_year){
  if (!is.character(destination)) stop ("destination should be a character string.")
  if (!(is.numeric(start_year) & is.numeric(end_year))) stop ("start_year and end_year should be numeric.")
  if ((!any(start_year == 1979:2018)) | (!any(end_year == 1979:2018)) | !(end_year >= start_year)){
    stop("Error: start_year and end_year should be between 2000-2020, and end_year should be greater or equal to start_year")
  }
  # username <- getPass("Enter the username: ") %>% URLencode(reserved = TRUE)
  # password <- getPass("Enter the password: ") %>% URLencode(reserved = TRUE)
  for (year in start_year:end_year){
    
    base_url <- paste0("https://www.globsnow.info/swe/archive_v3.0/L3B_monthly_SWE/NetCDF4/")
    page <- read_html(base_url)
    raw_list <- page
    links <- html_nodes(raw_list, "a") %>% 
      html_attr("href") %>% 
      str_subset("\\.nc")
    
    file_url_base <- paste0("https://www.globsnow.info/swe/archive_v3.0/L3B_monthly_SWE/NetCDF4/")
    
    url_download <- str_c(file_url_base, links)
    for (i in seq_along(url_download)) {
      fname <- str_c(destination, links[i])
      if (!file.exists(fname)) {
        download.file(url_download[i], fname, mode = "wb")
        #Sys.sleep(1)
      }
    }
  }
  
}


###########

# Download the dataests ---------------------------------------------------


destin <- "./data/raw/global_swe/"


download_swe_v3(destin, 1979, 2018)

##################

library()
