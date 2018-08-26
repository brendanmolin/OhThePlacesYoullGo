pageWithSidebar(
  headerPanel('Oh, the Places You\'ll (Probably) Go'),
  sidebarPanel(
    selectInput(inputId = 'schools', label = 'List of Schools to Apply to (in order of preference)',
                choices = sort(dir$inst_name), selected = c("Northeastern University", "Fordham University", "University of Miami", "George Mason University"),
                multiple = TRUE),
    actionButton("go", "Apply")
  ),
  mainPanel(
    plotOutput('prop_plot'),
    plotOutput('sim_plot')
  )
)