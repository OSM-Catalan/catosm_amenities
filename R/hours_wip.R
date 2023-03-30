salut_be |> as_tibble()
head(as_tibble(select(salut_be, propietats)), 20)


hours <- sapply(salut_be$propietats, \(x) str_extract_all(x, "[\\d{1,2}][:]?[\\d{2}]?"), USE.NAMES = FALSE)
hours
