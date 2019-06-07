library(shiny)
library(tidyverse)
library(leaflet)
library(mapview)
library(sf)

Arvokohteet <- readRDS("value.RDS")
Puut <- readRDS("trees.RDS")

targets <- as.vector(sort(unique(Arvokohteet$kohteen_nimi)))

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(bottom = 400, right = 20,
                draggable = TRUE,
                selectInput(inputId = "target",
                            label = "Kohde",
                            choices = targets,
                            selected = "KATRI VALAN PUISTO"),
                HTML("<div><br/><a target='blank' href='http://tuijasonkkila.fi/blog/2018/01/streets-of-helsinki/'>[About TBA]</a></div>")
  )
)

server <- function(input, output, session) {
  
  Kohteet <- reactive({
    Arvokohteet %>%
      filter(kohteen_nimi == input$target)
  })

  
  output$map <- renderLeaflet({
    
    trees_joined_with_selected_area <- st_join(Kohteet(), Puut)
    Kohteen_puut <- Puut[Puut$id %in% trees_joined_with_selected_area$id.y, ]

    mapviewOptions(basemaps = c("OpenStreetMap"))
    
    area <- mapview(Kohteet(),
                    col.regions = "steelblue2",
                    zcol = "kohteen_nimi",
                    legend = FALSE)
 
    if(nrow(Kohteen_puut) > 0) {
      
      m <- area +
        mapview(Kohteen_puut,
                col.regions = "springgreen4",
                cex = Kohteen_puut$koko,
                zcol = "suomenknimi",
                legend = FALSE)
      
  
    } else {
      m <- area
    }
    
    m@map
  
  })
  
}

shinyApp(ui, server)