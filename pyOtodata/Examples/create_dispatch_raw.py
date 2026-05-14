"""create_dispatch (raw) — triggers a dispatch for a device. No module required.

Sends a push notification to end-users and fires integration events.
"""

import requests

BASE_URL  = 'https://telematics.otodatanetwork.com:4431'
API_PATH  = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
DEVICE_ID = 123456

headers = {
    'Authorization': f'Bearer {API_KEY}',
    'Accept': 'application/json; charset=utf-8',
    'Content-Type': 'application/json',
}

r = requests.post(f'{BASE_URL}{API_PATH}/devices/{DEVICE_ID}/createdispatch', headers=headers)
r.raise_for_status()
print(f"Dispatch created for device {DEVICE_ID}.")

# Target a specific sensor
# r = requests.post(f'.../{DEVICE_ID}/createdispatch', headers=headers, params={'sensor': 1})
