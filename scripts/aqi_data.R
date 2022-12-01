library(jsonlite)
library(tidyverse)

#Pobieranie wszystkich danych o wszystkich stacjach pomiarowych
stacje <- fromJSON("https://api.gios.gov.pl/pjp-api/rest/station/findAll")
stacje <- stacje %>% tibble()
stacje_all_id <- stacje$id


#Pobieranie danych o polskim indeksie jakości powietrza, jeśli dana stacja udostępnia taki indeks (id stacji, indeks, data pomiaru)
air_data <- c()

for (i in 1:length(stacje_all_id)) {
  stacja <- fromJSON(paste0("https://api.gios.gov.pl/pjp-api/rest/aqindex/getIndex/", stacje_all_id[i]))
  if (stacja$stIndexStatus == TRUE) {
    indeks_id <- stacja$stIndexLevel$id
    data_pomiaru <- stacja$stCalcDate
    vec <- c(stacje_all_id[i], indeks_id, data_pomiaru)
    air_data <- c(air_data, vec)
  }
}
rm(stacja, data_pomiaru, indeks_id, vec)

#Pozyskane dane umieszczamy w przystępniejszej do odczytu formie
air_data_m <- matrix(air_data, ncol = 3, byrow = T)
air_data_tib <- as_tibble(air_data_m, .name_repair = "unique")
names(air_data_tib) <- c("Id", "Indeks_Id", "Data Pomiaru")
air_data_tib$Id <- as.numeric(air_data_tib$Id)
air_data_tib$Indeks_Id <- as.numeric(air_data_tib$Indeks_Id)

#Tworzymy osobną tabelę wyłącznie dla danych o indeksie i jego id
indeks_id_name <- tibble(Name = c("Bardzo zły", "Zły", "Dostateczny", "Umiarkowany", "Dobry", "Bardzo dobry"), Id = c(seq(5, 0, by = -1)))

#Tworzymy połączoną tabelę
air_data_joint <- air_data_tib %>% inner_join(indeks_id_name, by = c("Indeks_Id" = "Id"))

#Nadajemy factor dla rozróżnienia nazw indeksów
air_data_joint$Name <- ordered(air_data_joint$Name, levels = c("Bardzo zły", "Zły", "Dostateczny", "Umiarkowany", "Dobry", "Bardzo dobry"))
  
#Wybieramy stacje z aktywnym indeksem jakości powietrza, zmieniamy charakterystykę trzech kluczowych kolumn
stacje_data_w_index <- stacje %>%
  mutate(id = as.integer(id), 
         gegrLon = round(as.numeric(gegrLon), digits = 4), 
         gegrLat = round(as.numeric(gegrLat), digits = 4)) %>%
  filter(id %in% as.numeric(air_data_tib$Id))

#Wybieramy poszczególne kolumny (ponieważ jest ich 10, nie 6) i tworzymy nową, poprawioną ramkę danych (prawdopodobnie można byłoby zrobić to prościej)
SDWI_id <- stacje_data_w_index$id
SDWI_nazwa <- stacje_data_w_index$stationName
SDWI_Lat <- stacje_data_w_index$gegrLat
SDWI_Long <- stacje_data_w_index$gegrLon
SDWI_miasto_id <- stacje_data_w_index$city$id
SDWI_miasto <- stacje_data_w_index$city$name
SDWI_gmina <- stacje_data_w_index$city$commune$communeName
SDWI_powiat <- stacje_data_w_index$city$commune$districtName
SDWI_województwo <- tolower(stacje_data_w_index$city$commune$provinceName)
SDWI_adres <- stacje_data_w_index$addressStreet

stacje_z_indeksem <- tibble(as_tibble_col(SDWI_id, column_name = "id"),
                            as_tibble_col(SDWI_nazwa, column_name = "nazwa_stacji"),
                            as_tibble_col(SDWI_Long, column_name = "long"),
                            as_tibble_col(SDWI_Lat, column_name = "lat"),
                            as_tibble_col(SDWI_miasto_id, column_name = "miasto_id"),
                            as_tibble_col(SDWI_miasto, column_name = "miasto"),
                            as_tibble_col(SDWI_gmina, column_name = "gmina"),
                            as_tibble_col(SDWI_powiat, column_name = "powiat"),
                            as_tibble_col(SDWI_województwo, column_name = "województwo"),
                            as_tibble_col(SDWI_adres, column_name = "adres"))

rm(SDWI_id, SDWI_nazwa, SDWI_Lat, SDWI_Long, SDWI_miasto_id, SDWI_miasto, SDWI_gmina, SDWI_powiat, SDWI_województwo, SDWI_adres)

stacja_indeks_joint <- stacje_z_indeksem %>%
  inner_join(air_data_tib, by = c("id" = "Id")) %>%
  select(id, Indeks, long, lat, województwo)

stacja_indeks_joint %>%
  select(-id, -long, -lat) %>%
  group_by(województwo, Indeks) %>%
  summarize(n = n()) %>%
  print(n = Inf)

fill_polygons <- stacja_indeks_joint %>%
  select(-id, -long, -lat) %>%
  group_by(województwo, Indeks) %>%
  summarize(n = n()) %>%
  arrange(-n) %>%
  group_by(województwo) %>%
  slice_head(n = 1)


fill_polygons <- fill_polygons[order(order(woj_nazwy)),]

each_woj_index <- fill_polygons$Indeks

woj_shp_bez_na_2 <- woj_shp_bez_na %>%
  add_column(.before = 'geometry' ,each_woj_index)
