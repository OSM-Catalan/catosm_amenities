#' @title get_osm_schools
#' @description get all schools registered in openstreetmap from a municipality or comarca in Catalonia in either sf or table format
#' @param place character. name of the place for which to get schools - municipality or comarca
#' @param is_sf logical. If true, returns sf table. If false, a tibble.
#' @returns A sf or tibble with all schools in the desired place.
#' @import sf
#' @import dplyr
#' @import tidyr
#' @import tidyselect
#' @import osmdata
#' @export
get_osm_schools <- function(place, is_sf = TRUE){
  bbox <- osmdata::getbb(paste0(place, ", Catalunya"), format_out = "osm_type_id")
  schools <- osmdata::add_osm_features(opq = osmdata::opq(bbox, osm_types="nwr"),
                              features = list("amenity" = "school",
                                  "amenity" = "kindergarten",
                                  "amenity" = "music_school",
                                  "amenity" = "dancing_school",
                                  "amenity" = "language_school"))
  if(is_sf == TRUE) {
    schools <- osmdata::osmdata_sf(schools)
    schools_p <- schools$osm_points
    schools_pol <- schools$osm_polygons
    schools_mp <- schools$osm_multipolygons
    if(is.null(schools_p$ref) & is.null(schools_mp)){
      schools <- schools_pol
      schools <- dplyr::select(schools,
                        tidyselect::any_of(c("name", "name:ca", "ref", 
                                 "school", "isced:level", "min_age", "max_age",
                                 "operator", "operator:type", "religion",
                                 "amenity", "addr:city", "addr:place", "addr:suburb", 
                                 "addr:street", "addr:housenumber", "contact:email", 
                                 "contact:fax", "contact:phone", "website",
                                 "wheelchair", "wikidata", "name:etimology:wikidata")))
    }
    else if(is.null(schools_mp) & !is.null(schools_p$ref)){
      schools_p <- dplyr::select(schools_p,
                          tidyselect::any_of(c("name", "name:ca", "ref", 
                                   "school", "isced:level", "min_age", "max_age",
                                   "operator", "operator:type", "religion",
                                   "amenity", "addr:city", "addr:place", "addr:suburb", 
                                   "addr:street", "addr:housenumber", "contact:email", 
                                   "contact:fax", "contact:phone", "website",
                                   "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools_pol <- dplyr::select(schools_pol,
                            tidyselect::any_of(c("name", "name:ca", "ref", 
                                     "school", "isced:level", "min_age", "max_age",
                                     "operator", "operator:type", "religion",
                                     "amenity", "addr:city", "addr:place", "addr:suburb", 
                                     "addr:street", "addr:housenumber", "contact:email", 
                                     "contact:fax", "contact:phone", "website",
                                     "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools <- dplyr::bind_rows(schools_p, schools_pol)
    }
    else if(!is.null(schools_mp) & is.null(schools_p$ref)){
      schools_mp <- dplyr::select(schools_mp,
                          tidyselect::any_of(c("name", "name:ca", "ref", 
                                   "school", "isced:level", "min_age", "max_age",
                                   "operator", "operator:type", "religion",
                                   "amenity", "addr:city", "addr:place", "addr:suburb", 
                                   "addr:street", "addr:housenumber", "contact:email", 
                                   "contact:fax", "contact:phone", "website",
                                   "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools_pol <- dplyr::select(schools_pol,
                            tidyselect::any_of(c("name", "name:ca", "ref", 
                                     "school", "isced:level", "min_age", "max_age",
                                     "operator", "operator:type", "religion",
                                     "amenity", "addr:city", "addr:place", "addr:suburb", 
                                     "addr:street", "addr:housenumber", "contact:email", 
                                     "contact:fax", "contact:phone", "website",
                                     "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools <- dplyr::bind_rows(schools_mp, schools_pol)
    }
    else{
      schools_mp <- dplyr::select(schools_mp,
                           tidyselect::any_of(c("name", "name:ca", "ref", 
                                    "school", "isced:level", "min_age", "max_age",
                                    "operator", "operator:type", "religion",
                                    "amenity", "addr:city", "addr:place", "addr:suburb", 
                                    "addr:street", "addr:housenumber", "contact:email", 
                                    "contact:fax", "contact:phone", "website",
                                    "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools_pol <- dplyr::select(schools_pol,
                            tidyselect::any_of(c("name", "name:ca", "ref", 
                                     "school", "isced:level", "min_age", "max_age",
                                     "operator", "operator:type", "religion",
                                     "amenity", "addr:city", "addr:place", "addr:suburb", 
                                     "addr:street", "addr:housenumber", "contact:email", 
                                     "contact:fax", "contact:phone", "website",
                                     "wheelchair", "wikidata", "name:etimology:wikidata")))
      schools <- dplyr::bind_rows(schools_p, schools_mp, schools_pol) |> 
        mutate(geometry = sf::st_centroid(geometry))
    }
  }  
  else {
    schools <- osmdata::osmdata_data_frame(schools)
    schools <- dplyr::select(schools,
                      tidyselect::any_of(c("name", "name:ca", "ref", 
                               "school", "isced:level", "min_age", "max_age",
                               "operator", "operator:type", "religion",
                               "amenity", "addr:city", "addr:place", "addr:suburb", 
                               "addr:street", "addr:housenumber", "contact:email", 
                               "contact:fax", "contact:phone", "website",
                               "wheelchair", "wikidata", "name:etimology:wikidata")))
  }
  schools <- dplyr::filter(schools, !is.na(amenity))

  return(schools)
}
