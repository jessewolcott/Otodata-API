"""get_return_request — retrieves a single return request with all its line items.

ItemStatus: 0=Pending  1=Accepted  2=Refused
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

# Discover a real return request number from the environment
all_rrs = client.get_return_requests(is_open=True) or client.get_return_requests(is_open=False)
if not all_rrs:
    print("No return requests found in this environment — replace 'RR00001' with a real return request number.")
    sys.exit(0)
REQUEST_ID = all_rrs[0]['ReturnRequestNumber']

rr = client.get_return_request(REQUEST_ID)
for field in ('ReturnRequestNumber', 'RmaNumber', 'Status', 'Comment',
              'RequesterName', 'RequesterEmail', 'CreatedDate',
              'StreetAddress', 'City', 'Region', 'PostalCode', 'Country'):
    print(f"  {field}: {rr.get(field,'—')}")

items = rr.get('ReturnRequestItems', [])
print(f"\nLine items: {len(items)}")
for item in items:
    print(f"  SerialNumber={item.get('SerialNumber')}  Status={item.get('Status')}  "
          f"SensorStatus={item.get('SensorStatus','—')}  WarrantyStatus={item.get('WarrantyStatus')}")
