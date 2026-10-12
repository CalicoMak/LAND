from pathlib import Path
import yaml
from pprint import pprint
import pandas as pd
import requests
from concurrent.futures import ThreadPoolExecutor
import threading
import time
import sys


with open('config.yaml', 'r') as config_file:
    config = yaml.safe_load(config_file)
    
OUT_DIR = Path(config['out_dir'])
API_KEY = config['api_key']
    
airbnb_chch = pd.read_parquet(OUT_DIR / 'listings_chch_cleaned.parquet')

LAYER_ID = 98970
CODE_COL = 'SA22019_V1_00'

BASE_URL = 'https://koordinates.com/services/query/v1/vector.json'


_thread_local = threading.local()


def _get_session():
    if not hasattr(_thread_local, 'session'):
        _thread_local.session = requests.Session()
    return _thread_local.session


def find_area_code(lon_lat):
    lon, lat = lon_lat
    params = {
        'key': config['api_key'],
        'layer': LAYER_ID,
        'x': lon,
        'y': lat,
        'max_results': 1,
        'radius': 1,  # small radius — for a polygon layer, a point inside returns distance 0
    }
    resp = _get_session().get(BASE_URL, params=params, timeout=10)
    if resp.status_code == 429:
      print(resp.headers)
    resp.raise_for_status()
    data = resp.json()
    features = data['vectorQuery']['layers'][str(LAYER_ID)]['features']
    if not features:
        return None
    area_code = features[0]['properties'][CODE_COL]
    return area_code


# 1. Extract unique coordinate pairs to avoid redundant API requests
unique_pairs_df = airbnb_chch[['longitude', 'latitude']].drop_duplicates().reset_index(drop=True)
pairs = list(zip(unique_pairs_df.longitude, unique_pairs_df.latitude))

# 2. Setup thread-safe counter and progress tracking
completed = 0
total = len(pairs)
progress_lock = threading.Lock()

def find_area_code_with_progress(lon_lat):
    global completed
    code = find_area_code(lon_lat)
    with progress_lock:
        completed += 1
        percent = (completed / total) * 100
        sys.stdout.write(f"\rProgress: {percent:.1f}% ({completed}/{total})")
        sys.stdout.flush()
    return code

print(f"Querying API for {total} unique locations (out of {len(airbnb_chch)} total rows)...")
with ThreadPoolExecutor(max_workers=config['api_max_workers']) as executor:
    results = list(executor.map(find_area_code_with_progress, pairs))

print() # Move to a new line once progress completes

unique_pairs_df['sa2_code'] = results

# 3. Join the results back to the main dataframe based on coordinates
airbnb_chch = airbnb_chch.merge(unique_pairs_df, on=['longitude', 'latitude'], how='left')

# Using nullable integer type 'Int64' in case any lookups returned None (prevents errors)
airbnb_chch['sa2_code'] = airbnb_chch['sa2_code'].astype('Int64')

airbnb_chch.to_parquet(OUT_DIR / 'airbnb_chch_codes.parquet', index=False)
