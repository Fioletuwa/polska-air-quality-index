library(tidyverse)

colors_indeks <- c("Bardzo dobry" = "darkgreen", "Dobry" = "green", "Umiarkowany" = "yellow", "Dostateczny" = "orange", "Zły" = "red", "Bardzo zły" = "black")


ggplot() +
  geom_sf(data = woj_shp_bez_na, color = 'black', fill = 'green') +
  ggtitle("Mapa") +
  coord_sf() +
  theme_void()
