"""get_tank_levels (raw) — historical level readings for all devices. No module required.

Paginated at 10,000 readings per page.
"""

import requests

BASE_URL = 'https://telematics.otodatanetwork.com:4431'
API_PATH = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}
params  = {'startDateUtc': '2026-04-01T00:00:00Z', 'endDateUtc': '2026-04-30T23:59:59Z'}

r = requests.get(f'{BASE_URL}{API_PATH}/tanklevels', headers=headers, params=params)
r.raise_for_status()
levels = r.json()
logs   = levels.get('Logs', [])

print(f"Total readings: {levels.get('Count', 0)}")
for log in logs[:20]:
    print(f"  [{log.get('Id')}] {log.get('LogDateUtc','?'):26s}  "
          f"Level={log.get('Level',0):.1%}  Temp={log.get('Temperature','?')}°C")

# Page 2
# r = requests.get(f'{BASE_URL}{API_PATH}/tanklevels', headers=headers, params={**params, 'page': 1})
