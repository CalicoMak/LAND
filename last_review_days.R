# Calculating and plotting how long ago the last review was (days) 

# Installing necessary libraries.
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)

# Reading in the concatenated chch .csv
airbnb <- read_csv("../data_d3/listings_chch.csv")

# Filtering columns to keep only id, name, last_review
review_data <- airbnb %>%
  select(id, name, last_review)

# Changing 'last_review' string to Date (YYYY-MM-DD)
review_data <- review_data %>%
  mutate(last_review = ymd(last_review))

# Adding column with scrape date
review_data <- review_data %>%
  mutate(scrape_date = ymd("2026-06-19"))

# Calculating difference between scrape_date and last_review
review_data <- review_data %>%
  mutate(days_since_last_review = as.numeric(scrape_date - last_review))

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
