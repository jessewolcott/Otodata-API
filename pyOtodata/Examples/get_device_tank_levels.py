"""get_device_tank_levels — historical level readings for a single device.

Paginated at 10,000 readings per page; increment page= to walk through pages.
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
DEVICE_ID = 20008447
client    = OtoDataClient(api_key=API_KEY)

levels = client.get_device_tank_levels(
    device_id=DEVICE_ID,
    start_date_utc='2026-04-01T00:00:00Z',
    end_date_utc='2026-04-30T23:59:59Z',
)
logs = levels.get('Logs', [])
print(f"Readings for device {DEVICE_ID}: {levels.get('Count', 0)}")
for log in logs[:20]:
    print(f"  {log.get('LogDateUtc','?'):26s}  Level={log.get('Level',0):.1%}  "
          f"Temp={log.get('Temperature','?')}°C  Battery={log.get('BatteryLevel','?')}V")

# With sensor index / page
# levels = client.get_device_tank_levels(DEVICE_ID, '2026-04-01T00:00:00Z', '2026-04-30T23:59:59Z', sensor=1)
