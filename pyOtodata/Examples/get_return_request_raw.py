"""get_return_request (raw) — single return request with all line items. No module required."""

import requests

BASE_URL   = 'https://telematics.otodatanetwork.com:4431'
API_PATH   = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
REQUEST_ID = 'RR00001'   # Replace with a real return request number

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}

r = requests.get(f'{BASE_URL}{API_PATH}/returnRequests/{REQUEST_ID}', headers=headers)
r.raise_for_status()
rr = r.json()

for field in ('ReturnRequestNumber', 'RmaNumber', 'Status', 'Comment',
              'RequesterName', 'RequesterEmail', 'CreatedDate',
              'StreetAddress', 'City', 'Region', 'PostalCode', 'Country'):
    print(f"  {field}: {rr.get(field,'—')}")

items = rr.get('ReturnRequestItems', [])
print(f"\nLine items: {len(items)}")
for item in items:
    print(f"  SerialNumber={item.get('SerialNumber')}  Status={item.get('Status')}  "
          f"SensorStatus={item.get('SensorStatus','—')}")
