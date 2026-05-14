"""get_device (raw) — returns a single module by serial number. No module required."""

import json, requests

BASE_URL  = 'https://telematics.otodatanetwork.com:4431'
API_PATH  = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
DEVICE_ID = 123456

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}

r = requests.get(f'{BASE_URL}{API_PATH}/devices/{DEVICE_ID}', headers=headers)
r.raise_for_status()
print(json.dumps(r.json(), indent=2, default=str))

# With a specific sensor index
# r = requests.get(f'{BASE_URL}{API_PATH}/devices/{DEVICE_ID}', headers=headers, params={'sensor': 1})
