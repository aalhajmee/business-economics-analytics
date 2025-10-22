tabItem(
  tabName = "home",
  
  # Bootstrap JS for working carousel controls
  tags$head(
    tags$script(src = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js")
  ),
  
  # Carousel styling
  tags$style(HTML("
    /* overall carousel size */
    .carousel-item {
      height: 500px;
      position: relative;
    }

    /* make images auto-fit screen width */
    .carousel-item img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    /* ensure only one active slide shows */
    .carousel-item { display: none; }
    .carousel-item.active { display: block; }

    /* gradient overlay for readability */
    .carousel-item::before {
      content: '';
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: linear-gradient(to bottom, rgba(0,0,0,0.45), rgba(0,0,0,0.1));
      z-index: 1;
    }

    .carousel-caption { 
      z-index: 2;
    }

    /* center and style the arrows */
    .carousel-control-prev-icon,
    .carousel-control-next-icon {
      filter: invert(1) brightness(80%);
      width: 3rem;
      height: 3rem;
    }
  ")),
  
  # Carousel itself
  tags$div(
    id = "carouselExampleIndicators",
    class = "carousel slide carousel-fade",
    `data-bs-ride` = "carousel",
    `data-bs-interval` = "4000",  # auto-slide every 4 seconds
    
    # Indicators (dots)
    tags$div(
      class = "carousel-indicators",
      tags$button(type="button", `data-bs-target`="#carouselExampleIndicators", 
                  `data-bs-slide-to`="0", class="active", `aria-current`="true", `aria-label`="Slide 1"),
      tags$button(type="button", `data-bs-target`="#carouselExampleIndicators", 
                  `data-bs-slide-to`="1", `aria-label`="Slide 2"),
      tags$button(type="button", `data-bs-target`="#carouselExampleIndicators", 
                  `data-bs-slide-to`="2", `aria-label`="Slide 3")
    ),
    
    # Slides
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
        tags$img(src = "plant.jpg", class="d-block w-100"),
        tags$div(
          class = "carousel-caption d-none d-md-block",
          tags$h1("WHERE GROWTH BEGINS"),
          tags$p("Track, plan, and grow your wealth — one smart decision at a time."),
          tags$a(href = "#", class = "btn btn-primary btn-lg", "Learn more »")
        )
      )
    ),
    
    # Navigation arrows
    tags$button(
      class="carousel-control-prev", type="button",
      `data-bs-target`="#carouselExampleIndicators", `data-bs-slide`="prev",
      tags$span(class="carousel-control-prev-icon", `aria-hidden`="true"),
      tags$span(class="visually-hidden", "Previous")
    ),
    tags$button(
      class="carousel-control-next", type="button",
      `data-bs-target`="#carouselExampleIndicators", `data-bs-slide`="next",
      tags$span(class="carousel-control-next-icon", `aria-hidden`="true"),
      tags$span(class="visually-hidden", "Next")
    )
  ),
  
  br(),
  h2(style="text-align:center; font-weight:600;", "WE GOT YOU COVERED!")
)
