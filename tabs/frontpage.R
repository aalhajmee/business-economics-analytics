tags$script(HTML("
  function goToTab(tabName) {
    Shiny.setInputValue('go_to_tab', tabName, {priority: 'event'});
  }
"))

tabItem(
  tabName = "home",
  # --- Page Title ---
  h2("Take control of your financial future!",
     style = "text-align:center;
              font-family:'Trebuchet MS', sans-serif;
              font-weight:700;
              font-size:30px;"),
  br(),
  
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
    transition: transform 0.6s ease;
    display: block;
  }

  /* Slight zoom effect on hover */
  .hero-section:hover img {
    transform: scale(1.03);
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

  /* Box faint by default, darkens on hover */
  .caption-bg {
    background-color: rgba(0, 0, 0, 0.2);
    border-radius: 12px;
    padding: 30px 40px;
    display: inline-block;
    max-width: 80%;
    transition: background-color 0.6s ease;
  }

  /* Darken background on hover */
  .hero-section:hover .caption-bg {
    background-color: rgba(0, 0, 0, 0.45);
  }

  /* Text & button always visible */
  .caption-bg h1,
  .caption-bg p {
    color: white !important;
    margin: 0 0 15px 0;
    opacity: 1;
    transition: none;
  }

  .caption-bg h1 {
    font-size: 3.5rem;
    font-weight: 700;
    margin-bottom: 2rem;
  }

  .caption-bg p {
    font-size: 2rem;
    margin-bottom: 3rem;
  }

  .btn-primary {
    background-color: #007bff;
    border: none;
    padding: 1.5rem 3rem;
    font-size: 1.5rem;
    border-radius: 0.8rem;
  }

  .btn-primary:hover {
    background-color: #0056b3;
  }

  /* Fade animation for tab transitions */
  .tab-pane {
    opacity: 0;
    transition: opacity 0.4s ease-in-out;
  }
  .tab-pane.active {
    opacity: 1;
  }
")),
  
  
  # --- Slide 1 ---
  tags$div(
    class = "hero-section",
    tags$img(src = "buildings.jpg"),
    tags$div(
      class = "hero-caption",
      tags$div(
        class = "caption-bg",
        tags$h1("BUILD STRONG FINANCIAL FOUNDATIONS"),
        tags$p("Explore trends and opportunities that drive long-term success."),
        tags$button(
          class = "btn btn-primary btn-lg",
          onclick = "goToTab('cfhi')",
          "Get started now »"
        )
      )
    )
  ),
  
  # --- Slide 2 ---
  tags$div(
    class = "hero-section",
    tags$img(src = "meeting.jpg"),
    tags$div(
      class = "hero-caption",
      tags$div(
        class = "caption-bg",
        tags$h1("TURN INSIGHTS INTO ACTION"),
        tags$p("Leverage real-time analytics to make confident financial decisions."),
        tags$button(
          class = "btn btn-primary btn-lg",
          onclick = "goToTab('explore')",
          "Explore »"
        )
      )
    )
  ),
  
  # --- Slide 3 ---
  tags$div(
    class = "hero-section",
    tags$img(src = "stock.jpg"),
    tags$div(
      class = "hero-caption",
      tags$div(
        class = "caption-bg",
        tags$h1("CORRELATION WITH FINANCIAL MARKETS"),
        tags$p("Track the relationship between the S&P 500 and your financial health"),
        tags$button(
          class = "btn btn-primary btn-lg",
          onclick = "goToTab('market_correlation')",
          "Compare»"
        )
      )
    )
  ),
  
  # --- Slide 4 ---
  tags$div(
    class = "hero-section",
    tags$img(src = "plant.jpg"),
    tags$div(
      class = "hero-caption",
      tags$div(
        class = "caption-bg",
        tags$h1("WHERE GROWTH BEGINS"),
        tags$p("Track, plan, and grow your wealth, one smart decision at a time."),
        tags$button(
          class = "btn btn-primary btn-lg",
          onclick = "goToTab('overview')",
          "Learn more »"
        )
      )
    )
  ),
)
