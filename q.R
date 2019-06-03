library(tidyverse)
library(sf)

# https://twiav.nl/en/WFS_R.php

baseurl <- "https://kartta.hel.fi/ws/geoserver/avoindata/wfs?"
wfs_request <- "request=GetFeature&service=WFS&version=2.0.0&typeName=Puurekisteri_piste&outputFormat=json"
hki_trees_wfs <- paste0(baseurl,wfs_request)
trees <- st_read(hki_trees_wfs)
saveRDS(trees, "trees.RDS")

baseurl <- "https://kartta.hel.fi/ws/geoserver/avoindata/wfs?"
wfs_request <- "request=GetFeature&service=WFS&version=2.0.0&typeName=Arvoymparistot&outputFormat=json"
hki_value_wfs <- paste0(baseurl,wfs_request)
valueables <- st_read(hki_value_wfs)
saveRDS(valueables, "value.RDS")







