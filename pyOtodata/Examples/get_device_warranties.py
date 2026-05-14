"""get_device_warranties — warranty history for a device, newest to oldest.

WarrantyStatus: 2=NotStarted  3=Expired  4=Active  6=Voided  7=Archived
WarrantyType  : 0=Standard    1=Extended  2=BatteryPackOnly
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
DEVICE_ID = 20008447
client    = OtoDataClient(api_key=API_KEY)

warranties = client.get_device_warranties(DEVICE_ID)
print(f"Warranties for device {DEVICE_ID}: {len(warranties)}")
for w in warranties:
    print(f"  {w.get('WarrantyType','—'):20s}  {w.get('WarrantyStatus','—'):12s}  "
          f"{w.get('WarrantyStartDate','?')} -> {w.get('WarrantyEndDate','?')}")
