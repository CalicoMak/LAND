import pandas
import requests
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import threading
from pprint import pprint
import yaml

with open("config.yaml", "r") as config_file:
    config = yaml.safe_load(config_file)
    
OUT_DIR = Path(config['out_dir'])
    
airbnb_chch = pd.read_parquet(OUT_DIR / 'listings_chch_cleaned.parquet')

LAYER_ID = 98970
BASE_URL = 'https://koordinates.com/services/query/v1/vector.json'
CODE_COL = 'SA22019_V1_00'

_thread_local = threading.local()


def _get_session():
    if not hasattr(_thread_local, "session"):
        _thread_local.session = requests.Session()
    return _thread_local.session


def find_area_code(lon_lat):
    lon, lat = lon_lat
    params = {
        "key": API_KEY,
        "layer": LAYER_ID,
        "x": lon,
        "y": lat,
        "max_results": 1,
        "radius": 1,  # small radius — for a polygon layer, a point inside returns distance 0
    }
    resp = _get_session().get(BASE_URL, params=params, timeout=10)
    resp.raise_for_status()
    data = resp.json()
    features = data["vectorQuery"]["layers"][str(LAYER_ID)]["features"]
    if not features:
        return None
    area_code = features[0]["properties"][CODE_COL]
    return area_code


pairs = list(zip(airbnb_chch.longitude, airbnb_chch.latitude))
with ThreadPoolExecutor(max_workers=config['api_max_workers']) as executor:
    results = list(executor.map(find_area_code, pairs))


airbnb_chch['sa2_code'] = results
airbnb_chch['sa2_code'] = airbnb_chch['sa2_code'].astype(int)


airbnb_chch.to_parquet(OUT_DIR / 'airbnb_chch_codes.parquet', index=False)
