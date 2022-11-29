library(tidyverse)
library(sf)

colors_indeks <- c("Bardzo dobry" = "darkgreen", "Dobry" = "green", "Umiarkowany" = "yellow", "Dostateczny" = "orange", "Zły" = "red", "Bardzo zły" = "black")

mapowanie_stacji <- stacja_indeks_joint %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326)

mapowanie_stacji_t <- st_transform(mapowanie_stacji, crs = 2163)

ggplot() +
  scale_fill_manual(values = colors_indeks, aesthetics = c("fill", "color")) +
  scale_shape_manual(values = 21) +
  geom_sf(data = woj_shp_bez_na_2, color = 'black', aes(fill = factor(each_woj_index))) +
  geom_sf(data = mapowanie_stacji_t, aes(color = 'black', fill = Indeks), shape = 21) +
  ggtitle("Mapa Polskiego Indeksu Jakości Powietrza dla dnia 27.11.2022") +
  labs(fill = 'Indeks Województwa', color = 'Indeks Stacji') +
  coord_sf() +
  theme_void() +
  theme(legend.position = "left", legend.direction = "vertical")
