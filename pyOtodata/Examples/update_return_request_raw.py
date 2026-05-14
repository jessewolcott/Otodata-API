"""update_return_request (raw) — updates the comment on a return request. No module required."""

import requests
from datetime import datetime, timezone

BASE_URL   = 'https://telematics.otodatanetwork.com:4431'
API_PATH   = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
REQUEST_ID = 'RR00001'   # Replace with a real return request number

headers = {
    'Authorization': f'Bearer {API_KEY}',
    'Accept': 'application/json; charset=utf-8',
    'Content-Type': 'application/json',
}

r = requests.post(
    f'{BASE_URL}{API_PATH}/returnRequests/{REQUEST_ID}',
    headers=headers,
    json={'Comment': f"Reviewed {datetime.now(timezone.utc).strftime('%Y-%m-%d')} via direct requests"},
)
r.raise_for_status()
result = r.json()
errors = result.get('Errors', []) if result else []
if not errors:
    print(f"Return request {REQUEST_ID} updated.")
else:
    for err in errors:
        print(f"  Field '{err.get('Property')}': {err.get('Message')}")
