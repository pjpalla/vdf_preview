#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  tags$head(tags$style( type = "text/css", '
      .irs-line-mid{
        background: #428bca ;
        border: 1px solid #428bca ;
      }
      .irs-line-right{
        background: #428bca ;
      }
      .irs-bar {
        background: linear-gradient(to bottom, #DDD -50%, #FFF 150%);
        border-top: 1px solid #CCC ;
        border-bottom: 1px solid #CCC ;
      }
      .irs-bar-edge {
        background: inherit ;
        border: inherit ;
      }

    ')),  
  # Application title

            
  #titlePanel("Old Faithful Geyser Data"),

  # Sidebar with a slider input for number of bins
  fluidRow(
    
    column(4,offset = 0,
           div(h3("Punti di accesso alla Sardegna: distribuzione ingressi")),br(),
           radioButtons("map_choice", "Seleziona mappa:",
                        c("Mappa 1 (Comuni)" = 1,
                          "Mappa 2 (Province)" = 2, 
                          "Mappa 3 (Comuni + POI)" = 3,
                          "Mappa 4 (Province + POI)" = 4), selected = 3), br(),br(),
           selectInput("month", "Seleziona mese:",
                       c("Febbraio" = 2,
                         "Marzo" = 3,
                         "Aprile" = 4,
                         "Maggio" = 5,
                         "Giugno" = 6), selected = 3), br(),
           sliderInput("threshold",
                       "Soglia arrivi (%):",
                       min = 0,
                       max = 5,
                       value = 0.1, step = 0.1),br(), br(),
           
           h3("Ingressi in Sardegna"),br(),
           tableOutput("arrivals")
    ),
    column(8,
          leafletOutput("areas", height = "600")    
    )
  ),br()
  
  # fluidRow(
  #   column(4, offset = 0,
  #          div(h3("Distribuzione pernottamenti")),           
  #          selectInput("month1", "Seleziona mese:",
  #                      c("Febbraio" = 2,
  #                        "Marzo" = 3,
  #                        "Aprile" = 4,
  #                        "Maggio" = 5,
  #                        "Giugno" = 6), selected = 3), br(),
  #          
  #          radioButtons("user_type", "Tipologia visitatori:",
  #                             c("Italiani" = "ITA",
  #                               "Stranieri" = "STR",
  #                               "Italiani e Stranieri" = "ALL"), selected = "STR"), br(), br(),
  #          
  #          h3("Pernottanmenti in Sardegna"),br()           
  #          ),
  # 
  #          #tableOutput("ar,
  #   column(8,
  #          leafletOutput("overnight", height = "600")    
  #   )
  # )
  

  # sidebarLayout(
  #   sidebarPanel(
  #      radioButtons("map_choice", "Seleziona mappa:",
  #                          c("Mappa 3 (Comuni + POI)" = 3,
  #                            "Mappa 4 (Province + POI)" = 4)), br(),br(),
  #      selectInput("month", "Seleziona mese:",
  #                  c("Febbraio" = 2,
  #                    "Marzo" = 3,
  #                    "Aprile" = 4,
  #                    "Maggio" = 5,
  #                    "Giugno" = 6), selected = 3), br(),br(),br(),
  #      sliderInput("threshold",
  #                  "Soglia arrivi (%):",
  #                  min = 0,
  #                  max = 5,
  #                  value = 0.5, step = 0.1),br(), br(),
  #      
  #      h3("Ingressi in Sardegna"),br(),
  #      tableOutput("arrivals")
  #   ),
  # 
  #   # Show a plot of the generated distribution
  #   mainPanel(
  #      leafletOutput("areas", height = "800")   
  #      #leafletOutput("overnight", height = "800")
  #      #plotOutput("distPlot")
  #   )
  # )
))
