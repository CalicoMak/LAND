library(readr)
library(dplyr)
# library(ggplot2)

most_reviews <- read_csv("../data_d3/listings_chch.csv") %>%
  slice_max(order_by = number_of_reviews, prop = 0.1)


summary_top <- summarise(
    count = n(),
    min_num_reviews = min(number_of_reviews, na.rm = TRUE),
    mean_num_reviews = mean(number_of_reviews, na.rm = TRUE),
    max_num_reviews = max(number_of_reviews, na.rm = TRUE),
    min_price = min(price, na.rm = TRUE),
    mean_price = mean(price, na.rm = TRUE),
    max_price = max(price, na.rm = TRUE)
  )

print(summary_top)


# ggplot(filtered_data, aes(x = price)) +
#   geom_histogram(bins = 30, fill = "steelblue", color = "white", alpha = 0.8) +
#   labs(
#     title = "Price Distribution of Top 10% Filtered Rows",
#     x = "Price",
#     y = "Count"
#   ) +
#   theme_minimal()