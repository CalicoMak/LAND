library(readr)
library(dplyr)
library(lubridate)

data.dir <- "../data_d3"

# Setup date metadata
dates <- c("2025-10", "2025-11", "2025-12", "2026-01", "2026-02", "2026-03", "2026-04", "2026-05", "2026-06")

# Initialise list to store data frames
data.list <- vector("list", length(dates))

# Loop over files
for (i in seq_along(dates)) {
  filepath <- file.path(data.dir, paste0("listings_", dates[i], ".csv"))
  
  data.list[[i]] <- read_csv(filepath, show_col_types = FALSE) %>%
    filter(neighbourhood_group == "Christchurch City") %>%
    mutate(timeframe = ym(dates[i]))
}

# Combine into single data frame
airbnb <- bind_rows(data.list)

write_csv(airbnb, file.path(data.dir, "listings_chch.csv"))




## Review the new data

summary(airbnb)    #summary including max, min, mean, categories

colSums(is.na(airbnb))    #better for just seeing where the NAs are

airbnb %>%
  summarise(across(where(is.numeric), \(x) sd(x, na.rm = TRUE)))    #standard deviation for numeric variables


table(airbnb$room_type)
table(airbnb$neighbourhood)
table(airbnb$month_year)     #tables to have a better look at categorical variables and see where data came from

