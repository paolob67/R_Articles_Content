# Require some libs
library(ggplot2)
library(rworldmap)
library(ggmap)
library(mapview)

# Set working directory
setwd("~/Documents/2018/Article R/01")

# Get data from INGV
today <- as.character(Sys.Date())
thecall <- paste("curl 'http://webservices.ingv.it/fdsnws/event/1/query?starttime=2005-04-01T00%3A00%3A00&endtime=",today,"T23%3A59%3A59&minmag=2&maxmag=10&mindepth=-10&maxdepth=1000&minlat=35&maxlat=49&minlon=5&maxlon=20&minversion=100&orderby=time-asc&format=text&limit=10000' -o ./ingv.csv", sep = "")
system(thecall)

# Create data frame
ingv <- read.csv("./ingv.csv", sep="|")

# Show head of data frame
head(ingv)

# create a with rworldmap to display events from INGV 
therwmap <- getMap(resolution = "low")
png("./therwmap.png")
plot(therwmap, xlim = range(ingv$Longitude), ylim = range(ingv$Latitude))
points(ingv$Longitude,ingv$Latitude, col = "red", cex = .6)
dev.off()

# create a map with ggmap to display events got from INGV
bbox <- make_bbox(range(ingv$Longitude),range(ingv$Latitude), f = 0.05)
theggmap <- get_map(bbox)
jpeg("./theggmap.jpg", width = 1024, height = 1024)
theggmapplot <- ggmap(theggmap) + geom_point(aes(x = Longitude, y = Latitude, size = Magnitude), data = ingv, alpha = .5)
theggmapplot
dev.off()
