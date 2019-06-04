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
                            selected = "KARHUPUISTO")
  )
)

server <- function(input, output, session) {
  
  Kohteet <- reactive({
    Arvokohteet %>%
      filter(kohteen_nimi == input$target)
  })

  
  output$map <- renderLeaflet({
    
    mapviewOptions(basemaps = c("OpenStreetMap"))
  
    trees_joined_with_selected_area <- st_join(Kohteet(), Puut)
    Kohteen_puut <- Puut[Puut$id %in% trees_joined_with_selected_area$id.y, ]
    
    area <- mapview(Kohteet(),
                 col.regions = "lightskyblue4",
                 popup = leafpop::popupTable(Kohteet(),
                                             zcol = c("kohteen_nimi",
                                                      "yleiskuvaus",
                                                      "kasvilajistollinen_arvo",
                                                      "kasvillisuus"),
                                             feature.id = FALSE))
   
    if(nrow(Kohteen_puut) > 0) {
      m <- area + mapview(Kohteen_puut, 
                          col.regions = "green",
                          cex = 5,
                          feature.id = FALSE)
      
    } else {
      m <- area
      
      
    }
   
    m@map
    
  })
  
}

shinyApp(ui, server)