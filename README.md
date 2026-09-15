# LAND

DATA 201/422 Project Repository

Darcy Donaghy\
Nico Perry\
Lucious Pinto\
Alyssa Thompson

## AirBnB Dataset

### Source

AirBnB listings scraped and made available by InsideAirBnB. Data from New Zealand in the 9 months before 19 June 2026. Under Public Domain and to the extent possible under law, InsideAirBnB creator Murray Cox has waived all copyright and related or neighboring rights to Inside Airbnb Data. This work is published from: United States.\
Licence: Creative Commons Attribution 4.0 International License (CC BY)

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
Any columns unrelated to the connection between AirBnB data and tenancy data for price and available property information were removed.

- `host_id` and `host_name` (both provide unnecessary information about the host that will not be needed when combining AirBnB data with tenancy data).
- `neighbourhood_group` and `neighbourhood` (the area data at this level was not needed as we kept `latitude` and `longitude` columns).
- `number_of_reviews`, `last_review`, `reviews_per_month`, and `number_of_reviews_ltm` (nothing to compare this data to in the tenancy dataset.).
- `calculated_host_listings_count` (nothing to compare this to in the tenancy dataset).
- `license` (this data consisted only of Na values so didn't show anything).\

## Quarterly Rental Bond Dataset

### Source

This data has been made available by the The Ministry of Business, Innovation and Employment through Tenancy Services. Data from New Zealand each quarter from January 2020 to April 2026.\
Licence: Creative Commons Attribution 3.0 New Zealand License (CC BY)

### Columns

| Name | Meaning |
|------------------------------------|------------------------------------|
| `TimeFrame` | Starting day of the quarter to the bond data were collected |
| `Location Id` | SA2-2019 ID from Stats NZ |
| `Dwelling Type` | ALL \| [ Apartment \| Boarding House \| Flat \| House \| Room ] |
| `Number of Beds` | ALL \| Number of beds in the dwelling |
| `Total Bonds` | Total number of bonds |
| `Active Bonds` | Number of active bonds |
| `Closed Bonds` | Number of bonds closed that quarter |
| `Median Rent` | Median weekly rent in NZD |
| `Geometric Mean Rent` | The n-th root of the average multiplied together |
| `Upper Quartile Rent` | Synthetic 75th percentile assuming lognormal distribution of weekly rent in NZD |
| `Lower Quartile Rent` | Synthetic 25th percentile assuming lognormal distribution of weekly rent in NZD |
| `Log Std Dev Weekly Rent` | Log of the standard deviation of weekly rent |

### Cleaning

#### Rows Retained

- `TimeFrame` between `2025-10-01` and `2026-04-01`, i.e. the three quarters that align with the AirBnB data.
- `Location Id` in Christchurch City (according to SA2-2019 Higher Geographies), matching the same operation on the AirBnB data, which uses the exact same Christchurch City boundary. Removes all other SA2's, as well as `NULL` and `-99`, which cannot be qualified.
- `Dwelling Type` that is not `ALL`; no aggregation along `Dwelling Type` as this column will be retained.
- `Number of Beds` that is `ALL`; only aggregation along `Number of Beds` as this column will be removed. Also removes `NA` entries, which are unquantified values that overlap with `ALL`.

Note: As `ALL` indicates aggregation, keeping both actual values and `ALL` would result in double-counting bonds.

#### Columns Dropped

- `Number of Beds`: AirBnB dataset has no equivalent so no comparison can be made.

## Statistical Area 2 2019 Higher Geographies

### Source

Relates 2019 Statistical Area 2 units to higher geographic units. Downloaded from the Stats NZ Geographic Data Service.\
Licence: Creative Commons Attribution 4.0 International (CC BY)

### Columns

| Name | Description |
|-----------------------|-------------------------------------------------|
| SA22019_V1_00 | SA2-19 ID number |
| TA2019_V1_00_NAME | Name of the Territorial Authority inside which the given SA2-19 lies |
