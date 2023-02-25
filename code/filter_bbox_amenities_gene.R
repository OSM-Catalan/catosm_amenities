library(tidyverse)
library(sf)
library(httr)
library(osmdata)
library(jsonlite)
library(tmap)

### AIXÒ ÉS UN CODI EN BRUT, S'HAURÀ D'INCORPORAR A LES FUNCIONS DE CADA FONT DE DADES

# agafar bbox
o <- opq("Palafrugell")

get_bbox <- function(opq){
  bbox <- opq$bbox
  bbox <- as.vector(sapply(str_split(bbox,","), as.numeric))
  return(bbox)
} 


bbox <- get_bbox(o)

# QUERY NOMÉS PER AGAFAR BBOX

query_location <- paste0(c("SELECT * WHERE latitud <= ", bbox[3],
                           " AND latitud >= ", bbox[1],
                           " AND longitud <= ", bbox[4],
                           " AND longitud >= ", bbox[2]),
                         collapse = "")


baseurl <- "https://analisi.transparenciacatalunya.cat/resource/8gmd-gz7i.json?$query="       

query_location <- str_replace_all(query_location," ","%20")

equipaments_bbox <- GET(paste0(baseurl,query_location, collapse = "")) |> 
  content(as = "text") |> 
  fromJSON()

# mapa per comprovar
tmap_mode("view")

equipaments_bbox |> 
  st_as_sf(coords = c("longitud", "latitud"), crs = "EPSG:4326") |> 
  tm_shape() + 
  tm_dots()

