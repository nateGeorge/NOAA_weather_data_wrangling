# data munging to get no-NA data.tables of Manhattan (Central Park) and La Guardia
# daily weather data from NOAA

library(data.table)
library(fasttime)
library(DMwR)

#' Loads NOAA weather data from filename.
#'
#' \code{load.noaa.data} returns a data.table of ready-to-go weather data
#' 
#' The default columns were chosen to minimize missing values.
#' The default start date was chosen because that's the earliest date 
#' WDF2 and WDF5 are available for Manhattan/La Guardia data.
#' This could be made much more general to handle other columns, etc.
#' 
#' @param filepath A string that gives the filepath to the .csv file
#' @param keep.cols A character vector that gives the columns to be kept in the returned data.table.
#' @return A data.table with ready-to-go-data.
#' 
#' 
load.noaa.data <- function(filepath,
                           keep.cols = c('NAME', 'DATE', 'TMAX', 'TMIN', 'PRCP', 'SNOW', 'WDF2', 'WDF5'),
                           start.date = fastPOSIXct('1995-11-01')){
  dt <- fread(filepath)
  dt[, DATE:=fastPOSIXct(DATE)]
  if (!is.null(columns)) {
    dt <- dt[, keep.cols, with = FALSE]
  }
  if ('WDF2' %in% columns) {
    dt[, WDF2:=as.integer(WDF2)]
  }
  if ('WDF5' %in% columns) {
    dt[, WDF5:=as.integer(WDF5)]
  }
  if (!is.null(start.date)) {
    dt <- dt[DATE >= start.date]
  }
  return(dt)
}

filepath <- '/home/nate/github/NOAA_weather_data_wrangling/laguardia_and_manhattan.csv'
small.dt.latest <- load.noaa.data(filepath)

# separate data into manhattan and la guardia
manhattan <- small.dt.latest[NAME %like% 'CENTRAL PARK']
la.guardia <- small.dt.latest[NAME %like% 'LA GUARDIA']
manhattan[, NAME:=NULL]
la.guardia[, NAME:=NULL]

# check to make sure dates are continuous
all(diff(manhattan[order(DATE), DATE]) == 1)
all(diff(la.guardia[order(DATE), DATE]) == 1)
summary(manhattan)
summary(la.guardia)

# merge together to prepare for filling in missing values
both <- merge(manhattan, la.guardia, by = 'DATE', suffixes = c('.mh', '.lg'))
summary(both)

# fill in missing values with DMwR
both[, date.epoch := as.numeric(DATE)]
filled <- knnImputation(subset(both, select = -DATE))
summary(filled)
filled[, DATE:=both$DATE]
filled[, date.epoch:=NULL]
summary(filled)

# get separate data.tables and rename columns
manhattan.filled <- filled[, grep('.mh', colnames(filled)), with = FALSE]
new.colnames <- gsub(pattern = ".mh", replacement = "", x  = colnames(manhattan.filled))
colnames(manhattan.filled) <- new.colnames
summary(manhattan.filled)

la.guardia.filled <- filled[, grep('.lg', colnames(filled)), with = FALSE]
new.colnames <- gsub(pattern = ".lg", replacement = "", x  = colnames(la.guardia.filled))
colnames(la.guardia.filled) <- new.colnames
summary(la.guardia.filled)

# export data
fwrite(manhattan.filled, '/home/nate/github/NOAA_weather_data_wrangling/manhattan-data.csv')
fwrite(la.guardia.filled, '/home/nate/github/NOAA_weather_data_wrangling/laguardia-data.csv')
