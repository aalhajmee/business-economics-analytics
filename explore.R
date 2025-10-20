library(leaflet)

tabItem(tabName = "explore",
        h2("Explore"),
        p("Dive into the data and uncover insights."),
        leaflet(Data) %>% addProviderTiles(providers$Stamen.TonerLite) %>%
)

