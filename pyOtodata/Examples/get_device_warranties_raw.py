"""get_device_warranties (raw) — warranty history for a device. No module required.

WarrantyStatus: 2=NotStarted  3=Expired  4=Active  6=Voided  7=Archived
WarrantyType  : 0=Standard    1=Extended  2=BatteryPackOnly
"""

import requests

BASE_URL  = 'https://telematics.otodatanetwork.com:4431'
API_PATH  = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
DEVICE_ID = 123456

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}

r = requests.get(f'{BASE_URL}{API_PATH}/devices/{DEVICE_ID}/warranties', headers=headers)
r.raise_for_status()
warranties = r.json()

print(f"Warranties for device {DEVICE_ID}: {len(warranties)}")
for w in warranties:
    print(f"  {w.get('WarrantyType','—'):20s}  {w.get('WarrantyStatus','—'):12s}  "
          f"{w.get('WarrantyStartDate','?')} → {w.get('WarrantyEndDate','?')}")
