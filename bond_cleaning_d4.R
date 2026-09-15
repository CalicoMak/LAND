library(readr)
library(dplyr)

bonds <- read_csv("../data_d3/Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv")

sa2ref <- read_csv("statistical-area-2-higher-geographies-2019-generalised.csv")

# Get the relevant SA2 codes for Christchurch City
chch_sa2 <- sa2ref %>%
    filter(TA2019_V1_00_NAME == "Christchurch City") %>%
    pull(SA22019_V1_00)

bonds_filtered <- bonds %>%
    filter(
        `Location Id` %in% chch_sa2,
        TimeFrame >= as.Date("2025-10-01"),
        TimeFrame <= as.Date("2026-04-01")
    )

write_csv(bonds_filtered, "../data_d3/bonds_chch_filt.csv")
