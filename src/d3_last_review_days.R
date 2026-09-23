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
  select(id, name, last_review, month_year)

# Changing 'last_review' string to Date (YYYY-MM-DD)
review_data <- review_data %>%
  mutate(last_review = ymd(last_review))


scrape_lookup <- tibble(
  month_year = c(
    "October 2025", 
    "November 2025", 
    "December 2025", 
    "January 2026", 
    "February 2026", 
    "March 2026", 
    "April 2026", 
    "May 2026", 
    "June 2026"
    ), 
  scrape_date = as.Date(c(
    "2025-10-05", 
    "2025-11-25", 
    "2025-12-11", 
    "2026-01-16", 
    "2026-02-13", 
    "2026-03-17", 
    "2026-04-16", 
    "2026-05-23", 
    "2026-06-19"
    ))
  )

review_data <- review_data %>% 
  left_join(scrape_lookup, by = "month_year") %>% 
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
