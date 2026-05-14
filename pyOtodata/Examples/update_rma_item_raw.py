"""update_rma_item (raw) — marks an RMA item reconciled and/or adds a comment. No module required."""

import requests
from datetime import datetime, timezone

BASE_URL  = 'https://telematics.otodatanetwork.com:4431'
API_PATH  = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
RMA_ID    = 'RMA001'   # Replace with a real RMA number
DEVICE_ID = 123456     # Replace with the device serial number on that RMA

headers = {
    'Authorization': f'Bearer {API_KEY}',
    'Accept': 'application/json; charset=utf-8',
    'Content-Type': 'application/json',
}

r = requests.post(
    f'{BASE_URL}{API_PATH}/rmaItems/{RMA_ID}/devices/{DEVICE_ID}',
    headers=headers,
    json={
        'IsReconciled':    True,
        'CustomerComment': f"Confirmed received {datetime.now(timezone.utc).strftime('%Y-%m-%d')} via direct requests",
    },
)
r.raise_for_status()
result = r.json()
errors = result.get('Errors', []) if result else []
if not errors:
    print('RMA item updated.')
else:
    for err in errors:
        print(f"  Field '{err.get('Property')}': {err.get('Message')}")
