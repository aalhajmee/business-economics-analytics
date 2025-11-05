Params <- c("startAmount", "growthRate", "standardDev", "inflation", "infStandardDev", 
            "withdrawals", "years", "sims")

sim <- function(startAmount = 100000, growthRate = 5.0, standardDev = 7.0, inflation = 2.5, 
                infStandardDev = 1.5, withdrawals = 1000, years = 20, sims = 200) {
  
  #Initial
  startAmount = startAmount
  
  #Investment
  growthRate = growthRate / 100
  standardDev = standardDev / 100
  
  #Inflation
  inflation = inflation / 100
  infStandardDev = infStandardDev / 100
  
  #Withdrawals
  withdrawals = withdrawals
  
  #Years
  years = years
  
  #Sims
  sims = sims
  
  
  
  years = 12 * years
  monthlyGR = growthRate / 12
  monthlySD = standardDev / sqrt(12)
  monthlyInfl = inflation / 12
  monthlyInfSD = infStandardDev / sqrt(12)
  
  monthlyRInvest = matrix(0, years, sims)
  monthlyRInf = matrix(0, years, sims)
  
  monthlyRInvest[] = rnorm(years * sims, mean = monthlyGR, sd = monthlySD)
  monthlyRInf[] = rnorm(years * sims, mean = monthlyInfl, sd = monthlyInfSD)
  
  nav = matrix(startAmount, years + 1, sims)
  for (j in 1:years) {
    nav[j + 1, ] = nav[j, ] * (1 + monthlyRInvest[j,] - monthlyRInf[j,]) - withdrawals
  }
  
  nav[ nav < 0 ] = 0
  nav = nav / 1000000
  return(nav)
  
}


plot_nav <- function(nav) {
  # Set up side-by-side plots
  par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))
  
  matplot(nav,
          type = 'l', lwd = 0.5, lty = 1, col = 1:5,
          xlab = 'Months', ylab = 'Millions',
          main = 'Projected Value of Initial Capital')
  
  living = 1 - rowSums(is.na(nav)) / ncol(nav)
  
  plot(100 * living, las = 1, xlab = 'Months', ylab = 'Percentage Paying',
       main = 'Percentage of Paying Scenarios', ylim = c(0,100))
  grid()
  
}

server <- function(input, output, session) {
  
  getParameters <- function(prefix)
    list(
      startAmount   = input[[paste0(prefix, "_startAmount")]],
      growthRate    = input[[paste0(prefix, "_growthRate")]],
      standardDev   = input[[paste0(prefix, "_standardDev")]],
      inflation     = input[[paste0(prefix, "_inflation")]],
      infStandardDev= input[[paste0(prefix, "_infStandardDev")]],
      withdrawals   = input[[paste0(prefix, "_withdrawals")]],
      years         = input[[paste0(prefix, "_years")]],
      sims          = 200
    )

  trigger_a <- reactiveVal(0)
  trigger_b <- reactiveVal(0)
  
  # Add button observers
  observeEvent(input$a_recalculate, {
    trigger_a(trigger_a() + 1)
  })
  
  observeEvent(input$b_recalculate, {
    trigger_b(trigger_b() + 1)
  })
  
  # Update reactive expressions to depend on triggers
  navA <- reactive({
    trigger_a() 
    do.call(sim, getParameters("a"))
  })
  
  navB <- reactive({
    trigger_b()  
    do.call(sim, getParameters("b"))
  })
  
  output$a_distPlot <- renderPlot({
    req(navA())
    plot_nav(navA())
  })
  output$b_distPlot <- renderPlot({
    req(navB())
    plot_nav(navB())
  })
  
}


