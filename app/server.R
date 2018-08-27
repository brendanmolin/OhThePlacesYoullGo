got_school <- function(input_unitid, input_level = 0, admissions) {
  school_stats <- admissions[admissions$unitid == input_unitid, c("p", "se")]
  threshold <- rnorm(1, school_stats[1,1], school_stats[1,2])
  dice <- runif(1)
  
  return(threshold > dice)
}

sim_season <- function(input_unitid_list, input_level_list, admissions) {
  application_n <- length(input_unitid_list)
  n <- 0
  output <- FALSE
  while((n + 1) <= application_n && output == FALSE) {
    n <- n + 1
    output <- got_school(input_unitid_list[n], input_level_list[n], admissions)
  }
  if(output == FALSE) n <- n + 1
  
  return(n)
}

sim_n <- function(n_sim, input_unitid_list, input_level_list, admissions) {
  results <- data.frame(priority = 1:(length(input_unitid_list) + 1),
                        schools = c(input_unitid_list, -1),
                        target = 0,
                        stringsAsFactors = FALSE)
  
  while(sum(results$target) < n_sim) {
    admitted <- sim_season(input_unitid_list, input_level_list, admissions)
    results[admitted, "target"] <- results[admitted, "target"] + 1
  }
  
  ggplot(data = results %>%
           left_join(dir, by = c("schools" = "unitid")) %>%
           mutate(inst_name = ifelse(is.na(inst_name), "none", inst_name),
                  probability = target/sum(target)),
         aes(x = reorder(inst_name, -priority), y = probability)) +
    geom_bar(stat = 'identity', fill = 'gray49') +
    coord_flip() +
    scale_y_continuous(labels = percent, limits = c(0, 1)) +
    labs(title = 'The Place You\'ll Probably Go', x = 'schools', y = "probability of enrolling")
}

get_unitid <- function(x) {
  dir[match(x, dir$inst_name),"unitid"]
}

plot_school_prob <- function(list_of_unitid) {
  priority <- data.frame(unitid = list_of_unitid, priority = 1:length(list_of_unitid))
  
  admissions %>%
    inner_join(priority, by = c("unitid" = "unitid")) %>%
    inner_join(dir, by = c("unitid" = "unitid")) %>%
    ggplot(aes(x = reorder(inst_name, -priority), y = p)) +
    geom_bar(stat = 'identity', fill = 'firebrick3') +
    geom_errorbar( aes(ymin=p-1.96*se, ymax=p+1.96*se), width=0.4, colour="blue", size=0.5) +
    coord_flip() +
    scale_y_continuous(labels = percent, limits = c(0, 1)) +
    labs(title = 'Your Chances of Getting Admitted', x = 'schools', y = "percent of applicants admitted")
}

plot_top_bottom_10 <- function(df) {
  df %>%
    arrange(p) %>%
    filter(row_number() %in% c(1:10, (n()-9):n())) %>%
    mutate(top_bottom = row_number() <= n()/2) %>%
    ggplot(aes(x = reorder(inst_name, -p), y = p, fill = top_bottom)) +
    geom_bar(stat = 'identity', position = 'dodge') +
    geom_errorbar( aes(ymin=p-1.96*se, ymax=p+1.96*se), width=0.4, colour="blue", size=0.5) +
    coord_flip() +
    scale_y_continuous(labels = percent, limits = c(0, 1)) +
    labs(title = 'Your Chances of Getting Admitted', x = 'schools', y = "percent of applicants admitted")
}

server <- function(input, output) {
  
  # Gets school unitid numbers from names
  lof_unitid <- eventReactive(input$schools, sapply(input$schools, get_unitid))
  
  ## APPLY tab
  # Runs and creates plot of simulation
  simRun <- eventReactive(input$go, {
    sim_n(1000, lof_unitid(), c(), admissions)
  })
  # Creates plot of admission probability
  probPlot <- eventReactive(input$schools, {
    plot_school_prob(lof_unitid())
  })
  # Renders simulation plot
  output$sim_plot <- renderPlot({
    print(simRun())
  })
  # Renders admission probability plot
  output$prop_plot <- renderPlot({
    print(probPlot())
  })
  
  ## EXPLORE tab
  # Filters schools
  key_states <- eventReactive(input$go_explore, {
    if(input$explore_state == 'All') {
      return(unique(dir$state_abbr))
    } else {
      input$explore_state
    }
  })
  df_subset <- eventReactive(input$go_explore, {
    explore_dir <- dir %>%
      inner_join(admissions, by = c("unitid" = "unitid")) %>%
      filter(state_abbr %in% key_states(),
             p >= input$explore_difficulty[1] & p <= input$explore_difficulty[2],
             inst_control %in% input$explore_control)
    
    return(explore_dir)
  })
  
  # Run
  plot_exp <- eventReactive(input$go_explore, plot_top_bottom_10(df_subset()))
  plot_map <- eventReactive(input$go_explore, {
    df <- df_subset()
    leaflet(data = df) %>%
      addTiles() %>%
      addMarkers(lng = ~longitude,
                 lat = ~latitude,
                 popup = paste(df$inst_name, "<br>",
                               "Type:", df$inst_control))
  })
  
  # Plot Map
  # Renders prob plot
  output$explore_prop_plot <- renderPlot({
    print(plot_exp())
  })
  
  output$explore_map <- renderLeaflet({
    print(plot_map())
  })
}
