# LAND

DATA 201/422 Project Repository

Darcy Donaghy\
Nico Perry\
Lucious Pinto\
Alyssa Thompson

## AirBnB Dataset

### Source

AirBnB listings scraped and made available by InsideAirBnB. Data from New Zealand in the 9 months before 19 June 2026.\
License Type: Creative Commons Attribution 4.0 International License (CC BY).\
Under Public Domain and to the extent possible under law, InsideAirBnB creator Murray Cox has waived all copyright and related or neighboring rights to Inside Airbnb Data. This work is published from: United States.

### Columns

| Name | Meaning |
|------------------------------------|------------------------------------|
| `id` | Airbnb's unique identifier for the listing |
| `name` | Name of the listing |
| `host_id` | Airbnb's unique identifier for the host/user |
| `host_name` | Name of the host. Usually just the first name(s). |
| `neighbourhood_group` | The neighbourhood group as geocoded using the latitude and longitude against neighborhoods as defined by open or public digital shapefiles. Territorial Authority in NZ. |
| `neighbourhood` | No description. Assumed to be suburb. |
| `latitude` | Uses the World Geodetic System (WGS84) projection for latitude and longitude. |
| `longitude` | Uses the World Geodetic System (WGS84) projection for latitude and longitude. |
| `room_type` | [ Entire home/apt \| Private room \| Shared room \| Hotel ] |
| `price` | Daily price in local currency (NZD) |
| `minimum_nights` | Minimum number of night stay for the listing (calendar rules may be different) |
| `number_of_reviews` | The number of reviews the listing has |
| `last_review` | The date of the last/newest review |
| `reviews_per_month` | The average number of reviews per month the listing has over the lifetime of the listing |
| `calculated_host_listings_count` | The number of listings the host has in the current scrape, in the city/region geography |
| `availability_365` | The availability of the listing 365 days in the future as determined by the calendar. Note a listing may not be available because it has been booked by a guest or blocked by the host. |
| `number_of_reviews_ltm` | The number of reviews the listing has (in the last 12 months) |
| `license` | The licence/permit/registration number |

### Cleaning

**Columns removed before d4:**\
Any columns unrelated to the connection between airbnb data and tenancy data for price and available property information were removed.

- `host_id` and `host_name` (both provide unnecessary information about the host that will not be needed when combining airbnb data with tenancy data).
- `neighbourhood_group` and `neighbourhood` (the area data at this level was not needed as we kept `latitude` and `longitude` columns).
- `number_of_reviews`, `last_review`, `reviews_per_month`, and `number_of_reviews_ltm` (nothing to compare this data to in the tenancy dataset.).
- `calculated_host_listings_count` (nothing to compare this to in the tenancy dataset).
- `license` (this data consisted only of Na values so didn't show anything).\

## Tenancy Services Report

### Source

This data has been made available by the The Ministry of Business, Innovation and Employment. Data from New Zealand January 2020- April 2026.\
License Type: Creative Commons 3.0 New Zealand License.

### Columns

| Name | Meaning |
|------------------------------------|------------------------------------|
| `TimeFrame` | Date of data collection |
| `Location Id` | SA2 ID from StatsNZ |
| `Dwelling Type` | Type of dwelling |
| `Number of Beds` | Number of beds in the dwelling |
| `Total Bonds` | Total number of bonds at that location Id for that quarter |
| `Active Bonds` | Number of active bonds |
| `Median Rent` | Average rent price |
| `Geometric Mean Rent` | The n-th root of the average multiplied together |
| `Upper Quartile Rent` | Top 75th percentile of the dataset |
| `Lower Quartile Rent` | Lower 25th percentile of the dataset |
| `Log Std Dev Weekly Rent` | Log of the standard deviation of weekly rent |
