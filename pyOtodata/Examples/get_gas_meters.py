"""get_gas_meters — historical readings for all gas meter modules in the company.

Paginated at 10,000 meters per page. Units: cubic feet or cubic meters.
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

gas    = client.get_gas_meters(
    start_date_utc='2026-04-01T00:00:00Z',
    end_date_utc='2026-04-30T23:59:59Z',
)
meters = gas.get('Meters', [])
print(f"Total gas meter records: {gas.get('Count', 0)}")
for m in meters[:20]:
    print(f"  SerialNumber={m.get('SerialNumber')}  "
          f"Account={m.get('AccountNumber','—')}  Tank={m.get('TankNumber','—')}  "
          f"Volume={m.get('Volume')} {m.get('Units','')}  "
          f"Init={m.get('IndexInitialValue')} → Final={m.get('IndexFinalValue')}")

# Page 2
# gas = client.get_gas_meters('2026-04-01T00:00:00Z', '2026-04-30T23:59:59Z', page=1)
