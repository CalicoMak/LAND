library(dplyr)
library(ggplot2)
library(scales)

# Read joined data
joined <- read.csv("../data_LAND/joined_airbnb_tenancy.csv")

# Make sure variables have the correct types
joined <- joined %>%
  mutate(
    quarter = as.Date(quarter),
    a_month = as.Date(a_month),
    sa2_code = as.character(sa2_code),
    a_id = as.character(a_id)
  )


# ---------------------------------------------------------
# 1. Count UNIQUE Airbnb listings per quarter + SA2
# ---------------------------------------------------------

airbnb_counts <- joined %>%
  distinct(quarter, sa2_code, a_id) %>%
  group_by(quarter, sa2_code) %>%
  summarise(
    airbnb_listings = n(),
    .groups = "drop"
  )


# ---------------------------------------------------------
# 2. Get ONE active-bond value per quarter + SA2
# ---------------------------------------------------------

tenancy_counts <- joined %>%
  select(
    quarter,
    sa2_code,
    t_bonds_active
  ) %>%
  distinct() %>%
  group_by(quarter, sa2_code) %>%
  summarise(
    active_bonds = first(na.omit(t_bonds_active)),
    .groups = "drop"
  )


# ---------------------------------------------------------
# 3. Join Airbnb and tenancy counts
# ---------------------------------------------------------

rental_comparison <- airbnb_counts %>%
  left_join(
    tenancy_counts,
    by = c("quarter", "sa2_code")
  )


# ---------------------------------------------------------
# 4. Calculate Airbnb listings as % of active bonds
# ---------------------------------------------------------

rental_comparison <- rental_comparison %>%
  mutate(
    airbnb_percent_of_active_bonds =
      (airbnb_listings / active_bonds) * 100
  )


# ---------------------------------------------------------
# 5. Select the top 15 SA2s in each quarter
# ---------------------------------------------------------

top_areas <- rental_comparison %>%
  filter(!is.na(airbnb_percent_of_active_bonds)) %>%
  group_by(quarter) %>%
  slice_max(
    order_by = airbnb_percent_of_active_bonds,
    n = 15,
    with_ties = FALSE
  ) %>%
  ungroup()


# ---------------------------------------------------------
# 6. Make the graph
# ---------------------------------------------------------

ggplot(
  top_areas,
  aes(
    x = reorder(sa2_code, airbnb_percent_of_active_bonds),
    y = airbnb_percent_of_active_bonds
  )
) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ quarter, scales = "free_y") +
  labs(
    title = "Airbnb listings relative to active rental bonds",
    subtitle = "Top 15 SA2 areas in each quarter",
    x = "SA2 code",
    y = "Airbnb listings as % of active bonds"
  ) +
  scale_y_continuous(
    labels = label_percent(scale = 1)
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    axis.text.y = element_text(size = 8)
  )
