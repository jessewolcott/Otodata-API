"""get_rmas — lists RMAs for the company.

Paginated at 100 per page.
RmaItemStatus: 0=PendingAnalysis  1=BeingAnalyzed  2=Complete
               3=PendingReceipt  4=NotReceived  5=Ignored
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

# Open RMAs
open_rmas = client.get_rmas(is_open=True)
print(f"Open RMAs: {len(open_rmas)}")
for rma in open_rmas[:20]:
    print(f"  {rma.get('RmaNumber','?'):12s}  Complete={rma.get('IsComplete')}  "
          f"Created={rma.get('CreatedDate','?')}")

# Completed RMAs
# closed = client.get_rmas(is_open=False)

# Page 2
# page2 = client.get_rmas(is_open=True, page=1)
