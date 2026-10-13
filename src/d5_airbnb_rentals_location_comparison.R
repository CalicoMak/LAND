suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(scales)
  library(readr)
  library(yaml)
})

config <- read_yaml("config.yaml", readLines.warn = FALSE)

# Reading in the joined data
joined <- read_rds(
  file.path(config$out_dir, "joined_airbnb_tenancy.rds")
)

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

# Joining Airbnb and tenancy counts
rental_comparison <- airbnb_counts %>%
  left_join(
    tenancy_counts,
    by = c("quarter", "sa2_code")
  )

# Calculating active rental bonds per Airbnb listing
rental_comparison <- rental_comparison %>%
  mutate(
    active_bonds_per_airbnb =
      active_bonds / airbnb_listings
  )

# Selecting the top 15 SA2s in each quarter
top_areas <- rental_comparison %>%
  filter(
    !is.na(active_bonds_per_airbnb),
    is.finite(active_bonds_per_airbnb)
  ) %>%
  group_by(quarter) %>%
  slice_max(
    order_by = active_bonds_per_airbnb,
    n = 15,
    with_ties = FALSE
  ) %>%
  ungroup()

# Keep all SA2 observations with valid counts
plot_data <- rental_comparison %>%
  filter(
    !is.na(active_bonds),
    !is.na(airbnb_listings),
    active_bonds > 0,
    airbnb_listings > 0
  ) %>%
  mutate(
    more_airbnb = airbnb_listings > active_bonds
  )

# Scatter plot comparing Airbnb listings and active bonds
location_comparison <- ggplot(
  plot_data,
  aes(
    x = active_bonds,
    y = airbnb_listings
  )
) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed",
    colour = "grey40"
  ) +
  geom_point(
    aes(colour = more_airbnb),
    alpha = 0.8,
    size = 2
  ) +
  facet_wrap(~ quarter) +
  scale_x_log10(
    labels = scales::label_comma()
  ) +
  scale_y_log10(
    labels = scales::label_comma()
  ) +
  scale_colour_manual(
    values = c(
      "FALSE" = "steelblue",
      "TRUE" = "firebrick"
    ),
    labels = c(
      "FALSE" = "More active bonds",
      "TRUE" = "More Airbnb listings"
    ),
    name = "Comparison"
  ) +
  labs(
    title = "Airbnb listings compared with active rental bonds",
    subtitle = "All SA2 areas by quarter; dashed line indicates equal counts",
    x = "Active rental bonds (log scale)",
    y = "Airbnb listings (log scale)"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    legend.position = "bottom"
  )

# Save plot
ggsave(
  file.path(
    config$out_dir,
    "d5_airbnb_rentals_location_comparison.png"
  ),
  plot = location_comparison,
  width = 12,
  height = 8,
  dpi = 300
)
