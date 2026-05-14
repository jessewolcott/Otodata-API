"""get_return_requests (raw) — lists return requests. No module required.

Paginated at 100 per page.
Status: 0=Pending  1=Analyzing  2=Completed  3=RmaReady
"""

import requests

BASE_URL = 'https://telematics.otodatanetwork.com:4431'
API_PATH = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}

r = requests.get(f'{BASE_URL}{API_PATH}/returnRequests', headers=headers, params={'isOpen': 'true'})
r.raise_for_status()
open_rrs = r.json()

print(f"Open return requests: {len(open_rrs)}")
for rr in open_rrs[:20]:
    print(f"  {rr.get('ReturnRequestNumber','?'):12s}  Status={rr.get('Status')}  "
          f"Devices={rr.get('DeviceCount')}  Requester={rr.get('RequesterName','—')}")

# Completed / page 2
# r = requests.get(f'{BASE_URL}{API_PATH}/returnRequests', headers=headers, params={'isOpen': 'false', 'page': 1})
