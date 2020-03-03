#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
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
source("R/overnight_stay.R")




raw_io_min = read.csv("kpi/io/io_data_min.csv")
overnight = read.csv("kpi/arrivals_attendances/pernottamenti_all.csv")
tot_inputs_by_user <- read.csv("kpi/io/tot_ingressi_per_user_type_mid.csv")
provenienze <- read.csv("kpi/io/provenienze_ita_str_max.csv")
mappings <- read.csv("mappings/multimap_ras.csv", sep = ";")
vod_sired_mappings <- read.csv("mappings/sired_vodafone_mappings.csv", sep=';')
sired_data <- read.csv("kpi/arrivals_attendances/dati_Gen-Giu_2019.csv", encoding = 'UTF-8')
#adr <- readOGR("shapefiles/MULTIMAP.shp")
adr <- readOGR("shapefiles/light_adr.shp")
mesi = c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno")
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
  
  output$arrivals <- renderPlotly({
            map_input = as.integer(input$map_choice1)
            month_input = as.integer(input$month)
            input_threshold = as.numeric(input$threshold/100)
            input_kpi = input$kpi
            print(input_kpi)
            mesi = c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno")
            
            ### here we create the aggregated dataset with the arrivals to use to draw the map
            aggregated_inputs <- get_input_by_adr(dataframe = raw_io_min, map_value = map_input, kpi_value = input_kpi, month_selected = month_input, threshold = input_threshold)     
            aggregated_inputs$arrivals <- as.integer(aggregated_inputs$arrivals)
            aggregated_inputs$percentage <- paste(round(aggregated_inputs$percentage,3)*100, "%", sep = '')
            
     
            names(aggregated_inputs)[2] = "ingressi"
            names(aggregated_inputs)[3] = "adr"
            names(aggregated_inputs)[4] = "percentuale"            
            # aggregated_inputs %>% rename(
            #           ingressi = arrivals,
            #           adr = adr_name,
            #           percentuale = percentage
            # )
            aggregated_inputs <- aggregated_inputs[, c(2, 3, 4)]
            #aggregated_inputs <- aggregated_inputs[order(aggregated_inputs$ingressi, decreasing = T), ]
            aggregated_inputs <- aggregated_inputs[1:10, ]
            adr_levels = as.character(aggregated_inputs$adr)
            aggregated_inputs$adr = factor(adr_levels, levels = rev(adr_levels), ordered = T)
            
            
            
            pal <- colorNumeric(
              palette = brewer.pal(n=9, "YlOrRd")[2:9],
              domain = NULL)
            selected_kpi = "Ingressi"
            
            if (input_kpi == "departures"){
              selected_kpi = "Uscite"
              pal <- colorNumeric(
                palette = brewer.pal(n=9, "YlGnBu")[2:9],
                domain = NULL)
            }
            
            p <- plot_ly(
              data = aggregated_inputs,
              y = ~adr,
              x = ~ingressi,
              type = "bar",
              orientation = 'h',
              marker = list(color = ~pal(ingressi),
                            line = list(color = "grey",
                                        width = 1.5)),
              text = ~paste(adr, ": ", percentuale, sep = ''),
              hoverinfo = 'text') %>% layout(title = paste(selected_kpi, " mese di ", mesi[month_input], ": Top AdR"), yaxis = list(title = "", tickfont = list(size = 9, color = 'black')), xaxis = list(title="Visitatori (%)", tickfont = list(size = 8)), margin = m)
            
            
            
            
            }) 
  
  output$areas <- renderLeaflet({
    
    map_input = as.integer(input$map_choice1)
    month_input = as.integer(input$month)
    input_threshold = as.numeric(input$threshold/100)
    input_kpi = input$kpi
    print(input_threshold)
    
    ### here we create the aggregated dataset with the arrivals to use to draw the map
    aggregated_inputs <- get_input_by_adr(dataframe = raw_io_min, map_value = map_input, kpi_value = input_kpi, month_selected = month_input, threshold = input_threshold)
    
    ## now we add the arrivals to the adr map
    adr <- adr[adr$MAP_ID == map_input, ]
    adr_levels = as.character(adr$AREA_LB_0)
    adr$AREA_LB_0 = as.factor(adr_levels)
    adr$arrivals <- sapply(adr$AREA_LB_0, function(x) aggregated_inputs$filtered_arrivals[aggregated_inputs$adr_name == x])
    adr <- adr[adr$arrivals > 0, ]
    ### here we define colours

    # pal <- colorNumeric(
    #   palette = brewer.pal(n=9, "PuBuGn")[3:9],
    #   #palette = brewer.pal(n = 9, "PuBuGn")[c(1, 3, 5, 7, 9)],
    #   domain = NULL)
    
    ### colors bin definition ##
    legend_title = "Ingressi"
    color_palette = "YlOrRd" 
    if (input_kpi == "departures"){
      color_palette = "YlGnBu"
      legend_title = "Uscite"
    }
    bins <- c(500, 2000, 3000, 4000, 4500, 5000, 6000, 7000, 10000, 15000, 20000, 25000, 30000, 60000, 65000, 150000)
    pal <- colorBin(color_palette, domain = adr$arrivals, bin = bins)

    
    m <- leaflet(data = adr) %>% setView(lng=8.981, lat=40.072, zoom=8) %>% addTiles() %>%
              addPolygons(layerId = adr, color = "#444444", weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 1, fillColor = ~pal(arrivals),
                          highlightOptions = highlightOptions(color = "white", weight = 2,
                                                              bringToFront = TRUE), label = paste(adr$AREA_LB_0, ":", adr$arrivals), labelOptions = labelOptions(clickable = FALSE, noHide = FALSE)) %>%
              addLegend("bottomright", pal = pal, values = ~arrivals, title = legend_title, opacity = 1)
              
    m
  })
  
  output$tot_users <- renderPlotly({
    mesi = c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno")
    month_input = as.integer(input$month)
    input_kpi = input$kpi
    selected_kpi = "Ingressi"
    tot_inputs_by_user <- tot_inputs_by_user %>% filter(month == month_input & kpi == input_kpi)
    colors = brewer.pal(9, "YlOrRd")[c(6,9,3)]
    
    if (input_kpi == "departures"){
      selected_kpi = "Uscite"
      colors = brewer.pal(9, "YlGnBu")[c(6,9,3)]
 
    }

    p <- plot_ly(tot_inputs_by_user, labels = ~user_type, values = ~tot, type = 'pie', textinfo = 'percent', hoverinfo = 'text',
                 text = ~tot, marker = list(colors = colors, line = list(color = '#FFFFFF', width = 1))) %>%
    layout(title = paste(selected_kpi, " mese di ", mesi[month_input], ": ripartizione visitatori", sep = ''), showlegend = T, margin = m)
    
  })
  
  output$accessi_str <- renderPlotly({
    month_input = as.integer(input$month1)
    input_kpi = input$kpi1
    prov_ingressi <- provenienze %>% filter(user_type == "STR" & kpi == input_kpi & month == month_input)
    prov_ingressi <- prov_ingressi[1:10, ]
    lvls = as.character(prov_ingressi$country)
    prov_ingressi$country = factor(lvls, levels = rev(lvls), ordered = T)
    

    selected_kpi = "Ingressi"
    pal <- colorNumeric(
      palette = brewer.pal(n=9, "Reds")[2:9],
      domain = NULL)
    
    if (input_kpi == "departures"){
      pal <- colorNumeric(
        palette = brewer.pal(n=9, "Blues")[2:9],
        domain = NULL)
        selected_kpi = "Uscite"
    }
    
   
    
    p <- plot_ly(
      data = prov_ingressi,
      y = ~tot,
      x = ~country,
      type = "bar",
      marker = list(color = ~pal(tot) ,
                    line = list(color = "grey",
                                width = 1.5)),
      text = ~paste(country, ": ", tot, sep = ''),
      hoverinfo = 'text') %>% layout(title = paste(selected_kpi, ": provenienza <b>visitatori stranieri</b> nel mese di ", mesi[month_input]), yaxis = list(title = "visitatori", tickfont = list(size = 9, color = 'black')), xaxis = list(title="Nazione", tickfont = list(size = 8)), margin = m)
    

  })
  
  
  output$accessi_ita <- renderPlotly({
    month_input = as.integer(input$month1)
    input_kpi = input$kpi1
    prov_ingressi <- provenienze %>% filter(user_type == "ITA" & kpi == input_kpi & month == month_input)
    prov_ingressi <- prov_ingressi[1:10, ]
    lvls = as.character(prov_ingressi$region)
    prov_ingressi$region = factor(lvls, levels = rev(lvls), ordered = T)
    
    
    
    selected_kpi = "Ingressi"
    pal <- colorNumeric(
      palette = brewer.pal(n=9, "Oranges")[2:9],
      domain = NULL)
    if (input_kpi == "departures"){
      pal <- colorNumeric(
        palette = brewer.pal(n=9, "Greens")[2:9],
        domain = NULL)
        selected_kpi = "Uscite"
    }
    
    
    
    selected_kpi = "Ingressi"
    
    p <- plot_ly(
      data = prov_ingressi,
      y = ~tot,
      x = ~region,
      type = "bar",
      marker = list(color = ~pal(tot) ,
                    line = list(color = "grey",
                                width = 1.5)),
      text = ~paste(region, ": ", tot, sep = ''),
      hoverinfo = 'text') %>% layout(title = paste(selected_kpi, ": provenienza <b>visitatori italiani</b> nel mese di ", mesi[month_input]), yaxis = list(title = "visitatori", tickfont = list(size = 9, color = 'black')), xaxis = list(title="Regione", tickfont = list(size = 8)), margin = m)
    
    
  })
  
  
  output$overnight <- renderLeaflet({
        month = input$month2
        user_type = input$user_type
        map_input = input$map_choice2


        aggregated_overnight_stay <- get_overnight_stay_by_adr(dataset = overnight, map_id = map_input, month = month, user_type = user_type)
        adr <- adr[adr$MAP_ID == map_input, ]
        adr <- adr[adr$AREA_LB_0 %in% aggregated_overnight_stay$adr_names, ]

        adr_levels = as.character(adr$AREA_LB_0)
        adr$AREA_LB_0 = as.factor(adr_levels)
        aos_levels = as.character(aggregated_overnight_stay$adr_names)
        aggregated_overnight_stay$adr_names = as.factor(aos_levels)
        #levels(aggregated_overnight_stay$adr_name) = levels(adr$AREA_LB_0)
        adr$overnight <- sapply(adr$AREA_LB_0, function(x){
              ifelse(x %in% aggregated_overnight_stay$adr_name, aggregated_overnight_stay$pernottamenti[aggregated_overnight_stay$adr_name == x], 0)
              })
        adr <- adr[adr$overnight > 0, ]
        if (user_type == "ITA"){
          chosen_color = "Reds"
        }else if (user_type == "STR"){
          chosen_color = "GnBu"
        }else{
          chosen_color = "Purples"
        }
        
        pal <- colorNumeric(
          palette = brewer.pal(n=9, chosen_color)[3:9],
          domain = NULL)

        #pal <- colorBin("Blues", 4, pretty = F)

        #    qpal <- colorQuantile("Blues", c(min(top_values), max(top_values)), n = 4)
        title <- tags$div(
          HTML("Dati Vodafone")
        )  

        m <- leaflet(data = adr) %>% setView(lng=8.981, lat=40.072, zoom=8) %>% addTiles() %>%
          addPolygons(layerId = adr, color = "#444444", weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 1, fillColor = ~pal(overnight),
                      highlightOptions = highlightOptions(color = "white", weight = 2,
                                                          bringToFront = TRUE), label = paste(adr$AREA_LB_0, ":", adr$overnight), labelOptions = labelOptions(clickable = FALSE, noHide = FALSE)) %>%
          addLegend("bottomright", pal = pal, values = ~overnight, title = "pernottamenti", opacity = 1) %>%
          addControl(title, position = "topleft")

        m
  })
  
  output$sired_overnight <- renderLeaflet({
    month = input$month2
    user_type = input$user_type
    map_input = input$map_choice2
    
    sired_overnight = get_sired_overnight_stay(dataset = sired_data, month = month, mapping = vod_sired_mappings, user_type = user_type)
    adr <- adr[adr$MAP_ID == map_input, ]
    adr <- adr[adr$AREA_LB_0 %in% sired_overnight$adr_names, ]
    
    adr_levels = as.character(adr$AREA_LB_0)
    adr$AREA_LB_0 = as.factor(adr_levels)
    sos_levels = as.character(sired_overnight$adr_names) ##sired overnight stays
    sired_overnight$adr_names = as.factor(sos_levels)
    #levels(aggregated_overnight_stay$adr_name) = levels(adr$AREA_LB_0)
    adr$overnight <- sapply(adr$AREA_LB_0, function(x){
      ifelse(x %in% sired_overnight$adr_names, sired_overnight$pernottamenti[sired_overnight$adr_names == x], 0)
    })
    adr <- adr[adr$overnight > 0, ]
    if (user_type == "ITA"){
      chosen_color = "Oranges"
    }else if (user_type == "STR"){
      chosen_color = "Greens"
    }else{
      chosen_color = "RdPu"
    }
    
    pal <- colorNumeric(
      palette = brewer.pal(n=9, chosen_color)[3:9],
      domain = NULL)
    
    #pal <- colorBin("Blues", 4, pretty = F)
    
    #    qpal <- colorQuantile("Blues", c(min(top_values), max(top_values)), n = 4)
    title <- tags$div(
      HTML("Dati SiRed")
    )  
    
    m <- leaflet(data = adr) %>% setView(lng=8.981, lat=40.072, zoom=8) %>% addTiles() %>%
      addPolygons(layerId = adr, color = "#444444", weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 1, fillColor = ~pal(overnight),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE), label = paste(adr$AREA_LB_0, ":", adr$overnight), labelOptions = labelOptions(clickable = FALSE, noHide = FALSE)) %>%
      addLegend("bottomright", pal = pal, values = ~overnight, title = "pernottamenti", opacity = 1) %>%
      addControl(title, position = "topleft")
    
    m
    
    
    
    
  })
  
})
