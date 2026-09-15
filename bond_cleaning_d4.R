library(readr)
library(dplyr)
library(sf)

data.dir <- "../data_d3"
sa2ref.name <- "statistical-area-2-higher-geographies-2019-generalised"

# Read only the attributes by explicitly selecting columns and omitting the geometry
sa2ref <- st_read(
  file.path(data.dir, "statistical-area-2-higher-geographies-2019-generalised.gpkg"),
  query = "SELECT SA22019_V1_00, TA2019_V1_00_NAME FROM statistical_area_2_higher_geographies_2019_generalised",
  quiet = TRUE
)

# Get the relevant SA2 codes for Christchurch City
sa2ref.chch <- sa2ref %>%
  filter(TA2019_V1_00_NAME == "Christchurch City") %>%
  pull(SA22019_V1_00)

bonds <- read_csv(file.path(data.dir, "Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv"))

# Filter by location, time, and the dwelling type / number of beds combination
bonds.filtered <- bonds %>%
  filter(
    TimeFrame >= as.Date("2025-10-01"),
    TimeFrame <= as.Date("2026-04-01"),
    `Location Id` %in% sa2ref.chch#,
    # `Dwelling Type` != "ALL",
    # `Number Of Beds` == "ALL"
  ) #%>%
  # select(-`Number Of Beds`)

write_csv(bonds.filtered, file.path(data.dir, "bonds_chch.csv"))