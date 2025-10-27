tags$script(HTML("
  function goToTab(tabName) {
    Shiny.setInputValue('go_to_tab', tabName, {priority: 'event'});
  }
"))

tabItem(
  tabName = "home",
  
  # Section styling
  tags$style(HTML("
    .hero-section {
      position: relative;
      height: 500px;
      margin-bottom: 2rem;
      overflow: hidden;
    }

    .hero-section img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      filter: brightness(80%);
    }

    .hero-caption {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      text-align: center;
      color: white;
      z-index: 2;
      width: 80%;
    }

    .hero-caption h1 {
      font-size: 2.5rem;
      font-weight: 700;
      margin-bottom: 1rem;
    }

    .hero-caption p {
      font-size: 1.2rem;
      margin-bottom: 1.5rem;
    }

    .btn-primary {
      background-color: #007bff;
      border: none;
      padding: 0.75rem 1.5rem;
      font-size: 1rem;
      border-radius: 0.4rem;
    }

    .btn-primary:hover {
      background-color: #0056b3;
    }
  ")),
  
  # --- Slide 1 ---
  tags$div(
    class = "hero-section",
    tags$img(src = "buildings.jpg"),
    tags$div(
      class = "hero-caption",
      tags$h1("BUILD STRONG FINANCIAL FOUNDATIONS"),
      tags$p("Explore trends, markets, and opportunities that drive long-term success."),
      tags$button(
        class = "btn btn-primary btn-lg",
        onclick = "goToTab('cfhi')",
        "Get started now »"
      )
    )
  ),
  
  # --- Slide 2 ---
  tags$div(
    class = "hero-section",
    tags$img(src = "meeting.jpg"),
    tags$div(
      class = "hero-caption",
      tags$h1("TURN INSIGHTS INTO ACTION"),
      tags$p("Leverage real-time analytics to make confident financial decisions."),
      tags$button(
        class = "btn btn-primary btn-lg",
        onclick = "goToTab('explore')",
        "Explore »"
      )
    )
  ),
  
  # --- Slide 3 ---
  tags$div(
    class = "hero-section",
    tags$img(src = "plant.jpg"),
    tags$div(
      class = "hero-caption",
      tags$h1("WHERE GROWTH BEGINS"),
      tags$p("Track, plan, and grow your wealth — one smart decision at a time."),
      tags$button(
        class = "btn btn-primary btn-lg",
        onclick = "goToTab('guide')",
        "Learn more »"
      )
    )
  ),
  
  br(),
  h2(style="text-align:center; font-weight:600;", "WE GOT YOU COVERED!")
)
