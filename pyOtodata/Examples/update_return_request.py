"""update_return_request — updates the comment on a return request."""

import sys, os
from datetime import datetime, timezone
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

result = client.update_return_request(
    REQUEST_ID,
    comment=f"Reviewed {datetime.now(timezone.utc).strftime('%Y-%m-%d')} via pyOtodata",
)
errors = result.get('Errors', []) if result else []
if not errors:
    print(f"Return request {REQUEST_ID} updated.")
else:
    for err in errors:
        print(f"  Field '{err.get('Property')}': {err.get('Message')}")
