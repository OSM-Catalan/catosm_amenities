library(tidyverse)
library(httr)
library(lubridate)
library(jsonlite)
baseurl <- "https://analisi.transparenciacatalunya.cat/resource/8gmd-gz7i.json?$query="
query <- "SELECT propietats WHERE propietats LIKE '%Horari%' LIMIT 10000"
query <- str_replace_all(query, "%","%25")
query <- str_replace_all(query, "'", "%27")
query <- str_replace_all(query," ","%20")

horaris <- GET(paste0(baseurl, query)) |> 
  content(as = "text") |> 
  fromJSON()


horaris |> write.csv("~/horaris.csv")
