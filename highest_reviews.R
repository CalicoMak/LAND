library(readr)
library(dplyr)

summary_top <- read_csv("../data_d3/listings_chch.csv") %>%
  slice_max(order_by = number_of_reviews, prop = 0.1) %>%
  summarise(
    count = n(),
    min_num_reviews = min(number_of_reviews, na.rm = TRUE),
    mean_num_reviews = mean(number_of_reviews, na.rm = TRUE),
    max_num_reviews = max(number_of_reviews, na.rm = TRUE),
    min_price = min(price, na.rm = TRUE),
    mean_price = mean(price, na.rm = TRUE),
    max_price = max(price, na.rm = TRUE)
  )

print(summary_top)
