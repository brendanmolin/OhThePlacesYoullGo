library(educationdata)
library(dplyr)

if(!('educationdata' %in% installed.packages()[,"Package"])) devtools::install_github('UrbanInstitute/education-data-package-r')

admissions <- suppressMessages(educationdata::get_education_data(level = "college-university",
                                                                 source = 'ipeds',
                                                                 topic = 'admissions-enrollment',
                                                                 filters = list(year = 2015),
                                                                 add_labels = TRUE))

dir <- suppressMessages(educationdata::get_education_data(level = "college-university",
                                                          source = 'ipeds',
                                                          topic = 'directory',
                                                          filters = list(year = 2015),
                                                          add_labels = TRUE))

admissions <- admissions %>%
  filter(sex == 'Total',
         ftpt == 'Total',
         !is.na(number_applied),
         number_enrolled > 0,
         number_applied > 0) %>%
  select(-year, -sex, -ftpt)

dir <- dir %>%
  filter(unitid %in% admissions$unitid) %>%
  select(unitid, inst_name, state_abbr, zip, latitude, longitude, inst_control, hbcu)

write.csv(admissions, "app/data/admissions.csv", row.names = FALSE)
write.csv(dir, "app/data/dir.csv", row.names = FALSE)