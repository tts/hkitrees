library(tidyverse)
library(sf)

# https://twiav.nl/en/WFS_R.php

baseurl <- "https://kartta.hel.fi/ws/geoserver/avoindata/wfs?"
wfs_request <- "request=GetFeature&service=WFS&version=2.0.0&typeName=Puurekisteri_piste&outputFormat=json"
hki_trees_wfs <- paste0(baseurl,wfs_request)
trees <- st_read(hki_trees_wfs)
trees <- trees %>% 
  mutate(koko = ifelse(kokoluokka == "0 - 10 cm", 0,
                       ifelse(kokoluokka == "10 - 20 cm", 2,
                              ifelse(kokoluokka == "20 - 30 cm", 4,
                                     ifelse(kokoluokka == "30 - 50 cm", 6,
                                            ifelse(kokoluokka == "50 - 70 cm", 8,
                                                   ifelse(kokoluokka == "70 cm -", 10, 0)))))))

trees$koko <- ifelse(is.na(trees$kokoluokka), 0, trees$koko)

saveRDS(trees, "trees.RDS")

baseurl <- "https://kartta.hel.fi/ws/geoserver/avoindata/wfs?"
wfs_request <- "request=GetFeature&service=WFS&version=2.0.0&typeName=Arvoymparistot&outputFormat=json"
hki_value_wfs <- paste0(baseurl,wfs_request)
valueables <- st_read(hki_value_wfs)
saveRDS(valueables, "value.RDS")

