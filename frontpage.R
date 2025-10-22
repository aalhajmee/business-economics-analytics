tabItem(
  tabName = "landing",
  
  tags$div(
    id = "carouselExampleIndicators",
    class = "carousel slide",
    `data-bs-ride` = "carousel",
    
    # Carousel indicators
    tags$div(
      class = "carousel-indicators",
      tags$button(type="button", `data-bs-target`="#carouselExampleIndicators", `data-bs-slide-to`="0", class="active", `aria-current`="true", `aria-label`="Slide 1"),
      tags$button(type="button", `data-bs-target`="#carouselExampleIndicators", `data-bs-slide-to`="1", `aria-label`="Slide 2"),
      tags$button(type="button", `data-bs-target`="#carouselExampleIndicators", `data-bs-slide-to`="2", `aria-label`="Slide 3")
    ),
    
    # Carousel inner slides
    tags$div(
      class = "carousel-inner",
      
      # Slide 1
      tags$div(
        class = "carousel-item active",
        tags$img(src = "buildings.jpg", class="d-block w-100"),
        tags$div(
          class = "carousel-caption d-none d-md-block",
          tags$h1("BUILD STRONG FINANCIAL FOUNDATIONS"),
          tags$p("Explore trends, markets, and opportunities that drive long-term success."),
          tags$a(href = "#", class = "btn btn-primary btn-lg", "Get started now »")
        )
      ),
      
      # Slide 2
      tags$div(
        class = "carousel-item",
        tags$img(src = "meeting.jpg", class="d-block w-100"),
        tags$div(
          class = "carousel-caption d-none d-md-block",
          tags$h1("TURN INSIGHTS INTO ACTION"),
          tags$p("Leverage real-time analytics to make confident financial decisions."),
          tags$a(href = "#", class = "btn btn-primary btn-lg", "Explore now »")
        )
      ),
      
      # Slide 3
      tags$div(
        class = "carousel-item",
        tags$img(src = "plant", class="d-block w-100"),
        tags$div(
          class = "carousel-caption d-none d-md-block",
          tags$h1("WHERE GROWTH BEGINS"),
          tags$p("Track, plan, and grow your wealth — one smart decision at a time."),
          tags$a(href = "#", class = "btn btn-primary btn-lg", "Learn more »")
        )
      )
    ),
    
    # Navigation arrows
    tags$button(class="carousel-control-prev", type="button", `data-bs-target`="#carouselExampleIndicators", `data-bs-slide`="prev",
                tags$span(class="carousel-control-prev-icon", `aria-hidden`="true"),
                tags$span(class="visually-hidden", "Previous")),
    
    tags$button(class="carousel-control-next", type="button", `data-bs-target`="#carouselExampleIndicators", `data-bs-slide`="next",
                tags$span(class="carousel-control-next-icon", `aria-hidden`="true"),
                tags$span(class="visually-hidden", "Next"))
  ),
  
  br(),
  h2(style="text-align:center; font-weight:600;", "WE GOT YOU COVERED!")
)