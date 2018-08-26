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

server <- function(input, output) {
  
  lof_unitid <- eventReactive(input$schools, sapply(input$schools, get_unitid))
  
  simRun <- eventReactive(input$go, {
    sim_n(1000, lof_unitid(), c(), admissions)
  })
  
  probPlot <- eventReactive(input$schools, {
    plot_school_prob(lof_unitid())
  })
  
  output$sim_plot <- renderPlot({
    print(simRun())
  })
  
  output$prop_plot <- renderPlot({
    print(probPlot())
  })
}
