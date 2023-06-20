.onAttach <- function(libname, pkgname) {
  msg <- paste0(
    "Dades OSM sota llic\u00E8ncia ODbL 1.0. (c) Col\u00B7laboradors d'OpenStreetMap ",
    "https://www.openstreetmap.org/copyright",
    "Dades Generalitat sota llic\u00E8ncia oberta d'\u00FAs d'informaci\u00F3. (c) Generalitat de Catalunya ",
    "https://governobert.gencat.cat/ca/dades_obertes/llicencia-oberta-informacio-catalunya/"
  )
  packageStartupMessage(msg)
}
