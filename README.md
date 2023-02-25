# catosm_amenities
Functions to find and complete amenities, shops, healthcare centres, and other POIS using open data



This is pretty much work in progress, all collaborations are welcome.
Molt en procés, tot just comença.

L'objectiu és fer una sèrie de funcions que permetin comparar objectes d'OSM en un territori (municipi o comarca) amb la informació treta de bases de dades obertes per veure si 1) falten objectes per a afegir a OSM o s'han de treure objectes que representen coses que no existeixen. 2) Completar objectes amb informació incompleta. La idea és treure'n un paquet que farà funcionar una app web.

## Bases de dades ubicades

1) [Directori de centres docents](https://analisi.transparenciacatalunya.cat/Educaci-/Directori-de-centres-docents-anual-Base-2020/kvmv-ahh4) - coneguda, prioritat baixa, tenim l'[app](https://marcbosch.shinyapps.io/escoles_osm/).
2) [Equipaments (Dades obertes de la Generalitat)](https://analisi.transparenciacatalunya.cat/Urbanisme-infraestructures/Equipaments-de-Catalunya/8gmd-gz7i) - Prioritat alta, no afegirem les escoles perquè farem servir el directori de centres educatius. Consultar llicència.
3) [Cens d'activitats econòmiques en Planta Baixa (Ajuntament de Barcelona)](https://opendata-ajuntament.barcelona.cat/data/ca/dataset/cens-activitats-comercials) - Prioritat alta, però són del 2019. Esperem que ho actualitzin aviat.
4) [Cens d'activitats econòmiques (Diputació de Barcelona](https://dadesobertes.diba.cat/datasets/cens-dactivitats-i-establiments) - Prioritat alta. Nota, no tenen columnes de latitud/longitud, s'han de geocodificar. És una situació una mica emprenyosa, s'haurà de veure com fer-ho eficient.

## COSES FETES

1) Funció per filtrar equipaments de la Generalitat a un bbox creat amb ```osmdata```
2) Funció per geocodificar comerços de la base de dades de la Diputació de Barcelona.

## COSES A FER

1) Donar equivalències entre les categories de les bases de dades i les claus i valors d'OSM.
2) Fer funcions per baixar les dades de les fonts estudiades a partir d'una query feta amb ```osmdata```
3) Fer visualitzacions ràpides per comparar.
4) Fer taules amb els objectes de les dues fonts

