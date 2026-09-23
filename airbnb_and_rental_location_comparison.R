library(tidyverse)
library(readr)

# Load data
airbnb_comparison <- read_csv("../data_d3/listings_chch_codes.csv")
rentals_comparison <- read_csv("../data_d3/bonds_cleaned.csv")

# -----------------------------
# Prepare Airbnb data
# -----------------------------

airbnb_comparison <- airbnb_comparison %>%
  mutate(
    timeframe = as.Date(timeframe),
    sa2_code = as.character(sa2_code)
  )

# Dates matching the rental dataset
quarter_dates <- as.Date(c(
  "2025-10-01",
  "2026-01-01",
  "2026-04-01"
))

# Keep Airbnb observations from matching dates
airbnb_quarter <- airbnb_comparison %>%
  filter(timeframe %in% quarter_dates)

# Count unique Airbnb listings per location and date
airbnb_counts <- airbnb_quarter %>%
  group_by(timeframe, sa2_code) %>%
  summarise(
    airbnb_count = n_distinct(id),
    .groups = "drop"
  )

# -----------------------------
# Prepare rental data
# -----------------------------

rentals_comparison <- rentals_comparison %>%
  mutate(
    TimeFrame = as.Date(TimeFrame),
    `Location Id` = as.character(`Location Id`)
  )

# Sum active rental bonds across dwelling types and bed categories
rental_counts <- rentals_comparison %>%
  group_by(TimeFrame, `Location Id`) %>%
  summarise(
    rental_count = sum(`Active Bonds`),
    .groups = "drop"
  ) %>%
  rename(
    timeframe = TimeFrame,
    sa2_code = `Location Id`
  )

# -----------------------------
# Join datasets
# -----------------------------

comparison <- inner_join(
  airbnb_counts,
  rental_counts,
  by = c("timeframe", "sa2_code")
) %>%
  mutate(
    difference = airbnb_count - rental_count,
    airbnb_percentage =
      airbnb_count / (airbnb_count + rental_count) * 100
  )

# View results
print(comparison)

# -----------------------------
# April 2026 results
# -----------------------------

april_2026 <- comparison %>%
  filter(timeframe == as.Date("2026-04-01")) %>%
  arrange(desc(airbnb_count))

print(april_2026)

# -----------------------------
# Plot
# -----------------------------

ggplot(
  april_2026,
  aes(x = rental_count, y = airbnb_count)
) +
  geom_point() +
  labs(
    title = "Airbnb and long-term rental properties by SA2",
    subtitle = "Christchurch, April 2026",
    x = "Active long-term rental properties",
    y = "Airbnb listings"
  ) +
  theme_minimal()
