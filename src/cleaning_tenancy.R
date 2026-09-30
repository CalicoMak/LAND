library(readr)
library(dplyr)
library(yaml)

config <- read_yaml("config.yaml")

bonds <- read_csv(file.path(config$data_dir, "Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv"))

# Filter by time and ensure aggregation over both dwelling type and number of beds
bonds.filtered <- bonds %>%
  filter(
    TimeFrame >= as.Date("2025-10-01"),
    TimeFrame <= as.Date("2026-04-01"),
    `Dwelling Type` == "ALL",
    `Number Of Beds` == "ALL"
  ) %>%
  select(-`Dwelling Type`, -`Number Of Beds`)

write_rds(bonds.filtered, file.path(config$data_dir, "tenancy_cleaned.rds"))