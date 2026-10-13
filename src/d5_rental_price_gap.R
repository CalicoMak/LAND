suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(yaml)
})

config <- read_yaml("config.yaml", readLines.warn = FALSE)

joined <- read_rds(file.path(config$out_dir, "joined_airbnb_tenancy.rds"))

# Median nightly Airbnb price, Christchurch Central (SA2 326600)
chch_central <- joined %>% filter(sa2_code == 326600)

median_price <- tibble::tibble(
  area = "Christchurch Central",
  sa2_code = 326600,
  median_nightly_price = median(chch_central$a_nightlyprice, na.rm = TRUE),
  n_listings = sum(!is.na(chch_central$a_nightlyprice))
)

median_price
saveRDS(median_price, file.path(config$out_dir, "median_price_chch_central.rds"))


# Calculating 'craziest' gap between short and long term rental prices.
# We defined short term as airbnb and long term as tenancy because majority of airbnb data (>94%) is <28 days. 

# Reading back in the 'geographic-areas-table-2023' (meshblock-level)
geo_raw <- read_csv(file.path(config$data_dir, "geographic-areas-table-2023.csv"))

# Lookup 1: 2023 SA2 -> SA3 (as before) ---
geo23 <- geo_raw %>%
  select(SA22023_code, SA22023_name, SA32023_code, SA32023_name) %>%
  distinct(SA22023_code, .keep_all = TRUE) %>%
  transmute(sa2_code = as.character(SA22023_code),
            SA22023_name,
            SA32023_code = as.character(SA32023_code),
            SA32023_name,
            sa3_uncertain = FALSE)

# Lookup 2: 2018 SA2 codes that no longer exist in 2023
# Some of our data uses 2018 SA2 codes. Assigning each to the SA3 containing most of its meshblocks, and flagging those where the old SA2 are on more than one SA3.

geo18 <- geo_raw %>%
  filter(!is.na(SA22018_code),
         !(SA22018_code %in% SA22023_code)) %>%
  count(SA22018_code, SA22018_name, SA32023_code, SA32023_name, name = "n_mb") %>%
  group_by(SA22018_code) %>%
  mutate(sa3_uncertain = n_distinct(SA32023_code) > 1) %>%
  slice_max(n_mb, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  transmute(sa2_code = as.character(SA22018_code),
            SA22023_name = paste0(SA22018_name, " (2018 area)"),
            SA32023_code = as.character(SA32023_code),
            SA32023_name,
            sa3_uncertain)

# Combined lookup (2023 codes take priority)
geo <- bind_rows(geo23, geo18) %>%
  distinct(sa2_code, .keep_all = TRUE)

# Merging the sa2/sa3 with our joined airbnb and tenancy data
merged <- joined %>%
  mutate(sa2_code = as.character(sa2_code),
         t_rent_median = parse_number(as.character(t_rent_median)),
         t_nightly_equiv = t_rent_median / 7,
         gap = a_nightlyprice - t_nightly_equiv) %>%
  filter(!is.na(gap)) %>%
  left_join(geo, by = "sa2_code")

# Checking that there are no more na's
sum(is.na(merged$SA22023_name))
sum(is.na(merged$SA32023_name))

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
saveRDS(gap_sa2, file.path(config$out_dir, "gap_sa2.rds"))
gap_sa3
saveRDS(gap_sa3, file.path(config$out_dir, "gap_sa3.rds"))

# Finding the largest gap over both sa2 and sa3
gap_sa2 %>% slice_max(median_gap, n = 1)