library(readr)
library(dplyr)
library(ggplot2)

most_reviews <- read_csv("../data_d3/listings_chch.csv") %>%
  slice_max(order_by = number_of_reviews, prop = 0.1)


summary_top <- most_reviews %>%
  summarise(
    count = n(),
    min_num_reviews = min(number_of_reviews, na.rm = TRUE),
    mean_num_reviews = mean(number_of_reviews, na.rm = TRUE),
    max_num_reviews = max(number_of_reviews, na.rm = TRUE),
  )

print(summary_top)


ggplot(most_reviews, aes(x = price)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "white", alpha = 0.8) +
  labs(
    title = "Price Distribution of top 10% listings by review count in Christchurch",
    x = "Price",
    y = "Count"
  ) +
  theme_minimal()
