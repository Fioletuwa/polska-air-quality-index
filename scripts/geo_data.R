library(sf)
library(tidyverse)

woj_shp <- st_read("data\\Wojewodztwa\\Województwa.shp")

gdzie_na <- which(is.na(woj_shp), arr.ind = T)
gdzie_na_kolumny <- gdzie_na[,-1] %>% unique()

woj_shp_bez_na <- woj_shp[,-gdzie_na_kolumny]

woj_nazwy <- woj_shp_bez_na$JPT_NAZWA_

fill_nazwy <- fill_polygons$województwo

