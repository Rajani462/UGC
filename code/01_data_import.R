#Import raw data 
source('./source/libraries.R')
source('./source/functions.R')


# read the datsets --------------------------------------------------------


studies <- fread('./data/raw/studies.csv', 
                 header = T, 
                 stringsAsFactors = T) #All strings should be factors (categorical variables)

hydrological <- fread('./data/raw/Hydrological_extremes.csv',
                      header = T,
                      stringsAsFactors = T)

studies_met <- fread('./data/raw/Metrices.csv', 
                     header = T, 
                     stringsAsFactors = T) 

studies_vers <- fread('./data/raw/Versions.csv', 
                      header = T, 
                      stringsAsFactors = T) 
#testing that are imported correctly

studies$id
str(studies)

saveRDS(studies, file = './data/studies.Rds')
saveRDS(hydrological, file = './data/hydrological.Rds')
saveRDS(studies_met, file = './data/studies_metrics.Rds')
saveRDS(studies_vers, file = './data/studies_vers.Rds')
