library(tidyverse)
library(sf)

colors_indeks <- c("Bardzo dobry" = "darkgreen", "Dobry" = "green", "Umiarkowany" = "yellow", "Dostateczny" = "orange", "Zły" = "red", "Bardzo zły" = "black")

mapowanie_stacji <- stacja_joint_indeks_name %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326)

mapowanie_stacji_t <- st_transform(mapowanie_stacji, crs = 2163)

ggplot() +
  scale_fill_manual(values = colors_indeks, aesthetics = c("fill", "color"), breaks = c("Bardzo dobry", "Dobry", "Umiarkowany", "Dostateczny", "Zły", "Bardzo zły")) +
  scale_shape_manual(values = 21) +
  geom_sf(data = woj_shp_bez_na, color = 'black', aes(fill = factor(each_woj_index))) +
  geom_sf(data = mapowanie_stacji_t, aes(color = 'black', fill = Name), shape = 21) +
  ggtitle("Mapa Polskiego Indeksu Jakości Powietrza dla dnia 10.01.2023") +
  labs(fill = 'Indeks Województwa', color = 'Indeks Stacji') +
  coord_sf() +
  theme_void() +
  theme(legend.position = "left", legend.direction = "vertical", legend.box.margin = margin(0, 0, 0, 6))

