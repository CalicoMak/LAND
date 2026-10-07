
# Calculating median Airbnb price 

library(dplyr)
library(readr)
library(yaml)

config <- read_yaml("config.yaml")

# Reading in the Airbnb file
listings <- read_rds(file.path(config$out.dir, "listings_chch_codes.rds"))
# Reading in Joined data 
joined_data <- read_rds(file.path(config$out.dir, "joined_airbnb_tenancy.rds"))
# Filtering only by Chch central (code 326600)
chch_central <- listings %>% filter(sa2_code == 326600)
# Calculating median using median function
median(chch_central$price, na.rm = TRUE)
# = 239


# Calculating 'craziest' gap between short and long term rental prices.
# We defined short term as airbnb and long term as tenancy because majority of airbnb data (>94%) is <28 days. 

# Reading in the 'geographic-areas-table-2023' 
geo <- read_rds(file.path(config$out.dir, "geographic-areas-table-2023.rds")) %>%
  select(SA22023_code, SA22023_name, SA32023_code, SA32023_name) %>%
  distinct(SA22023_code, .keep_all = TRUE) %>%
  mutate(SA22023_code = as.character(SA22023_code),
         SA32023_code = as.character(SA32023_code))

# Merging the sa2/sa3 with our joined airbnb and tenancy data
merged <- joined_data %>%
  mutate(sa2_code = as.character(sa2_code),
         t_nightly_equiv = t_rent_median / 7,
         gap = a_nightlyprice - t_nightly_equiv) %>%
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