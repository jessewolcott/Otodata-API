"""get_return_requests — lists return requests for the company.

Paginated at 100 per page.
Status: 0=Pending  1=Analyzing  2=Completed  3=RmaReady
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

# Open requests
open_rrs = client.get_return_requests(is_open=True)
print(f"Open return requests: {len(open_rrs)}")
for rr in open_rrs[:20]:
    print(f"  {rr.get('ReturnRequestNumber','?'):12s}  Status={rr.get('Status')}  "
          f"Devices={rr.get('DeviceCount')}  Requester={rr.get('RequesterName','—')}")

# Completed requests
# closed = client.get_return_requests(is_open=False)

# Page 2
# page2 = client.get_return_requests(is_open=True, page=1)
