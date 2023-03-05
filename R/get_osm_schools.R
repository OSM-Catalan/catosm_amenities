library(tidyverse)
library(osmdata)
library(sf)
#' @title osm_schools
#' @description get all schools registered in openstreetmap from a municipality or comarca in Catalonia in either sf or table format
#' @param place character. name of the place for which to get schools - municipality or comarca
#' @param is_sf logical. If true, returns sf table. If false, a tibble.
#' @returns A sf or tibble with all schools in the desired place.
#' @export
get_osm_schools <- function(place, is_sf = TRUE){
  schools <- opq(paste0(place, ", Spain")) |> 
    add_osm_features("[\"amenity\"=\"school\"][\"ref\"]")
  if(is_sf == TRUE) {
    schools <- osmdata_sf(schools)
    schools_p <- schools$osm_points
    schools_pol <- schools$osm_polygons
    schools_mp <- schools$osm_multipolygons
    if(is.null(schools_p$ref) & is.null(schools_mp)){
      schools <- schools_pol
      schools <- select(schools,
                        any_of(c("name", "name:ca", "ref", 
                                 "school", "isced:level", "min_age", "max_age",
                                 "operator", "operator:type", "religion",
                                 "amenity", "addr:city", "addr:place", "addr:suburb", 
                                 "addr:street", "addr:housenumber", "contact:email", 
                                 "contact:fax", "contact:phone", "website",
                                 "wheelchair", "wikidata", "name:etimology:wikidata")))
    }
    else if(is.null(schools_mp) & !is.null(schools_p$ref)){
      schools_p <- select(schools_p,
                          any_of(c("name", "name:ca", "ref", 
                                   "school", "isced:level", "min_age", "max_age",
                                   "operator", "operator:type", "religion",
                                   "amenity", "addr:city", "addr:place", "addr:suburb", 
                                   "addr:street", "addr:housenumber", "contact:email", 
                                   "contact:fax", "contact:phone", "website",
                                   "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools_pol <- select(schools_pol,
                            any_of(c("name", "name:ca", "ref", 
                                     "school", "isced:level", "min_age", "max_age",
                                     "operator", "operator:type", "religion",
                                     "amenity", "addr:city", "addr:place", "addr:suburb", 
                                     "addr:street", "addr:housenumber", "contact:email", 
                                     "contact:fax", "contact:phone", "website",
                                     "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools <- bind_rows(schools_p, schools_pol)
    }
    else if(!is.null(schools_mp) & is.null(schools_p$ref)){
      schools_mp <- select(schools_mp,
                          any_of(c("name", "name:ca", "ref", 
                                   "school", "isced:level", "min_age", "max_age",
                                   "operator", "operator:type", "religion",
                                   "amenity", "addr:city", "addr:place", "addr:suburb", 
                                   "addr:street", "addr:housenumber", "contact:email", 
                                   "contact:fax", "contact:phone", "website",
                                   "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools_pol <- select(schools_pol,
                            any_of(c("name", "name:ca", "ref", 
                                     "school", "isced:level", "min_age", "max_age",
                                     "operator", "operator:type", "religion",
                                     "amenity", "addr:city", "addr:place", "addr:suburb", 
                                     "addr:street", "addr:housenumber", "contact:email", 
                                     "contact:fax", "contact:phone", "website",
                                     "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools <- bind_rows(schools_mp, schools_pol)
    }
    else{
      schools_mp <- select(schools_mp,
                           any_of(c("name", "name:ca", "ref", 
                                    "school", "isced:level", "min_age", "max_age",
                                    "operator", "operator:type", "religion",
                                    "amenity", "addr:city", "addr:place", "addr:suburb", 
                                    "addr:street", "addr:housenumber", "contact:email", 
                                    "contact:fax", "contact:phone", "website",
                                    "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools_pol <- select(schools_pol,
                            any_of(c("name", "name:ca", "ref", 
                                     "school", "isced:level", "min_age", "max_age",
                                     "operator", "operator:type", "religion",
                                     "amenity", "addr:city", "addr:place", "addr:suburb", 
                                     "addr:street", "addr:housenumber", "contact:email", 
                                     "contact:fax", "contact:phone", "website",
                                     "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools <- bind_rows(schools_p, schools_mp, schools_pol)      
    }
  }  
  else {
    schools <- 
    osmdata_data_frame(schools)
    schools <- select(schools,
                      any_of(c("name", "name:ca", "ref", 
                               "school", "isced:level", "min_age", "max_age",
                               "operator", "operator:type", "religion",
                               "amenity", "addr:city", "addr:place", "addr:suburb", 
                               "addr:street", "addr:housenumber", "contact:email", 
                               "contact:fax", "contact:phone", "website",
                               "wheelchair", "wikidata", "name:etimology:wikidata")))
    }

  return(schools)
}
