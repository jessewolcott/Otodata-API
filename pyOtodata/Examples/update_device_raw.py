"""update_device (raw) — modifies a device's properties. No module required.

Only include keys you want to change.
"""

import requests
from datetime import datetime, timezone

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
payload = {
    'Name':           'North Tank',
    'Route':          'Route A',
    'Note':           f"Updated {datetime.now(timezone.utc).strftime('%Y-%m-%d')} via direct requests",
    'LocationName':   'Site A',
    'LocationNumber': 'LOC001',
}

r = requests.post(f'{BASE_URL}{API_PATH}/devices/{DEVICE_ID}', headers=headers, json=payload)
r.raise_for_status()
result = r.json()
errors = result.get('Errors', []) if result else []
if not errors:
    print('Device updated successfully.')
else:
    for err in errors:
        print(f"  Field '{err.get('Property')}': {err.get('Message')}")

# With enforced validation
# r = requests.post(f'.../{DEVICE_ID}', headers=headers, json=payload, params={'enforceValidation': 'true'})
