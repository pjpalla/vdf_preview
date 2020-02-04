#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # fluidRow(
  #           sidebarPanel(
  #                     sliderInput("bins",
  #                                 "Number of bins:",
  #                                 min = 1,
  #                                 max = 50,
  #                                 value = 30)
  #           ),            
  #             column(
  #               width = 6,
  #               leafletOutput("areas", height = "600")
  #             ))
  # 
  # Application title
  div(h2("Punti di accesso alla Sardegna: distribuzione ingressi")),br(),
            
  #titlePanel("Old Faithful Geyser Data"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
       radioButtons("map_choice", "Seleziona mappa:",
                           c("Mappa 3 (Comuni + POI)" = 3,
                             "Mappa 4 (Province + POI)" = 4)), br(),br(),
       selectInput("month", "Seleziona mese:",
                   c("Febbraio" = 2,
                     "Marzo" = 3,
                     "Aprile" = 4,
                     "Maggio" = 5,
                     "Giugno" = 6), selected = 3), br(),br(),br(),
       sliderInput("threshold",
                   "Soglia arrivi (%):",
                   min = 0,
                   max = 5,
                   value = 0.5, step = 0.1),br(), br(),
       
       h3("Ingressi in Sardegna"),br(),
       tableOutput("arrivals")
    ),

    # Show a plot of the generated distribution
    mainPanel(
       leafletOutput("areas", height = "800")                
       #plotOutput("distPlot")
    )
  )
))
