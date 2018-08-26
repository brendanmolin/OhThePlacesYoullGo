library(shiny)
library(dplyr)
library(ggplot2)
library(scales)

# Import
admissions <- read.csv("data/admissions.csv", stringsAsFactors = FALSE)
dir <- read.csv("data/dir.csv", stringsAsFactors = FALSE)