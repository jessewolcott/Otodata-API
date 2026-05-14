"""update_rma_item — marks an RMA item as reconciled and/or adds a customer comment."""

import sys, os
from datetime import datetime, timezone
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

# Discover a real RMA and device from the environment
all_rmas = client.get_rmas(is_open=True) or client.get_rmas(is_open=False)
if not all_rmas:
    print("No RMAs found in this environment — replace 'RMA001' and device ID with real values.")
    sys.exit(0)
RMA_ID    = all_rmas[0]['RmaNumber']
rma       = client.get_rma(RMA_ID)
DEVICE_ID = rma['RmaItems'][0]['SerialNumber']

result = client.update_rma_item(
    rma_id=RMA_ID,
    device_id=DEVICE_ID,
    is_reconciled=True,
    customer_comment=f"Confirmed received {datetime.now(timezone.utc).strftime('%Y-%m-%d')} via pyOtodata",
)
errors = result.get('Errors', []) if result else []
if not errors:
    print('RMA item updated.')
else:
    for err in errors:
        print(f"  Field '{err.get('Property')}': {err.get('Message')}")

# Comment only — leave reconciliation unchanged
# client.update_rma_item(RMA_ID, DEVICE_ID, customer_comment='Needs further inspection')
