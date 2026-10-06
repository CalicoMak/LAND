library(readr)
library(dplyr)
library(lubridate)
library(yaml)

config <- read_yaml("config.yaml", readLines.warn = FALSE)
tenancy <- read_csv(file.path(config$data_dir, "Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv"))

# Define parameters
start_month <- config$airbnb_months[[1]]
end_month <- config$airbnb_months[[length(config$airbnb_months)]]

# Filter by time and ensure aggregation over both dwelling type and number of beds
tenancy.cleaned <- tenancy %>%
  filter(
    TimeFrame >= ym(start_month),
    TimeFrame <= ym(end_month),
    `Dwelling Type` == "ALL",
    `Number Of Beds` == "ALL"
  ) %>%
  select(-`Dwelling Type`, -`Number Of Beds`)

write_rds(tenancy.cleaned, file.path(config$out_dir, "tenancy_cleaned.rds"))