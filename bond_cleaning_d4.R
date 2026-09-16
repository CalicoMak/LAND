library(readr)
library(dplyr)

data.dir <- "../data_d3"

bonds <- read_csv(file.path(data.dir, "Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv"))

# Filter by time and the dwelling type / number of beds combination
bonds.filtered <- bonds %>%
  filter(
    TimeFrame >= as.Date("2025-10-01"),
    TimeFrame <= as.Date("2026-04-01"),
    `Dwelling Type` != "ALL",
    `Number Of Beds` == "ALL"
  ) %>%
  select(-`Number Of Beds`)

write_csv(bonds.filtered, file.path(data.dir, "bonds_cleaned.csv"))