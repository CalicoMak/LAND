library(ggplot2)
library(readr)


# Load concatenated Christchurch dataset
df <- read_csv("../data_d3/listings_chch.csv")

# Remove missing prices
df_clean <- df[!is.na(df$price), ]

# IQR outlier removal
Q1 <- quantile(df_clean$price, 0.25)
Q3 <- quantile(df_clean$price, 0.75)
IQR_val <- Q3 - Q1
df_clean <- df_clean[df_clean$price >= Q1 - 1.5 * IQR_val & 
                       df_clean$price <= Q3 + 1.5 * IQR_val, ]

# Christchurch histogram
ggplot(df_clean, aes(x = price)) +
  geom_histogram(fill = "#7B7FC4", color = "white", bins = 40) +
  labs(title = "Distribution of price for Airbnb Christchurch",
       x = "price", y = "count") +
  theme_minimal()



