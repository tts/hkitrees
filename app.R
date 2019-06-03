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
                            choices = c("All", targets),
                            selected = "All")
  )
)

server <- function(input, output, session) {
  
  filteredTargets <- reactive({
    if(input$target == 'All') {
      return(Arvokohteet)
    } else {
      Arvokohteet %>%
        filter(kohteen_nimi == input$target)
    }
  })

  
  output$map <- renderLeaflet({
    
    trees_joined_with_selected_area <- st_join(filteredTargets(), Puut)
    trees_here <- Puut[Puut$id %in% trees_joined_with_selected_area$id.y, ]
    
    area <- mapview(filteredTargets(),
                 col.regions = "lightskyblue4",
                 popup = leafpop::popupTable(filteredTargets(),
                                             zcol = c("kohteen_nimi",
                                                      "yleiskuvaus",
                                                      "kasvilajistollinen_arvo",
                                                      "kasvillisuus"),
                                             feature.id = FALSE))
   
    if(nrow(trees_here) > 0) {
      m <- area + mapview(trees_here, 
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