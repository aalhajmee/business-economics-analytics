library(leaflet)

tabItem(tabName = "explore",
        h2("Explore"),
        p("Dive into the data and uncover insights."),
        leaflet() %>% setView(lng = -97.476204, lat = 39.293357, zoom = 4) %>% 
          addTiles()
)

