## GEOCODING BUSINESSES W/O COORDINATES
# Database: Diputació de Barcelona
# AQUÍ VEIEM QUE HI HA MASSA DIVERSITAT I NO HI HA DIVISIÓ. PER TANT, S'HA DE FILTRAR PEL TIPUS D'EQUIPAMENT SEU I AFEGIR-HI KEY-VALUE.

library(tidyverse)
library(tidygeocoder)
library(sf)
library(httr)
library(jsonlite)
library(osmdata)
source("code/get_filter_bbox.R")

bbox <- get_filter_bbox("Santpedor", transform = TRUE)

#### ORIGINAL STUFF-####

url <- paste0("https://do.diba.cat/api/dataset/establiments/","camp-utm_x-greaterequal/",bbox[2], 
              "/camp-utm_x-lowerequal/", bbox[4],
              "/camp-utm_y-greaterequal/", bbox[1],
              "/camp-utm_y-lowerequal/", bbox[3])


establiments <- GET(url) |> 
  content(as = "text") |> 
  fromJSON()
establiments <- establiments$elements
establiments <- establiments |> 
  unnest(adreca)


