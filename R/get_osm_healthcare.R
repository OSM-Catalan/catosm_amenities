library(tidyverse)
library(osmdata)
library(sf)
#' @title get_osm_healthcare
#' @description get all healthcare amenities except for farmacies registered in openstreetma from a municipality or comarca in Catalonia in either sf or table format
#' @param place character. name of the place for which to get healthcare - municipality or comarca
#' @param is_sf logical. If true, returns sf table. If false, a tibble.
#' @returns A sf or tibble with all healthcare in the desired place.
#' @export


get_osm_healthcare <- function(place, is_sf = TRUE){
  healthcare <- add_osm_features(opq = opq(paste0(place, ", Spain"), osm_types="nwr"), 
                              features = list("amenity" = "clinic",
                                              "amenity" = "doctors",
                                              "amenity" = "hospital",
                                              "healthcare" = "clinic",
                                              "healthcare" = "hospital"))
  cols_to_select <- c("name", "name:ca", "ref", 
                      "amenity", "healthcare", "healthcare:counselling", "healthcare:speciality",
                      "operator", "operator:type", "addr:city", "addr:place", "addr:suburb", 
                      "addr:street", "addr:housenumber", "contact:email", "email",
                      "contact:fax", "fax", "contact:phone", "phone", "website",
                      "wheelchair", "wikidata") # validate that we want these columns
  if(is_sf == TRUE) {
    healthcare <- osmdata_sf(healthcare)
    healthcare_p <- healthcare$osm_points
    healthcare_pol <- healthcare$osm_polygons
    healthcare_mp <- healthcare$osm_multipolygons
    if(is.null(healthcare_p$ref) & is.null(healthcare_mp)){
      healthcare <- healthcare_pol
      healthcare <- select(healthcare,
                        any_of(cols_to_select))
    }
    else if(is.null(healthcare_mp) & !is.null(healthcare_p$ref)){
      healthcare_p <- select(healthcare_p,
                          any_of(cols_to_select))
      healthcare_pol <- select(healthcare_pol,
                            any_of(cols_to_select))
      healthcare <- bind_rows(healthcare_p, healthcare_pol)
    }
    else if(!is.null(healthcare_mp) & is.null(healthcare_p$ref)){
      healthcare_mp <- select(healthcare_mp,
                           any_of(cols_to_select))
      healthcare_pol <- select(healthcare_pol,
                            any_of(cols_to_select))
      healthcare <- bind_rows(healthcare_mp, healthcare_pol)
    }
    else{
      healthcare_mp <- select(healthcare_mp,
                           any_of(cols_to_select))
      healthcare_pol <- select(healthcare_pol,
                            any_of(cols_to_select))
      healthcare <- bind_rows(healthcare_p, healthcare_mp, healthcare_pol) |> 
        mutate(geometry = st_centroid(geometry))
    }
  }  
  else {
    healthcare <- 
      osmdata_data_frame(healthcare)
    healthcare <- select(healthcare,
                      any_of(cols_to_select))
  }
  healthcare <- filter(healthcare, !is.na(amenity))
  # should I order the contact info here? Probably should put a param then - or better leave it for the get_all_healthcare() function
  return(healthcare)
}
