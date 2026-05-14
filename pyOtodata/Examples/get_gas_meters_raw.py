"""get_gas_meters (raw) — historical readings for all gas meter modules. No module required.

Paginated at 10,000 meters per page.
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

r = requests.get(f'{BASE_URL}{API_PATH}/meters', headers=headers, params=params)
r.raise_for_status()
gas    = r.json()
meters = gas.get('Meters', [])

print(f"Total gas meter records: {gas.get('Count', 0)}")
for m in meters[:20]:
    print(f"  SerialNumber={m.get('SerialNumber')}  "
          f"Account={m.get('AccountNumber','—')}  Tank={m.get('TankNumber','—')}  "
          f"Volume={m.get('Volume')} {m.get('Units','')}  "
          f"Init={m.get('IndexInitialValue')} → Final={m.get('IndexFinalValue')}")

# Page 2
# r = requests.get(f'{BASE_URL}{API_PATH}/meters', headers=headers, params={**params, 'page': 1})
