library(tidyverse)
library(plotly)
library(RColorBrewer)

brewer.pal(n = 6, name = 'RdYlGn')

plot_ly(data = woj_shp_bez_na, 
        color = ~each_woj_index,
        colors = colors_indeks,
        split = ~JPT_NAZWA_, 
        span = I(1), 
        showlegend = FALSE, 
        text = ~paste0("<b>", str_to_title(JPT_NAZWA_), "</b><br>","<b>Indeks</b>:", each_woj_index), 
        hoveron = "fills", 
        hoverinfo = "text") %>%
  config(displayModeBar = FALSE)
