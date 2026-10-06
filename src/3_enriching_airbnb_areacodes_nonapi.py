from pathlib import Path
import yaml
from pprint import pprint
import geopandas as gpd
import pandas as pd

with open('config.yaml', 'r') as config_file:
    config = yaml.safe_load(config_file)

DATA_DIR = Path(config['data_dir'])
OUT_DIR = Path(config['out_dir'])
    
airbnb_chch = pd.read_parquet(OUT_DIR / 'listings_chch_cleaned.parquet')

sa2_gdf = gpd.read_file(DATA_DIR / 'statistical-area-2-2019-generalised.gpkg')
code_col ='SA22019_V1_00'


# Convert Airbnb DataFrame to GeoDataFrame (assuming EPSG:4326 for Lat/Lon)
airbnb_gdf = gpd.GeoDataFrame(
    airbnb_chch,
    geometry=gpd.points_from_xy(airbnb_chch["longitude"], airbnb_chch["latitude"]),
    crs="EPSG:4326",
)

# Ensure both layers use the same Coordinate Reference System
if sa2_gdf.crs != airbnb_gdf.crs:
    sa2_gdf = sa2_gdf.to_crs(airbnb_gdf.crs)

# Spatial Join (Point-in-Polygon check)
joined_gdf = gpd.sjoin(
    airbnb_gdf, sa2_gdf[[code_col, "geometry"]], how="left", predicate="within"
)

# Map the code back to the original DataFrame and save
airbnb_chch["sa2_code"] = joined_gdf[code_col]

airbnb_chch.to_parquet(OUT_DIR / "airbnb_chch_codes.parquet", index=False)
