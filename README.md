# The Place You'll Probably Go

This project is a very simple demonstration of a Markov Chain Simulation in a Shiny application using data from the Urban Institute's education data API.  

## Description

The application allows the user to see the probability they will go to a given school given their ranked order of preference and self-assessed applicant quality.  Using information on application and enrollment rates in each university, we determine the probability of an applicant getting into a school, adjusted for the applicant quality.  We then simulate whether or not they get into their first choice, and if not their second choice, and so on and so forth.  We run the simulation 1000 times, thus determining the probability of an applicant going to each school.

## Data Source

The data we are using is sourced from the Urban Institute, who collects and cleans various public datasets and makes them available through an API.

API Documentation: https://ed-data-portal.urban.org/documentation/

## Tools

We use the following tools:
* R
  * shiny
  * dplyr
  * ggplot2
  * scales
  * leaflet
  * education_data
* shinyapps.io

## Repository

The src/ folder contains the script to pull the data we need for the app, clean it, and save it to the app/data/ folder.  The app/ folder contains the scripts for the application, and is pushed to shinyapps.io.
