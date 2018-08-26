pageWithSidebar(
  # HEADER AND DETAILS
  headerPanel('Oh, the Places You\'ll (Probably) Go'),
  # USER INPUT
  sidebarPanel(
    # Which schools you're applying to, in order of preference
    selectInput(inputId = 'schools', label = 'List of Schools to Apply to (in order of preference)',
                choices = sort(dir$inst_name), selected = c("Northeastern University", "Fordham University", "University of Miami", "George Mason University"),
                multiple = TRUE),
    actionButton("go", "Apply")
  ),
  # OUTPUT
  mainPanel(
    # Probability of getting admitted; updates with each change to input 'schools'
    plotOutput('prop_plot'),
    # Probability of going to each school; updates after action button
    plotOutput('sim_plot')
  )
)