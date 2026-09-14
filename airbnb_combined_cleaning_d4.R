# Installing necessary libraries
library(readr)
library(dplyr)


# Loading the data
airbnb <- read_csv("../data_d3/listings_chch.csv")


# Keeping the particular columns
airbnb_clean <- airbnb %>%
  select(id, name, room_type, latitude, longitude, room_type, price,
         minimum_nights, availability_365, month_year)

# Removing the na values from minimum_nights
airbnb_clean <- airbnb_clean %>%
  filter(!is.na(minimum_nights))

# Save the cleaned file
write_csv(airbnb_clean, "../data_d3/listings_chch.csv")
