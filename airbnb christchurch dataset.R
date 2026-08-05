library(readr)
library(dplyr)
library(lubridate)

listings_jun <- read_csv("../data_d3/listings_2026-06.csv")

jun_chch <- listings_jun %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "June 2026")   #add in month + time


listings_may <- read_csv("../data_d3/listings_2026-05.csv")

may_chch <- listings_may %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "May 2026")


listings_apr <- read_csv("../data_d3/listings_2026-04.csv")

apr_chch <- listings_apr %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "April 2026")


listings_mar <- read_csv("../data_d3/listings_2026-03.csv")

mar_chch <- listings_mar %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "March 2026")


listings_feb <- read_csv("../data_d3/listings_2026-02.csv")

feb_chch <- listings_feb %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "February 2026")


listings_jan <- read_csv("../data_d3/listings_2026-01.csv")

jan_chch <- listings_jan %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "January 2026")


listings_dec <- read_csv("../data_d3/listings_2025-12.csv")

dec_chch <- listings_dec %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "December 2025")


listings_nov <- read_csv("../data_d3/listings_2025-11.csv")

nov_chch <- listings_nov %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "November 2025")


listings_oct <- read_csv("../data_d3/listings_2025-10.csv")

oct_chch <- listings_oct %>%
  filter(neighbourhood_group == "Christchurch City") %>%
  mutate(month_year = "October 2025")



airbnb <- bind_rows(
  oct_chch,
  nov_chch,
  dec_chch,
  jan_chch,
  feb_chch,
  mar_chch,
  apr_chch,
  may_chch,
  jun_chch
)   #combine the data sets

summary(airbnb)    #summary including max, min, mean, catagories

colSums(is.na(airbnb))    #better for just seeing where the NAs are

airbnb %>%
  summarise(across(where(is.numeric), \(x) sd(x, na.rm = TRUE)))    #standard deviation for numeric variables


table(airbnb$room_type)
table(airbnb$neighbourhood)
table(airbnb$month_year)     #tables to have a better look at catagorical variables and see where data came from


