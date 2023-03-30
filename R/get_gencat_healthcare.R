library(osmdata)
library(sf)
library(jsonlite)
library(httr)
library(tidyverse)
library(rvest)

#' @title get_gencat_healthcare
#' @description get all healthcare amenities except for farmacies from the Catalan Government overpass from a municipality or comarca in Catalonia in either sf or table format
#' @param place character. name of the place for which to get schools - municipality or comarca
#' @param is_sf logical. If true, returns sf table. If false, a tibble.
#' @returns A sf or tibble with all schools in the desired place
#' @export

get_gencat_healthcare <- function(place, is_sf = TRUE){
  # filter tags
  baseurl <- "https://analisi.transparenciacatalunya.cat/resource/8gmd-gz7i.json?$query="
  bbox <- get_filter_bbox(place, transform = FALSE)
  query <- paste0("SELECT * WHERE longitud >= ",bbox[2], 
  " AND longitud <= ",bbox[4],
  " AND latitud >= ",bbox[1],
  " AND latitud <= ",bbox[3],
  " AND categoria LIKE '%Centres sanitaris%'",
  collapse = "")
  query <- str_replace_all(query, "%","%25")
  query <- str_replace_all(query, "'", "%27")
  query <- str_replace_all(query," ","%20")
  healthcare <- GET(paste0(baseurl, query)) |> 
    content(as = "text") |> 
    fromJSON()
  healthcare <- healthcare |> 
    select(-c(alies, utmx, utmy, localitzacio, data_modificacio, codi_municipi, comarca)) |> 
    separate(via, into = c("addr:street", "addr:housenumber"), sep = ",") |> 
    mutate(nohousenumber = ifelse(str_detect(str_to_lower(`addr:housenumber`), "s/n"), "yes", NA_character_),
           `addr:housenumber` = ifelse(str_detect(str_to_lower(`addr:housenumber`), "s/n"), NA_character_, `addr:housenumber`)) |> 
    rename("ref" = "idequipament",
           "name" = "nom",
           "addr:postcode" = "cpostal",
           "contact:phone" = "telefon1",
           "contact:fax" = "fax",
           "contact:phone2" = "telefon2",
           "contact:email" = "email",
           "addr:city" = "poblacio") |> 
    mutate(amenity = case_when(str_detect(categoria,"Hospitals") ~ "hospital",
                               str_detect(name, "Consultori") ~ "doctors",
                               str_detect(categoria, "Centres d'atenció primària") |
                                 str_detect(categoria, "Centres d'atenció i seguiment a les drogodependències") |
                                 str_detect(categoria, "Centres amb intercanvi de xeringues") ~ "clinic",
                               str_detect(categoria, "Centres amb atenció continuada") ~ "clinic",
                               str_detect(categoria, "sociosanitaris") | str_detect(categoria, "Centres de salut mental") ~ "clinic OR hospital",
                               TRUE ~ "REVISAR"),
           healthcare = amenity,
           `healthcare:counselling` = ifelse(str_detect(categoria, "Centres d'atenció i seguiment a les drogodependències") |
                                               str_detect(categoria, "Centres amb intercanvi de xeringues"), "addiction", NA_character_),
           `healthcare:speciality` = case_when(str_detect(categoria, "Centres amb atenció continuada") ~ "emergency",
                                               str_detect(categoria, "Centres de salut mental") ~ "psychiatry",
                                               TRUE ~ NA_character_))
  return(healthcare)
  }