library(readr)
library(dplyr)
library(lubridate)
library(yaml)

config <- read_yaml("config.yaml")

# Setup date metadata
dates <- c("2025-10", "2025-11", "2025-12", "2026-01", "2026-02", "2026-03", "2026-04", "2026-05", "2026-06")

# Initialise list to store data frames
data.list <- vector("list", length(dates))

# Loop over files
for (i in seq_along(dates)) {
  filepath <- file.path(config$data_dir, paste0("listings_", dates[i], ".csv"))
  
  data.list[[i]] <- read_csv(filepath, show_col_types = FALSE) %>%
    filter(neighbourhood_group == "Christchurch City") %>%
    mutate(timeframe = ym(dates[i]))
}

# Combine into single data frame
airbnb <- bind_rows(data.list)



# Keeping the particular columns
airbnb_clean <- airbnb %>%
  select(id, name, room_type, latitude, longitude, room_type, price,
         minimum_nights, availability_365, timeframe)

# Removing the na values from minimum_nights
airbnb_clean <- airbnb_clean %>%
  filter(!is.na(minimum_nights))

# Save the cleaned file
write_rds(airbnb_clean, file.path(config$out, "listings_chch.rds"))
