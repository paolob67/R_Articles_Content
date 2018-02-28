# Require some libs
library(reshape2)
library(plyr)
library(dplyr)
library(ggplot2)
library(ggmap)

# Set working directory
setwd("~/Documents/2018/Article R/02")


# Get data from ARPA Lazio
# set the url and curl call for the file
# this file has geoloc of stations http://www.arpalazio.net/main/aria/doc/RQA/locRQA.txt
fileurl <- "http://www.arpalazio.net/main/aria/sci/basedati/chimici/BDchimici/RM/DatiOrari/RM_PM10_2017.txt"
thecall <- paste("curl '", fileurl, "' -o RM_PM10_2017.txt", sep = "")
# get it
system(thecall)


# Read PM10 data in a raw data frame
# to load with static station names uncomment the following ... 
# stations =  c("Preneste", "Francia", "Magna Grecia", "Cinecitta", "Colleferro Oberdan", "Colleferro Europa", "Allumiere", "Civitavecchia", "Guidonia", "Ada", "Guido", "Cavaliere", "Ciampino", "Fermi", "Bufalotta", "Cipro", "Tiburtina", "Arenula", "Malagrotta", "Civitavecchia Porto", "CV-Villa Albani", "CV-Via Morandi", "CV-Via Roma","Fiumicino Porto", "Fiumicino Villa Guglielmi")
# PM10_raw <- read.csv("RM_PM10_2017.txt", sep = "", col.names = c("day", "hour", stations))


# Read PM10 data in a raw data frame
# load raw data in PM10 data frame
PM10_raw <- read.csv("RM_PM10_2017.txt", sep = "")
# let's change the column names to something meaningful
# load stations names in data frame for lookup from local csv file created from pdf available online
stations_df <- read.csv("stations.csv")
# plot stations
bbox <- make_bbox(range(stations_df$Longitude, na.rm = TRUE),range(stations_df$Latitude, na.rm = TRUE), f = 0.05)
thestationsmap <- get_map(bbox)
jpeg("./thestationsmap.jpg", width = 1024, height = 1024)
thestationsmapplot <- ggmap(thestationsmap) + geom_point(aes(x = Longitude, y = Latitude), data = stations_df, col = "red")
thestationsmapplot
dev.off()
# get station codes from factors of the raw data
stations_hd <- data.frame(Station.Code = names(PM10_raw)[3:length(names(PM10_raw))])
# perform lookup of stations names and set them im raw data
stations_hd <- merge(stations_df, stations_hd, by = "Station.Code", sort = FALSE)
# set a vector of the correct station names
stations <- c("day", "hour", as.vector(stations_hd$Station.Name))
# update data frame
colnames(PM10_raw) <- stations


# Tidy up the PM10 data frame
PM10_tidy <- melt(PM10_raw, id.vars = c("day", "hour"), variable.name = "station", value.name = "PM10level")

# Keep empty observations by setting to NA values
PM10_tidy$PM10level[PM10_tidy$PM10level == -999] <- NA

# Show values for stations
jpeg("./pm10onstations2017.jpg", width = 1024, height = 1024)
ggplot(PM10_tidy, aes(station, PM10level)) + geom_boxplot(fill = "red") + theme_bw()
dev.off()

# Show mean PM10 levels throughout the year
PM10_mean <- PM10_tidy %>%
  group_by(day) %>%
  summarise(PM10mean = mean(PM10level, na.rm = TRUE))

jpeg("./pm10mean2017.jpg", width = 1024, height = 1024)
ggplot(data = PM10_mean, aes(x = day, y = PM10mean)) + geom_area( fill = "red" ) + theme_bw() 
dev.off()
