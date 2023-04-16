library(tidyverse)

#' @title get_gencat_schools
#' @description get all schools from the Catalan Government overpass from a municipality or comarca in Catalonia in either sf or table format
#' @param place character. name of the place for which to get schools - municipality or comarca
#' @param is_sf logical. If true, returns sf table. If false, a tibble.
#' @returns A sf or tibble with all schools in the desired place.
#' @export
get_gencat_schools <- function(place, is_sf = TRUE){
  bbox <- get_filter_bbox(place, transform = FALSE)
  baseurl <- "https://analisi.transparenciacatalunya.cat/resource/kvmv-ahh4.json?$query="
  
  
  query <- paste0("SELECT * WHERE curs='2022/2023' AND coordenades_geo_x >= ",bbox[2], " AND coordenades_geo_x <= ",bbox[4]," AND coordenades_geo_y >= ",bbox[1], " AND coordenades_geo_y <= ",bbox[3])
  query <- str_replace_all(query," ","%20")
  schools <- httr::GET(paste0(baseurl,query)) |> 
    httr::content(as = "text") |> 
    jsonlite::fromJSON()
  # change column names to fit with osm keys
  if(is_sf == TRUE) schools <- sf::st_as_sf(schools, coords = c("coordenades_geo_x", "coordenades_geo_y"), crs = "EPSG:4326")
  else schools <- select(schools, -c(coordenades_geo_x, coordenades_geo_y))
  schools <- schools |> 
    select(-c(curs, codi_titularitat, codi_naturalesa, 
              codi_delegaci, nom_delegaci, codi_comarca,
              codi_municipi, codi_municipi_6, 
              codi_localitat, codi_districte_municipal, 
              nom_comarca, zona_educativa)) |> # kill columns we do not need
    rename("operator" = "nom_titularitat",
           "name" = "denominaci_completa",
           "ref" = "codi_centre",
           "contact:phone" = "tel_fon",
           "contact:fax" = "fax",
           "contact:email" = "e_mail_centre",
           "website" = "url",
           "addr:city" = "nom_municipi",
           "addr:place" = "nom_localitat",
           "addr:postcode" = "codi_postal",
           "source:date" = "any") |> # change column names
    mutate("contact:fax" = paste0("+34",`contact:fax`),
           "contact:phone" = paste0("+34", `contact:phone`),
           "addr:street" = str_extract(adre_a, "^[^\\,]+"),
           "addr:housenumber" = str_extract(adre_a, "[^\\, ]+$"),
           "operator:type" = ifelse(nom_naturalesa == "Públic", "public", "private"))
  # get table with isced codes and kinds of school
  eqs <- "https://wiki.openstreetmap.org/wiki/Import_schools_in_Catalunya" |> 
    rvest::read_html() |> 
    rvest::html_elements(xpath = '/html/body/div[3]/div[3]/div[5]/div[1]/table[2]') |> 
    rvest::html_table()
  eqs <- eqs[[1]] |> 
    mutate(Cycle = str_split(Cycle, ", ")) |> 
    unnest(cols = Cycle) |> 
    mutate(Cycle = str_to_lower(Cycle))
  schools_isced <- schools |> 
    sf::st_drop_geometry() |> 
    select(any_of(c("ref", eqs$Cycle))) |> 
    pivot_longer(-ref,
                 names_to = "level_name",
                 values_to = "junk") |> 
    filter(!is.na(junk)) |> 
    select(-junk) |> 
    left_join(eqs, by = c("level_name" = "Cycle")) |> 
    mutate("school" = case_when(level_name %in% c("einf1c", "einf2c") ~ NA_character_,
                                level_name == "epri" ~ "primary",
                                level_name %in% c("eso", "batx") ~ "secondary",
                                level_name %in% c("aa01", "cfpm", "ppas", 
                                                  "aa03", "cfps", "pfi", "pa01",
                                                  "cfam", "pa02", "cfas",
                                                  "esdi", "adr", "crbc",
                                                  "dans", "musp", "muss",
                                                  "tegm", "tegs") ~ "professional",
                                level_name == "ee" ~ "special_education_needs",
                                TRUE ~ NA_character_),
           "amenity" = case_when(level_name == "einf1c" ~ "kindergarten",
                                 level_name == "muse" ~ "music_school",
                                 level_name == "dane" ~ "dancing_school",
                                 level_name == "idi" ~ "language_school",
                                 TRUE ~ "school")) |> # falta posar les escoles de dansa
    arrange(`ISCED level`) |> 
    group_by(ref) |> 
    summarise("isced:level" = paste(unique(`ISCED level`), collapse = "; "),
              "min_age" = min(min_age),
              "max_age" = ifelse(length(c(max_age)[is.na(c(max_age))]) > 0, NA_integer_,max(max_age)),
              "amenity" = paste(unique(`amenity`), collapse = "; "),
              "school" = paste(unique(school)[!is.na(c(unique(school)))], collapse = "; "))
  
  
  schools <- schools |> 
    select(-any_of(c(eqs$Cycle, "nom_naturalesa", "adre_a"))) |> 
    left_join(schools_isced, by = "ref")
  
  return(schools)
}
