## code to prepare `DATASET` dataset goes here
library(tidyverse)

correspondences <- read_csv("data-raw/categories_equipaments_gencat.csv")
correspondences <- correspondences[,-1] # remove row lines
correspondences <- pivot_longer(correspondences,-c(categoria_1, categoria_2, categoria_3),
                                names_to = "junk",
                                values_to = "value") # pivot_longer

correspondences <- correspondences |> filter(!is.na(value)) |> 
  mutate(junk = str_remove(junk, "\\d")) |> 
  pivot_wider(id_cols = c(categoria_1, categoria_2, categoria_3),
              names_from = junk,
              values_from = value) |> 
  unnest() # put all keys and all values in separate columns



usethis::use_data(correspondences, overwrite = TRUE)
