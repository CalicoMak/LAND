library(readr)
library(dplyr)
library(lubridate)
library(arrow)
library(yaml)

config <- read_yaml("config.yaml")

# Define parameters
airbnb.months <- config$airbnb_months
neighbourhood <- "Christchurch City"

# Initialise list to store data frames
data.list <- vector("list", length(airbnb.months))

# Loop over files
for (i in seq_along(airbnb.months)) {
  filepath <- file.path(config$data_dir, paste0("listings_", airbnb.months[i], ".csv"))
  
  data.list[[i]] <- read_csv(filepath, show_col_types = FALSE) %>%
    filter(neighbourhood_group == neighbourhood) %>%
    mutate(timeframe = ym(airbnb.months[i]))
}

# Combine into single data frame
airbnb <- bind_rows(data.list)

write_rds(airbnb, file.path(config$out, "listings_chch.rds"))


# Keeping the particular columns
airbnb.cleaned <- airbnb %>%
  select(id, name, room_type, latitude, longitude, room_type, price,
         minimum_nights, availability_365, timeframe)

# Removing the na values from minimum_nights
airbnb.cleaned <- airbnb.cleaned %>%
  filter(!is.na(minimum_nights))

# Save the cleaned file
write_parquet(airbnb.cleaned, file.path(config$out, "listings_chch_cleaned.parquet"))
