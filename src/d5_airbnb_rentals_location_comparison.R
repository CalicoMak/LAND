suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(scales)
  library(readr)
  library(yaml)
})

config <- read_yaml("config.yaml", readLines.warn = FALSE)

# Reading in the joined data
joined <- read_rds(file.path(config$out_dir, "joined_airbnb_tenancy.rds"))

# Making sure the variables have the correct types
joined <- joined %>%
  mutate(
    quarter = as.Date(quarter),
    a_month = as.Date(a_month),
    sa2_code = as.character(sa2_code),
    a_id = as.character(a_id)
  )


# Counting unique Airbnb listings per quarter + SA2
airbnb_counts <- joined %>%
  distinct(quarter, sa2_code, a_id) %>%
  group_by(quarter, sa2_code) %>%
  summarise(
    airbnb_listings = n(),
    .groups = "drop"
  )

# Getting one active-bond value per quarter & SA2
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

# Joining Airbnb and Tenancy counts
rental_comparison <- airbnb_counts %>%
  left_join(
    tenancy_counts,
    by = c("quarter", "sa2_code")
  )

# Calculating Airbnb listing as percent of active bonds
rental_comparison <- rental_comparison %>%
  mutate(
    airbnb_percent_of_active_bonds =
      (airbnb_listings / active_bonds) * 100
  )

# Selecting the top 15 SA2s in each quarter
top_areas <- rental_comparison %>%
  filter(!is.na(airbnb_percent_of_active_bonds)) %>%
  group_by(quarter) %>%
  slice_max(
    order_by = airbnb_percent_of_active_bonds,
    n = 15,
    with_ties = FALSE
  ) %>%
  ungroup()

# Making the graph with ggplot
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

# Saving as png
ggsave(file.path(config$out_dir, "d5_airbnb_rentals_location_comparison.png"))