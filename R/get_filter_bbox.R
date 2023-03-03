library(tidyverse)
library(osmdata)
library(sf)


#' @title get_filter_bbox
#' @description get a bbox for filtering rest apis
#' @param place character. name of the place for which to find bbox - municipality or comarca
#' @param transform logical. Whether bbox should remain in geographic coordinates or be transformed/projected
#' @param end_crs character. if transform == TRUE, choose the CRS to which it will be converted. 
#' @export
get_filter_bbox <- function(place, transform = FALSE, end_crs = "EPSG:25831"){
  if(transform == FALSE){
    opq <- opq(place)
    bbox <- opq$bbox
    bbox <- as.vector(sapply(str_split(bbox,","), as.numeric))
    return(bbox)
  }
  else{
    bbox <- getbb(place, format_out = "sf_polygon")
    bbox <- st_transform(bbox[1,], crs = end_crs)
    bbox <- st_bbox(bbox)
    bbox <- unname(bbox)
    bbox <- c(bbox[2], bbox[1], bbox[4], bbox[3])
    return(bbox)
  }
}