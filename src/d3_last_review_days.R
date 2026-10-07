# Calculating and plotting how long ago the last review was (days) 

# Installing necessary libraries.
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(yaml)

config <- read_yaml("config.yaml")

# Reading in the concatenated chch .rds
airbnb <- read_rds(file.path(config$out_dir, "listings_chch.rds"))

# Build the scrape date lookup directly from the config.
# Each scrape date is keyed by the month it falls in ("YYYY-MM"),
# which is what the timeframe column represents.
scrape_dates <- tibble(
  scrape_date = ymd(unlist(config$scrape_dates))
) %>%
  mutate(timeframe = format(scrape_date, "%Y-%m"))

# Keep only id, name, last_review, timeframe
review_data <- airbnb %>%
  select(id, name, last_review, timeframe)

# Convert last_review to Date (YYYY-MM-DD), join the scrape date on
# timeframe, and calculate days since last review
review_data <- review_data %>%
  mutate(last_review = ymd(last_review)) %>%
  left_join(scrape_dates, by = "timeframe") %>%
  mutate(
    days_since_last_review = as.numeric(scrape_date - last_review)
  )

# Removing missing values and negative day counts
review_data <- review_data %>%
  filter(!is.na(days_since_last_review), days_since_last_review >= 0)

# Creating total histogram
ggplot(review_data, aes(x = days_since_last_review)) +
  geom_histogram(binwidth = 30, color = "white") +
  labs(
    title = "Distribution of Days Since Last Review",
    x = "Days Since Last Review",
    y = "Number of Listings"
  )

# Filtering to keep only listings reviewed in the last 360 days
review_data_recent <- review_data %>%
  filter(days_since_last_review <= 360)

# Create histogram for the last 360 days
ggplot(review_data_recent, aes(x = days_since_last_review)) +
  geom_histogram(binwidth = 15, color = "white") +
  labs(
    title = "Distribution of Days Since Last Review (Last 360 Days)",
    x = "Days Since Last Review",
    y = "Number of Listings"
  )
