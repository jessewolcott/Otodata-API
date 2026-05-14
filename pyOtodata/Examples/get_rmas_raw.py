"""get_rmas (raw) — lists RMAs for the company. No module required.

Paginated at 100 per page.
RmaItemStatus: 0=PendingAnalysis  1=BeingAnalyzed  2=Complete
               3=PendingReceipt  4=NotReceived  5=Ignored
"""

import requests

BASE_URL = 'https://telematics.otodatanetwork.com:4431'
API_PATH = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}

r = requests.get(f'{BASE_URL}{API_PATH}/rmas', headers=headers, params={'isOpen': 'true'})
r.raise_for_status()
open_rmas = r.json()

print(f"Open RMAs: {len(open_rmas)}")
for rma in open_rmas[:20]:
    print(f"  {rma.get('RmaNumber','?'):12s}  Complete={rma.get('IsComplete')}  "
          f"Created={rma.get('CreatedDate','?')}")

# Completed / page 2
# r = requests.get(f'{BASE_URL}{API_PATH}/rmas', headers=headers, params={'isOpen': 'false', 'page': 1})
