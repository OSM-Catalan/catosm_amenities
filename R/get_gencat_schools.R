#' @title get_gencat_schools
#' @description get all schools from the Catalan Government overpass from a municipality or comarca in Catalonia in either sf or table format
#' @param place character. name of the place for which to get schools - municipality or comarca
#' @param is_sf logical. If true, returns sf table. If false, a tibble.
#' @import sf
#' @import dplyr
#' @import tidyr
#' @import osmdata
#' @import stringr
#' @import rvest
#' @import jsonlite
#' @import httr
#' @returns A sf or tibble with all schools in the desired place. If it returns a tibble, it will return all schools in the bbox of the selected place, not filtering by polygon
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
  if(is_sf == TRUE) {
    schools <- sf::st_as_sf(schools, coords = c("coordenades_geo_x", "coordenades_geo_y"), crs = "EPSG:4326")
    filter_pol <- osmdata::getbb(paste0(place, ", Catalunya"), format_out = "sf_polygon")
    filter_pol <- bind_rows(filter_pol$polygon, filter_pol$multipolygon)
    schools <- sf::st_intersection(schools, sf::st_transform(filter_pol, sf::st_crs(schools)))
    }
  else schools <- select(schools, -c(coordenades_geo_x, coordenades_geo_y))
  schools <- schools |> 
    dplyr::select(-c(curs, codi_titularitat, codi_naturalesa, 
              codi_delegaci, nom_delegaci, codi_comarca,
              codi_municipi, codi_municipi_6, 
              codi_localitat, codi_districte_municipal, 
              nom_comarca, zona_educativa)) |> # kill columns we do not need
    dplyr::rename("operator" = "nom_titularitat",
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
    dplyr::mutate("contact:fax" = paste0("+34",`contact:fax`),
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
    dplyr::select(any_of(c("ref", eqs$Cycle))) |> 
    tidyr::pivot_longer(-ref,
                 names_to = "level_name",
                 values_to = "junk") |> 
    dplyr::filter(!is.na(junk)) |> 
    dplyr::select(-junk) |> 
    dplyr::left_join(eqs, by = c("level_name" = "Cycle")) |> 
    dplyr::mutate("school" = case_when(level_name %in% c("einf1c", "einf2c") ~ NA_character_,
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
    dplyr::arrange(`ISCED level`) |> 
    dplyr::group_by(ref) |> 
    dplyr::summarise("isced:level" = paste(unique(`ISCED level`), collapse = "; "),
              "min_age" = min(min_age),
              "max_age" = ifelse(length(c(max_age)[is.na(c(max_age))]) > 0, NA_integer_,max(max_age)),
              "amenity" = paste(unique(`amenity`), collapse = "; "),
              "school" = paste(unique(school)[!is.na(c(unique(school)))], collapse = "; "))
  
  
  schools <- schools |> 
    dplyr::select(-any_of(c(eqs$Cycle, "nom_naturalesa", "adre_a"))) |> 
    dplyr::left_join(schools_isced, by = "ref")
  
  return(schools)
}