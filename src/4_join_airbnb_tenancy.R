library(DBI)
library(RSQLite)
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(arrow)
library(yaml)

config <- read_yaml("config.yaml", readLines.warn = FALSE)

airbnb <- read_parquet(file.path(config$out_dir, "airbnb_chch_codes.parquet"))
tenancy <- read_rds(file.path(config$out_dir, "tenancy_cleaned.rds"))

# tenancy$`Median Rent` <- as.numeric(tenancy$`Median Rent`)

# Ensure SA2 code is the same type for joining
airbnb$sa2_code <- as.character(airbnb$sa2_code) 
tenancy$`Location Id` <- as.character(tenancy$`Location Id`)

# Create a quarter column in airbnb
airbnb <- airbnb %>%
  mutate(quarter = floor_date(timeframe, unit = "quarter"))

# Create SQLite database file inside the data folder
con <- dbConnect(RSQLite::SQLite(), ":memory:", extended_types = TRUE)

# Write data frames into SQLite tables
dbWriteTable(con, "airbnb", airbnb)
dbWriteTable(con, "tenancy", tenancy)

# Left join on tenancy, on quarter and SA2
# Keep desired columns, rename according to whether they relate to airbnb or tenancy
sql_join <- "
SELECT
    a.quarter,
    a.sa2_code,
    a.timeframe AS a_month,
    a.id AS a_id,
    a.room_type AS a_type,
    a.price AS a_nightlyprice,
    a.minimum_nights AS a_min_nights,
    a.availability_365 AS a_availability_365,
    t.`Total Bonds` AS t_bonds_total,
    t.`Active Bonds` AS t_bonds_active,
    t.`Closed Bonds` AS t_bonds_closed,
    t.`Median Rent` AS t_rent_median,
    t.`Geometric Mean Rent` AS t_rent_geometricmean,
    t.`Upper Quartile Rent` AS t_rent_75,
    t.`Lower Quartile Rent` AS t_rent_25,
    t.`Log Std Dev Weekly Rent` AS t_rent_logstddev
FROM airbnb a
LEFT JOIN tenancy t
    ON a.quarter = t.TimeFrame
    AND a.sa2_code = t.`Location Id`;
"

joined_data <- dbGetQuery(con, sql_join)

write_rds(joined_data, file.path(config$out_dir, "joined_airbnb_tenancy.rds"))

dbDisconnect(con)

nrow(airbnb)
nrow(joined_data)
