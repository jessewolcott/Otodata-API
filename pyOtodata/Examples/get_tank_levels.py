"""get_tank_levels — historical level readings for ALL devices in the company.

Paginated at 10,000 readings per page; increment page= to walk through pages.
ValueType: 0=Percentage(/100)  1=Distance(mm)  2=Quantity  3=Temp(deciKelvin)
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

levels = client.get_tank_levels(
    start_date_utc='2026-04-01T00:00:00Z',
    end_date_utc='2026-04-30T23:59:59Z',
)
logs = levels.get('Logs', [])
print(f"Total readings: {levels.get('Count', 0)}")
for log in logs[:20]:
    print(f"  [{log.get('Id')}] {log.get('LogDateUtc','?'):26s}  "
          f"Level={log.get('Level',0):.1%}  Temp={log.get('Temperature','?')}°C  "
          f"Battery={log.get('BatteryLevel','?')}V")

# Page 2
# levels = client.get_tank_levels('2026-04-01T00:00:00Z', '2026-04-30T23:59:59Z', page=1)
