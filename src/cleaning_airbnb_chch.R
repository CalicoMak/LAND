library(readr)
library(dplyr)
library(lubridate)
library(yaml)

config <- read_yaml("config.yaml")

# Initialise list to store data frames
data.list <- vector("list", length(config$airbnb_months))

# Loop over files
for (i in seq_along(config$airbnb_months)) {
  filepath <- file.path(config$data_dir, paste0("listings_", dates[i], ".csv"))
  
  data.list[[i]] <- read_csv(filepath, show_col_types = FALSE) %>%
    filter(neighbourhood_group == "Christchurch City") %>%
    mutate(timeframe = ym(dates[i]))
}

# Combine into single data frame
airbnb <- bind_rows(data.list)

write_rds(airbnb, file.path(config$out, "listings_chch.rds"))


# Keeping the particular columns
airbnb_clean <- airbnb %>%
  select(id, name, room_type, latitude, longitude, room_type, price,
         minimum_nights, availability_365, timeframe)

# Removing the na values from minimum_nights
airbnb_clean <- airbnb_clean %>%
  filter(!is.na(minimum_nights))

# Save the cleaned file
write_rds(airbnb_clean, file.path(config$out, "listings_chch_cleaned.rds"))
