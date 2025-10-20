library(leaflet)

tabItem(tabName = "explore",
        h2("Explore"),
        p("Dive into the data and uncover insights."),
        leaflet() %>% setView(lng = 39.293357, lat = -97.476204, zoom = 12) %>% 
          addTiles()
)

