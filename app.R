library(shiny)
library(tidyverse)
library(leaflet)
library(mapview)
library(sf)

# Arvokohteet
Arvokohteet <- readRDS("trees.RDS")
# Puut
Puut <- readRDS("value.RDS")

targets <- as.vector(sort(unique(Arvokohteet$kohteen_nimi)))

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(bottom = 500, right = 20,
                draggable = TRUE,
                selectInput(inputId = "target",
                            label = "Kohde",
                            choices = c("All", targets),
                            selected = "All")
  )
)

server <- function(input, output, session) {
  
  filteredTargets <- reactive({
    if(input$target == 'All')
      return(Arvokohteet)
    Arvokohteet %>%
      filter(kohteen_nimi == input$target)
  })

  
  output$map <- renderLeaflet({
    
    trees_joined_with_selected_area <- st_join(filteredTargets(), Puut)
    trees_here <- Puut[Puut$id %in% trees_joined_with_selected_area$id.y, ]
   
    if(nrow(trees_here) > 0) {
      
      m <- mapview(filteredTargets(),
                 popup = leafpop::popupTable(filteredTargets(),
                                             zcol = c("kohteen_nimi",
                                                      "yleiskuvaus",
                                                      "kasvilajistollinen_arvo",
                                                      "kasvillisuus"),
                                             feature.id = FALSE)) +
        mapview(trees_here, feature.id = FALSE)
    }
    else {
      m <- mapview(filteredTargets(),
                   popup = leafpop::popupTable(filteredTargets(),
                                               zcol = c("kohteen_nimi",
                                                        "yleiskuvaus",
                                                        "kasvilajistollinen_arvo",
                                                        "kasvillisuus"),
                                               feature.id = FALSE))
    }
    
    m@map
    
  })
  
}

shinyApp(ui, server)