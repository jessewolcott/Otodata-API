"""get_rma (raw) — single RMA with all line items. No module required."""

import requests

BASE_URL = 'https://telematics.otodatanetwork.com:4431'
API_PATH = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
RMA_ID   = 'RMA001'   # Replace with a real RMA number

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}

r = requests.get(f'{BASE_URL}{API_PATH}/rmas/{RMA_ID}', headers=headers)
r.raise_for_status()
rma = r.json()

print(f"RmaNumber : {rma.get('RmaNumber')}")
print(f"IsComplete: {rma.get('IsComplete')}")
print(f"Created   : {rma.get('CreatedDate','?')}")

items = rma.get('RmaItems', [])
print(f"\nRMA items: {len(items)}")
for item in items:
    print(f"  SerialNumber={item.get('SerialNumber')}  Status={item.get('Status')}  "
          f"IsReconciled={item.get('IsReconciled')}  Conclusion={item.get('Conclusion','—')}")
