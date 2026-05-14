"""get_devices (raw) — returns all modules using direct requests calls. No module required."""

import requests

BASE_URL = 'https://telematics.otodatanetwork.com:4431'
API_PATH = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}

r = requests.get(f'{BASE_URL}{API_PATH}/devices', headers=headers)
r.raise_for_status()
devices = r.json()

print(f"Total devices: {len(devices)}")
for d in devices[:20]:
    print(f"  [{d['Id']}] {d.get('Name','—'):30s}  {d.get('Status','—'):20s}  {d.get('LastLevel',0):.1%}")

# Filter by last-modified date
# r = requests.get(f'{BASE_URL}{API_PATH}/devices', headers=headers, params={'lastDateUtc': '2026-01-01T00:00:00Z'})
