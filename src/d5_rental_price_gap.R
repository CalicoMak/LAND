
# Calculating median Airbnb price 

library(dplyr)
library(readr)

# Reading in the Airbnb file
listings <- read_csv(file.path(data.dir, "listings_chch_codes.csv"))
# Filtering only by Chch central (code 326600)
chch_central <- listings %>% filter(sa2_code == 326600)
# Calculating median using median function
median(chch_central$price, na.rm = TRUE)
# = 239


# Calculating 'craziest' gap between short and long term rental prices.

# joined_data comes from the SQL script
geo <- read_csv(file.path(data.dir, "geographic-areas-table-2023.csv")) %>%
  select(SA22023_code, SA22023_name, SA32023_code, SA32023_name) %>%
  distinct(SA22023_code, .keep_all = TRUE) %>%
  mutate(SA22023_code = as.character(SA22023_code),
         SA32023_code = as.character(SA32023_code))

#
merged <- joined_data %>%
  mutate(bond_nightly_equiv = bond_median_weekly_rent / 7,
         gap = airbnb_price_per_night - bond_nightly_equiv) %>%
  filter(!is.na(gap)) %>% # Making sure there's no na data
  left_join(geo, by = c("sa2_code" = "SA22023_code"))

# SA2-level (suburb) gap, named, n >= 20 to avoid noise (SA2 to get a neighbourhood level of aggregation)
gap_sa2 <- merged %>%
  group_by(sa2_code, SA22023_name) %>%
  summarise(median_gap = median(gap), n = n(), iqr = IQR(gap), .groups = "drop") %>%
  filter(n >= 20) %>%
  arrange(desc(median_gap))

# SA3-level (pooled) gap, named (SA3 to give a bigger pool of aggregation)
gap_sa3 <- merged %>%
  group_by(SA32023_code, SA32023_name) %>%
  summarise(median_gap = median(gap), n = n(), iqr = IQR(gap), .groups = "drop") %>%
  arrange(desc(median_gap))

gap_sa2
gap_sa3

# Finding the largest gap over both sa2 and sa3
gap_sa2 %>% slice_max(median_gap, n = 1)
# Holmwood by ~210