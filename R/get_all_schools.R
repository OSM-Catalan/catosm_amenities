library(tidyverse)
library(osmdata)
library(sf)
#' @title get_all_schools
#' @description get all schools registered in openstreetmapand the Catalan government from a municipality or comarca in Cataloniamat
#' @param place character. name of the place for which to get schools - municipality or comarca
#' @param plot logical. If true,returns a list with an interactive tmap plot with both sources plotted and a data.frame. If false, only a data.frame
#' @returns A tibble with all schools or a list with said tibble and a map.
#' @export
get_all_schools <- function(place, plot = TRUE){
  osm_schools <- catosmamenities::get_osm_schools(place, is_sf = TRUE)
  gencat_schools <- catosmamenities::get_gencat_schools(place, is_sf = TRUE)
  osm_schools_df <- osm_schools |> 
    st_drop_geometry()
  colnames(osm_schools_df) <- sapply(colnames(osm_schools_df), 
                                     \(x) ifelse(x == "ref", x, paste0("osm_",x)))
  gencat_schools_df <- gencat_schools |> 
    st_drop_geometry()
  colnames(gencat_schools_df) <- sapply(colnames(gencat_schools_df), 
                                     \(x) ifelse(x %in% c("ref", "source:date"), x, paste0("gencat_",x)))
  all_schools <- full_join(gencat_schools_df, osm_schools_df, by = "ref") |> 
    distinct()
  all_schools <- all_schools |> 
    select(any_of(c("ref", "source:date", "osm_name", "osm_name:ca", "gencat_name",
                    "osm_amenity", "gencat_amenity",
                    "osm_school", "gencat_school", "osm_isced:level", "gencat_isced:level",
                    "osm_min_age", "gencat_min_age", "osm_max_age", "gencat_max_age", "osm_operator",
                    "gencat_operator", "osm_operator:type", "gencat_operator_type",
                    "osm_religion",
                    "osm_addr:city", "gencat_addr:city", "osm_addr:place","osm_addr:suburb", "gencat_addr:place",
                    "osm_addr:street", "gencat_addr:street", "osm_addr:housenumber", "gencat_addr:housenumber",
                    "osm_contact:email", "gencat_contact:email", "osm_contact:fax", "gencat_contact:fax",
                    "osm_contact:phone", "gencat_contact:phone", "osm_website", "gencat_website",
                    "osm_wheelchair", "osm_wikidata")))
  if(plot == TRUE){
    tmap_mode("view")
    plot <- tm_shape(mutate(osm_schools, source = "OSM")) + 
      tm_symbols(shape = 16,
                 col = "blue") + 
      tm_shape(mutate(gencat_schools, source = "GENCAT")) + 
      tm_symbols(shape = 18,
                 col = "red")
    return(list(plot = plot, df = all_schools))
  }
  else return(all_schools)

    
}
