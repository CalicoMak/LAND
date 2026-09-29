library(readr)
library(dplyr)

data.dir <- "../data_LAND"

bonds <- read_csv(file.path(data.dir, "Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv"))

# Filter by time and ensure aggregation over both dwelling type and number of beds
bonds.filtered <- bonds %>%
  filter(
    TimeFrame >= as.Date("2025-10-01"),
    TimeFrame <= as.Date("2026-04-01"),
    `Dwelling Type` == "ALL",
    `Number Of Beds` == "ALL"
  ) %>%
  select(-`Dwelling Type`, -`Number Of Beds`)

write_csv(bonds.filtered, file.path(data.dir, "tenancy_cleaned.csv"))