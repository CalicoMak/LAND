library(DBI)
library(RSQLite)
library(readr)

# 1. Define parent directory path
data.dir <- "../data_d3"

# 2. Read CSV files using file.path()
listings <- read_csv(file.path(data.dir, "listings_chch_codes.csv"))
bonds <- read_csv(file.path(data.dir, "bonds_chch.csv"))

# 3. Ensure matching data types for joining
listings$sa2_code <- as.character(listings$sa2_code) 
bonds$`Location Id` <- as.character(bonds$`Location Id`)

# 4. Create SQLite database file inside the data folder
con <- dbConnect(RSQLite::SQLite(), file.path(data.dir, "rentals.db"))

# 5. Write data frames into SQLite tables
dbWriteTable(con, "airbnb", listings, overwrite = TRUE)
dbWriteTable(con, "bonds", bonds, overwrite = TRUE)

# 6. SQL Join Query using exact column names
sql_join <- "
SELECT 
    a.id AS airbnb_id,
    a.sa2_code,
    a.price AS airbnb_price_per_night,
    b.`Median Rent` AS bond_median_weekly_rent
FROM airbnb a
INNER JOIN bonds b 
    ON a.sa2_code = b.`Location Id`;
"

joined_data <- dbGetQuery(con, sql_join)

# 7. Disconnect when finished
dbDisconnect(con)

# Preview results
head(joined_data)