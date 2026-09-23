library(DBI)
library(RSQLite)
library(readr)
library(dplyr)
library(lubridate)

# 1. Define parent directory path
data.dir <- "../data_d3"

# 2. Read CSV files using file.path()
listings <- read_csv(file.path(data.dir, "listings_chch_codes.csv"))
bonds <- read_csv(file.path(data.dir, "bonds_cleaned.csv"))

# 3. Ensure matching data types for joining
listings$sa2_code <- as.character(listings$sa2_code) 
bonds$`Location Id` <- as.character(bonds$`Location Id`)

listings <- listings %>%
  mutate(timeframe = as.Date(timeframe), 
         quarter = case_when(
           month(timeframe) %in% c(10,11,12) ~ "2025-10-01", 
           month(timeframe) %in% c(1, 2, 3) ~ "2026-01-01", 
           month(timeframe) %in% c(4,5,6) ~ "2026-04-01"
         ))

# 4. Create SQLite database file inside the data folder
con <- dbConnect(RSQLite::SQLite(), file.path(data.dir, "rentals.db"))

# 5. Forcing listing and bond data to be characters for attaching by similar (calculations already done)
bonds$TimeFrame <- as.character(as.Date(bonds$TimeFrame))
listings$quarter <- as.character(listings$quarter)  

# 6. Write data frames into SQLite tables
dbWriteTable(con, "airbnb", listings, overwrite = TRUE)
dbWriteTable(con, "bonds", bonds, overwrite = TRUE)

# 7. SQL Join Query using exact column names
sql_join <- "
WITH bonds_agg AS (
    SELECT
        `Location Id`,
        TimeFrame,
        SUM(`Median Rent` * `Total Bonds`) * 1.0 / SUM(`Total Bonds`) AS weighted_median_rent
    FROM bonds
    GROUP BY `Location Id`, TimeFrame
)
SELECT
    a.id AS airbnb_id,
    a.sa2_code,
    a.quarter,
    a.price AS airbnb_price_per_night,
    b.weighted_median_rent AS bond_median_weekly_rent
FROM airbnb a
INNER JOIN bonds_agg b
    ON a.sa2_code = b.`Location Id`
    AND a.quarter = b.TimeFrame;
"

joined_data <- dbGetQuery(con, sql_join)

# 7. Disconnect when finished
dbDisconnect(con)

# Preview results
head(joined_data)

