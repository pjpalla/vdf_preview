#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = "preview.css",

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
       h1("Analisi Anteprima Dati Vodafone", align="center"),br(), br(),
  # Application title

  #titlePanel("Old Faithful Geyser Data"),

  # Sidebar with a slider input for number of bins
           h3("Punti di accesso alla Sardegna: distribuzione degli ingressi e delle uscite"),br(),
  div(class = "jumbotron", 
      #h2("Distribuzione degli ingressi", class='text-center'),br(),
      p(HTML("La mappa rappresenta la distribuzione degli <b>ingressi</b> e delle <b>uscite</b> in Sardegna sulla base dei dati forniti da <b>Vodafone</b>. Gli ingressi sono espressi in funzione della mappa prescelta e del mese considerato. Vengono riportate in mappa solamente le <b>Aree di Riferimento</b> (AdR) che contribuiscono con una determinata soglia percentuale agli ingressi complessivamente registrati sul territorio sardo."))),
  
  # wellPanel("La mappa rappresenta la distribuzione degli ingressi in Sardegna sulla base dei dati forniti da Vodafone. Gli ingressi sono espressi in funzione della mappa prescelta e del
  #           mese considerato. Vengono riportate in mappa solamente le Aree di Riferimento (AdR) che contribuiscono con una determinata soglia percentuale agli ingressi complessivamente registrati sul territorio sardo"), 
  
  

  fluidRow(
    column(5,
           
           wellPanel(
             radioButtons("kpi", "Seleziona KPI:",
                          c("Ingressi" = "arrivals",
                            "Uscite" = "departures"), selected = "arrivals"), br(),               
             radioButtons("map_choice1", "Seleziona mappa:",
                          c("Comuni" = 1,
                            "Province" = 2, 
                            "Comuni + PoI" = 3,
                            "Province + PoI" = 4), selected = 3), br(),
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
                         value = 0.5, step = 0.1),br(), br(), br(), br(), br(), br(),
             
             h3("Punti di accesso: flusso di visitatori"),br(),
             plotlyOutput("arrivals")
             
           )
           
         
    ),
    column(7,
          leafletOutput("areas", height = "600"),
          h3("Tipologia visitatori"),br(), br(),
          plotlyOutput("tot_users")
    )
  ),br(),
  h3("Provenienze"), br(),
  fluidRow(
    column(2,
           wellPanel(
             radioButtons("kpi1", "Seleziona KPI:",
                          c("Ingressi" = "arrivals",
                            "Uscite" = "departures"), selected = "arrivals"), br(),
             selectInput("month1", "Seleziona mese:",
                         c("Febbraio" = 2,
                           "Marzo" = 3,
                           "Aprile" = 4,
                           "Maggio" = 5,
                           "Giugno" = 6), selected = 3))             
           ),
    column(5,
           plotlyOutput("accessi_str")),
    column(5,
           plotlyOutput("accessi_ita"))
    
  ),
  
  h3("Distribuzione pernottamenti"), br(),
  fluidRow(
   
      column(4,
             wellPanel(
               radioButtons("map_choice2", "Seleziona mappa:",
                            c("Comuni" = 1,
                              "Comuni + PoI" = 3), selected = 1), br(),             
               selectInput("month2", "Seleziona mese:",
                           c("Febbraio" = 2,
                             "Marzo" = 3,
                             "Aprile" = 4,
                             "Maggio" = 5,
                             "Giugno" = 6), selected = 3), br(),
               
               radioButtons("user_type", "Tipologia visitatori:",
                            c("Italiani" = "ITA",
                              "Stranieri" = "STR",
                              "Italiani e Stranieri" = "ALL"), selected = "ITA"), br(), br(),
               
               h3("Pernottanmenti in Sardegna"),br()
      )      
      
    ),

           #tableOutput("ar,
    column(4,
           leafletOutput("overnight", height = "600")),
    column(4,
           leafletOutput("sired_overnight", height = "600")))
))



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


