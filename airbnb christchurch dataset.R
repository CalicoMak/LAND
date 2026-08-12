# Installing necessary libraries
library(readr)
library(dplyr)

# Setup date metadata
dates <- c("2025-10", "2025-11", "2025-12", "2026-01", "2026-02", "2026-03", "2026-04", "2026-05", "2026-06")
labels <- c("October 2025", "November 2025", "December 2025", "January 2026", "February 2026", 
            "March 2026", "April 2026", "May 2026", "June 2026")

# Initialise list to store data frames
data_list <- vector("list", length(dates))

# Loop over files
for (i in seq_along(dates)) {
  data_list[[i]] <- read_csv(paste0("../data_d3/listings_", dates[i], ".csv"), show_col_types = FALSE) %>%
    filter(neighbourhood_group == "Christchurch City") %>%
    mutate(month_year = labels[i])
}

# Combine into single data frame
airbnb <- bind_rows(data_list)

summary(airbnb)    #summary including max, min, mean, categories

colSums(is.na(airbnb))    #better for just seeing where the NAs are

airbnb %>%
  summarise(across(where(is.numeric), \(x) sd(x, na.rm = TRUE)))    #standard deviation for numeric variables


table(airbnb$room_type)
table(airbnb$neighbourhood)
table(airbnb$month_year)     #tables to have a better look at categorical variables and see where data came from

write_csv(airbnb, "../data_d3/listings_chch.csv")