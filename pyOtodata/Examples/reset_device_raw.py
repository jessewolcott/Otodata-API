"""reset_device (raw) — clears ALL customer data for a device. No module required.

WARNING: Destructive. Supply an exclude list to preserve specific fields.
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

confirm = input(f"Reset ALL customer data for device {DEVICE_ID}? Type YES to confirm: ")
if confirm == 'YES':
    r = requests.post(
        f'{BASE_URL}{API_PATH}/devices/{DEVICE_ID}/reset',
        headers=headers,
        json={'Exclude': ['Name', 'TankSerialNumber']},
    )
    r.raise_for_status()
    print('Device reset complete.')
else:
    print('Cancelled.')
