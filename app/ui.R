navbarPage("Oh, the Places You'll (Probably) Go!",
           tabPanel("Apply",
                    pageWithSidebar(
                      # HEADER AND DETAILS
                      headerPanel('Send Out Applications'),
                      # USER INPUT
                      sidebarPanel(
                        # Which schools you're applying to, in order of preference
                        selectInput(inputId = 'schools', label = 'List of Schools to Apply to (in order of preference)',
                                    choices = sort(dir$inst_name), selected = c("Northeastern University", "Fordham University", "University of Miami", "George Mason University"),
                                    multiple = TRUE),
                        # Run
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
           ),
           tabPanel("Explore",
                    pageWithSidebar(
                      # HEADER AND DETAILS
                      headerPanel('Find Your School'),
                      # USER INPUT
                      sidebarPanel(
                        ## Filter Schools
                        # Which states to look at
                        selectInput(inputId = 'explore_state', label = 'States',
                                    choices = c("All", sort(unique(dir$state_abbr))), selected = c("All"),
                                    multiple = TRUE),
                        # School difficulty
                        sliderInput("explore_difficulty", "Percent of Applicants Admitted:",
                                    min = 0, max = 1,
                                    value = c(0, 0.5), step = 0.05),
                        # Public vs Private
                        selectInput(inputId = 'explore_control', label = 'States',
                                    choices = sort(unique(dir$inst_control)), selected = c("Private for-profit", "Private not-for-profit", "Public"),
                                    multiple = TRUE),
                        # Run
                        actionButton("go_explore", "Explore")
                      ),
                      # OUTPUT
                      mainPanel(
                        # Probability of getting admitted to schools meeting requirements; top & bottom 10
                        plotOutput('explore_prop_plot'),
                        # Map of schools meeting requirements
                        leafletOutput('explore_map',height = 1000)
                      )
                    )
           )
)