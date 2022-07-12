require(mha)
require(lubridate)
require(stringr)
setwd('/home/hanel/DSP/sadaf/hydro/data/geo/')

d = dir(patt = 'shp')

bas = readOGR(d[1])
bas = bas[length(bas),]
bas$ID = gsub('mask_|\\.shp','', d[1])
for (i in d[2:length(d)]){
  ii = readOGR(i)
  ii = ii[length(ii),]
  ii$ID = gsub('mask_|\\.shp','', i)
  bas = rbind(bas, ii)
}
rownames(bas@data) = bas$ID
bas = spChFIDs(bas, bas$ID)


### grdc

allids = bas$ID #DTA[, unique(GRDCno)]

da = data.table(unzip('/home/owc/GRDC/Data/grdcdat_day.zip', list = TRUE))
da[, GRDCno := substr(Name, 1, 7)]
#da[GRDCno %in% allids][, Name]

file.remove(dir('/home/owc/GRDC/Data/extract/',full.names = TRUE))
unzip('/home/owc/GRDC/Data/grdcdat_day.zip', files = da[GRDCno %in% allids][, Name], exdir = '/home/owc/GRDC/Data/extract/')

gg = mapply(fread, dir('/home/owc/GRDC/Data/extract/', full.names = TRUE), SIMPLIFY = FALSE)
names(gg) = gsub('\\.day', '', dir('/home/owc/GRDC/Data/extract/'))
gg = rbindlist(gg, idcol = 'GRDCno')
gg[, Q := ifelse(Calculated>=0, Calculated, Original)]
gg[, GRDCno := as.numeric(GRDCno)]

i = dir('/home/owc/GRDC/Data/extract/', full.names = TRUE)[1]

nfo = mapply( function(i){
  r = readLines(i, n = 20)
  nfo = r[c(9, 15)]
  nfo = str_replace_all(nfo, "[^([:alnum:]+[:punct:])]", " ")
  nfo = sapply(strsplit(nfo, ':'), function(x)as.numeric(x[2]))
  return(data.table(GRDCno = nfo[1], A = nfo[2]))
  
}, dir('/home/owc/GRDC/Data/extract/', full.names = TRUE), SIMPLIFY = FALSE)

nfo = rbindlist(nfo)

gg = nfo[gg, on = 'GRDCno']
gg[, R:= (Q * 60 * 60 * 24)/(A * 1000)]
setnames(gg, 'YYYY-MM-DD', 'DTM')


mo = data.table(unzip('/home/owc/GRDC/Data/grdcdat_mon.zip', list = TRUE))
mo[, GRDCno := substr(Name, 1, 7)]
#mo[GRDCno %in% allids]

file.remove(dir('/home/owc/GRDC/Data/extract/',full.names = TRUE))
unzip('/home/owc/GRDC/Data/grdcdat_mon.zip', files = mo[GRDCno %in% allids][, Name], exdir = '/home/owc/GRDC/Data/extract/')

mgg = mapply(fread, dir('/home/owc/GRDC/Data/extract/', full.names = TRUE), SIMPLIFY = FALSE)
names(mgg) = gsub('\\.mon', '', dir('/home/owc/GRDC/Data/extract/'))
mgg = rbindlist(mgg, idcol = 'GRDCno')
mgg[, Q := ifelse(Calculated>=0, Calculated, Original)]
mgg[, GRDCno := as.numeric(GRDCno)]

#i = dir('/home/owc/GRDC/Data/extract/', full.names = TRUE)[1]

nfo = mapply( function(i){
  r = readLines(i, n = 20)
  nfo = r[c(9, 15)]
  nfo = str_replace_all(nfo, "[^([:alnum:]+[:punct:])]", " ")
  nfo = sapply(strsplit(nfo, ':'), function(x)as.numeric(x[2]))
  return(data.table(GRDCno = nfo[1], A = nfo[2]))
  
}, dir('/home/owc/GRDC/Data/extract/', full.names = TRUE), SIMPLIFY = FALSE)

nfo = rbindlist(nfo)

mgg = nfo[mgg, on = 'GRDCno']
setnames(mgg, 'YYYY-MM-DD', 'DTM')
mgg[, DTM := as.Date(gsub('-00', '-01', DTM))]

mgg[, R:= (Q * 60 * 60 * 24 * days_in_month(DTM))/(A * 1000)]
mgg = mgg[,. (GRDCno, DTM, Q, R)]
mgg = mgg[year(DTM)<1975]

gg = gg[, .(DTM = DTM[1], Q = mean(Q), R = sum(R)), by = .(GRDCno, year(DTM), month(DTM))]
gg[, c('year', 'month') := NULL]
gg[, DTM := as.Date(DTM)]
G = rbind(mgg, gg)
G = G[GRDCno %in% G[, year(min(DTM)) < 1871, by = GRDCno][V1==TRUE]$GRDCno]

# to convert monthly data into seasonal
G[, mon := month(DTM)]
G[, season := 'wi']
G[mon>3, season := 'sp']
G[mon>6, season := 'su']
G[mon>9, season := 'au']
G[, mon := NULL]
G = G[, .(DTM = DTM[1], Q = mean(Q), R = sum(R)), by = .(year(DTM), GRDCno, season)]
G[R < 0, R:= NA]
G[, year:=NULL]