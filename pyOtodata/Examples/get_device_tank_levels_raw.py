"""get_device_tank_levels (raw) — historical readings for one device. No module required."""

import requests

BASE_URL  = 'https://telematics.otodatanetwork.com:4431'
API_PATH  = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
DEVICE_ID = 123456

headers = {'Authorization': f'Bearer {API_KEY}', 'Accept': 'application/json; charset=utf-8'}
params  = {'startDateUtc': '2026-04-01T00:00:00Z', 'endDateUtc': '2026-04-30T23:59:59Z'}

r = requests.get(f'{BASE_URL}{API_PATH}/devices/{DEVICE_ID}/tanklevels', headers=headers, params=params)
r.raise_for_status()
levels = r.json()
logs   = levels.get('Logs', [])

print(f"Readings for device {DEVICE_ID}: {levels.get('Count', 0)}")
for log in logs[:20]:
    print(f"  {log.get('LogDateUtc','?'):26s}  Level={log.get('Level',0):.1%}  "
          f"Temp={log.get('Temperature','?')}°C  Battery={log.get('BatteryLevel','?')}V")
