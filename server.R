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
#adr <- readOGR("shapefiles/map3.shp")
# adr2 <- adr[adr$MAP_ID == 2, ]
# x = as.character(adr2$AREA_LB_0)
# adr2$AREA_LB_0 = as.factor(x)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
  output$arrivals <- renderTable({
            map_input = as.integer(input$map_choice)
            month_input = as.integer(input$month)
            ### here we create the aggregated dataset with the arrivals to use to draw the map
            aggregated_inputs <- get_input_by_adr(dataframe = raw_io_min, map_value = map_input, kpi_value = "arrivals", month_selected = month_input, threshold = 0)     
            aggregated_inputs$arrivals <- as.integer(aggregated_inputs$arrivals)
            aggregated_inputs$percentage <- paste(round(aggregated_inputs$percentage,3)*100, "%")
            names(aggregated_inputs)[2] = "ingressi"
            names(aggregated_inputs)[3] = "adr"
            names(aggregated_inputs)[4] = "percentuale"            
            # aggregated_inputs %>% rename(
            #           ingressi = arrivals,
            #           adr = adr_name,
            #           percentuale = percentage
            # )
            aggregated_inputs <- aggregated_inputs[, c(2, 3, 4)]
            aggregated_inputs <- head(aggregated_inputs[])          
            }) 
  
  output$areas <- renderLeaflet({
    
    map_input = as.integer(input$map_choice)
    month_input = as.integer(input$month)
    input_threshold = as.numeric(input$threshold/100)
    print(input_threshold)
    
    ### here we create the aggregated dataset with the arrivals to use to draw the map
    aggregated_inputs <- get_input_by_adr(dataframe = raw_io_min, map_value = map_input, kpi_value = "arrivals", month_selected = month_input, threshold = input_threshold)
    
    ## now we add the arrivals to the adr map
    adr <- adr[adr$MAP_ID == map_input, ]
    adr_levels = as.character(adr$AREA_LB_0)
    adr$AREA_LB_0 = as.factor(adr_levels)
    adr$arrivals <- sapply(adr$AREA_LB_0, function(x) aggregated_inputs$filtered_arrivals[aggregated_inputs$adr_name == x])
    adr <- adr[adr$arrivals > 0, ]
    ### here we define colours
#    reds <- colorRampPalette(brewer.pal(9, "Reds"))(10)
    #pal <- colorNumeric(reds[3:10], domain = adr$filtered_arrivals)
    #adr <- adr[adr$arrivals > 0, ]
    #top_values <- sort(adr$arrivals, decreasing = T)[1:16]
    pal <- colorNumeric(
      palette = brewer.pal(n=9, "PuBuGn")[3:9],
      domain = NULL)

    #pal <- colorBin("Blues", 4, pretty = F)
    
#    qpal <- colorQuantile("Blues", c(min(top_values), max(top_values)), n = 4)
    
    m <- leaflet(data = adr) %>% setView(lng=8.981, lat=40.072, zoom=8) %>% addTiles() %>%
              addPolygons(layerId = adr, color = "#444444", weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 1, fillColor = ~pal(arrivals),
                          highlightOptions = highlightOptions(color = "white", weight = 2,
                                                              bringToFront = TRUE), label = paste(adr$AREA_LB_0, ":", adr$arrivals), labelOptions = labelOptions(clickable = FALSE, noHide = FALSE)) %>%
              addLegend("bottomright", pal = pal, values = ~arrivals, title = "ingressi", opacity = 1)
              
    m
  })
  
})
