library(shiny)
library(dplyr)
library(ggplot2)
library(scales)
library(leaflet)

# Import
admissions <- read.csv("data/admissions.csv", stringsAsFactors = FALSE)
dir <- read.csv("data/dir.csv", stringsAsFactors = FALSE)