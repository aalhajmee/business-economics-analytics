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
        tags$img(src = "https://source.unsplash.com/1600x600/?city,skyline", class="d-block w-100"),
        tags$div(
          class = "carousel-caption d-none d-md-block",
          tags$h1("LOOKING FOR A PARTICULAR AREA?"),
          tags$p("Use our interactive map to identify pockets of opportunity."),
          tags$a(href = "#", class = "btn btn-primary btn-lg", "Get started now »")
        )
      ),
      
      # Slide 2
      tags$div(
        class = "carousel-item",
        tags$img(src = "https://source.unsplash.com/1600x600/?finance,office", class="d-block w-100"),
        tags$div(
          class = "carousel-caption d-none d-md-block",
          tags$h1("FIND YOUR NEXT INVESTMENT SPOT"),
          tags$p("Analyze regions with our custom-built financial insights dashboard."),
          tags$a(href = "#", class = "btn btn-primary btn-lg", "Explore now »")
        )
      ),
      
      # Slide 3
      tags$div(
        class = "carousel-item",
        tags$img(src = "https://source.unsplash.com/1600x600/?startup,meeting", class="d-block w-100"),
        tags$div(
          class = "carousel-caption d-none d-md-block",
          tags$h1("CONNECT DATA TO DECISIONS"),
          tags$p("Turn analytics into real-world financial growth opportunities."),
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