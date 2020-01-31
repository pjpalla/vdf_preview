#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(leaflet)
library(rgdal)
library(plotly)
library(data.table)
library(dplyr)
library(htmltools)
library(crosstalk)
library(V8)
library(RColorBrewer)
#source("R/config.R")
#source("R/utility.R")
source("R/input_output.R")




raw_io_min = read.csv("kpi/io/io_data_min.csv")
mappings <- read.csv("mappings/multimap_ras.csv", sep = ";")
adr <- readOGR("shapefiles/MULTIMAP.shp")
adr2 <- adr[adr$MAP_ID == 2, ]
x = as.character(adr2$AREA_LB_0)
adr2$AREA_LB_0 = as.factor(x)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
  output$areas <- renderLeaflet({
    
    ### here we create the aggregated dataset with the arrivals to use to draw the map
    aggregated_inputs <- get_input_by_adr(dataframe = raw_io_min, map_value = 3, kpi_value = "arrivals", month_selected = 2)
    
    ## now we add the arrivals to the adr map
    adr <- adr[adr$MAP_ID == 3, ]
    adr_levels = as.character(adr$AREA_LB_0)
    adr$AREA_LB_0 = as.factor(adr_levels)
    adr$arrivals <- sapply(adr$AREA_LB_0, function(x) aggregated_inputs$arrivals[aggregated_inputs$adr_name == x])
    
    ### here we define colours
    reds <- colorRampPalette(brewer.pal(9, "OrRd"))(200)
    pal <- colorNumeric(reds[30:200], domain = adr$arrivals)
    
    
    m <- leaflet(data = adr) %>% setView(lng=8.981, lat=40.072, zoom=8) %>% addTiles() %>%
              addPolygons(layerId = adr$AREA_LB_0, color = "#444444", weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, fillColor = ~pal(arrivals),
                          highlightOptions = highlightOptions(color = "white", weight = 2,
                                                              bringToFront = TRUE), label = adr$AREA_LB_0, labelOptions = labelOptions(clickable = FALSE, noHide = FALSE))              
              
    m
  })
  
})
