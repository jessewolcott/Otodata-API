"""get_rma — retrieves a single RMA with all its line items."""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

# Discover a real RMA number from the environment
all_rmas = client.get_rmas(is_open=True) or client.get_rmas(is_open=False)
if not all_rmas:
    print("No RMAs found in this environment — replace 'RMA001' with a real RMA number.")
    sys.exit(0)
RMA_ID = all_rmas[0]['RmaNumber']

rma = client.get_rma(RMA_ID)
print(f"RmaNumber : {rma.get('RmaNumber')}")
print(f"IsComplete: {rma.get('IsComplete')}")
print(f"Created   : {rma.get('CreatedDate','?')}")

items = rma.get('RmaItems', [])
print(f"\nRMA items: {len(items)}")
for item in items:
    print(f"  SerialNumber={item.get('SerialNumber')}  Status={item.get('Status')}  "
          f"IsReconciled={item.get('IsReconciled')}  WarrantyStatus={item.get('WarrantyStatus')}  "
          f"Conclusion={item.get('Conclusion','—')}")
