library(DBI)
library(RSQLite)
library(readr)

# 1. Load both CSV files
listings <- read_csv("listings_chch_codes.csv")
bonds <- read_csv("bonds_chch.csv")

# Ensure matching column types for joining
listings$sa2_code <- as.character(listings$sa2_code)
bonds$`Location ID` <- as.character(bonds$`Location ID`)

# 2. Connect to (or create) the SQLite database
con <- dbConnect(RSQLite::SQLite(), "rentals.db")

# 3. Store both datasets into SQLite tables
dbWriteTable(con, "airbnb", listings, overwrite = TRUE)
dbWriteTable(con, "bonds", bonds, overwrite = TRUE)

# 4. Perform the SQL Join
sql_join <- "
SELECT 
    a.id AS airbnb_id,
    a.name AS airbnb_name,
    a.sa2_code,
    a.price AS airbnb_price_per_night,
    b.TimeFrame,
    b.Dwelling_Type,
    b.Median AS bond_median_weekly_rent,
    b.Active_Bonds
FROM airbnb a
INNER JOIN bonds b 
    ON a.sa2_code = b.`Location ID`;
"

# Execute join and get the combined dataset
joined_dataset <- dbGetQuery(con, sql_join)

# View the joined dataset
head(joined_dataset)

# Clean up connection
dbDisconnect(con)
