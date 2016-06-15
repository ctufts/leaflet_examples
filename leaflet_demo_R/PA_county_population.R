rm(list = ls())
library(dplyr)
library(leaflet)
library(rgdal)
library(tigris)
library(RColorBrewer)
library(ggplot2)
library(readr)
source('fte_theme.R')

county_counts <- read_csv('data/population.csv')

downloaddir<-getwd()
unzip('data/PA_Counties_clip.shp.zip', exdir=downloaddir, junkpaths=TRUE)

filename<-list.files(downloaddir, pattern=".shp", full.names=FALSE)
filename<-gsub(".shp", "", filename[1])

county_shapes<-readOGR(downloaddir, filename) 

pal <- colorNumeric(
  palette = "YlGn",
  domain = county_counts$total_pop
)

county_shapes <- geo_join(county_shapes, county_counts, by_sp="NAME" , by_df="NAME" )


# create map 
paHealth.map <- leaflet() %>%
  addProviderTiles('CartoDB.Positron') %>%
  setView(lng=-77.16048, lat=41.00000, zoom =7) %>%
  addPolygons(data = county_shapes,
              stroke = T, smoothFactor = 0.2, fillOpacity = 0.5,
              color = "#000000", weight = 2, 
              fillColor = ~pal(county_shapes$total_pop)
              # color = ~pal(states@data$DISTRICT_)
  )%>% 
  addLegend("bottomright", pal = pal, values = county_counts$total_pop,
            title = "County Population",
            opacity = 1
  )

paHealth.map